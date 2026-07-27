import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/constants.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/login_result.dart';
import 'package:podd_app/models/user_profile.dart';
import 'package:podd_app/models/village.dart';
import 'package:podd_app/services/feature_capability_service.dart';
import 'package:podd_app/services/gql_service.dart';
import 'package:podd_app/services/jwt.dart';
import 'package:podd_app/services/observation_definition_service.dart';
import 'package:podd_app/services/observation_record_service.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:podd_app/services/report_type_service.dart';
import 'package:podd_app/services/secure_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'dart:async';

import 'api/auth_api.dart';

/// Outcome of [IAuthService.ensureValidAccessToken].
enum EnsureAccessTokenResult {
  /// Access token is usable (already valid or just refreshed).
  valid,

  /// No usable session — full logout has been applied when a session existed.
  unauthenticated,

  /// Network / transient failure — keep session; do not force logout.
  transientFailure,
}

/// Shared hard-fail markers for django-graphql-jwt refresh errors
/// (both classic and long-running refresh token paths).
class AuthTokenFailureMessages {
  static const hardRefreshFailures = <String>[
    'Refresh has expired',
    'Refresh token is expired',
    'Invalid refresh token',
    'invalid refresh',
  ];

  static bool isHardRefreshFailure(String message) {
    final lower = message.toLowerCase();
    for (final marker in hardRefreshFailures) {
      if (lower.contains(marker.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  static bool anyHardRefreshFailure(Iterable<String> messages) {
    for (final message in messages) {
      if (isHardRefreshFailure(message)) {
        return true;
      }
    }
    return false;
  }
}

abstract class IAuthService extends Listenable {
  bool? get isLogin;

  UserProfile? get userProfile;

  Village? get selectedVillage;

  /// Current in-memory access token (if any). Used by reactive refresh (S1).
  String? get accessToken;

  Future<AuthResult> authenticate(String username, String password);

  Future<void> logout();

  Future<void> saveTokenAndFetchProfile(AuthSuccess loginSuccess);

  Future<void> fetchProfile();

  /// Ensures a usable access token via a single refresh pipeline.
  ///
  /// [force] refreshes even if the current access token is still within skew.
  /// [failedAccessToken] is the access token that produced a JWT-expired error;
  /// if the session already has a newer token, no second refresh is performed (S1).
  Future<EnsureAccessTokenResult> ensureValidAccessToken({
    bool force = false,
    String? failedAccessToken,
  });

  /// Legacy bool API: `true` when session is unusable (should logout).
  /// Network/transient failures return `false` (do not force logout).
  Future<bool> requestAccessTokenIfExpired();

  Future<AuthResult> verifyQrToken(String token);

  updateConfirmedConsent();

  updateAvatarUrl(String avatarUrl);

  Future<void> selectVillage(int villageId);
}

class AuthService with ListenableServiceMixin implements IAuthService {
  final ISecureStorageService _secureStorageService;
  final Logger _logger;
  final AuthApi _authApi;
  final IFeatureCapabilityService _featureCapabilityService;
  final IReportTypeService _reportTypeService;
  final IReportService _reportService;
  final GqlService _gqlService;
  final IObservationDefinitionService _observationDefinitionService;
  final IObservationRecordService _observationRecordService;

  final ReactiveValue<bool?> _isLogin = ReactiveValue<bool?>(null);

  String? _token;
  String? _refreshToken;

  /// Bumped on login/logout so stale in-flight refreshes cannot commit (S3).
  int _sessionGeneration = 0;

  /// True while [logout] is clearing durable state — blocks rehydrate.
  bool _logoutInProgress = false;

  Future<EnsureAccessTokenResult>? _ensureInFlight;

  /// Serializes logout so concurrent unauthenticated paths share one cleanup.
  Future<void>? _logoutInFlight;

  UserProfile? _userProfile;
  @override
  UserProfile? get userProfile => _userProfile;

  final ReactiveValue<Village?> _selectedVillage =
      ReactiveValue<Village?>(null);
  @override
  Village? get selectedVillage => _selectedVillage.value;

  @override
  String? get accessToken => _token;

  AuthService({
    ISecureStorageService? secureStorageService,
    Logger? logger,
    AuthApi? authApi,
    IFeatureCapabilityService? featureCapabilityService,
    IReportTypeService? reportTypeService,
    IReportService? reportService,
    GqlService? gqlService,
    IObservationDefinitionService? observationDefinitionService,
    IObservationRecordService? observationRecordService,
  })  : _secureStorageService =
            secureStorageService ?? locator<ISecureStorageService>(),
        _logger = logger ?? locator<Logger>(),
        _authApi = authApi ?? locator<AuthApi>(),
        _featureCapabilityService =
            featureCapabilityService ?? locator<IFeatureCapabilityService>(),
        _reportTypeService =
            reportTypeService ?? locator<IReportTypeService>(),
        _reportService = reportService ?? locator<IReportService>(),
        _gqlService = gqlService ?? locator<GqlService>(),
        _observationDefinitionService = observationDefinitionService ??
            locator<IObservationDefinitionService>(),
        _observationRecordService = observationRecordService ??
            locator<IObservationRecordService>() {
    listenToReactiveValues([_isLogin, _selectedVillage]);
  }

  init() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('first_run') ?? true) {
      await _secureStorageService.deleteAll();

      prefs.setBool('first_run', false);
    }

    var token = await _secureStorageService.get('token');
    if (token != null) {
      _token = token;
      _refreshToken = await _secureStorageService.get('refreshToken');
      _userProfile = await _secureStorageService.getUserProfile();
      await _syncSelectedVillage();
      final ensureResult = await ensureValidAccessToken();
      if (ensureResult == EnsureAccessTokenResult.unauthenticated) {
        // ensureValidAccessToken already performed full logout when needed.
        _isLogin.value = false;
      } else {
        if (_userProfile != null) {
          await _refreshFeatureCapabilitiesAndAssignedVillages(_userProfile!);
          await _syncSelectedVillage();
          await _secureStorageService.setUserProfile(_userProfile!);
        }
        _isLogin.value = true;
      }
    } else {
      _isLogin.value = false;
    }

    _registerLifeCycleHandler();
  }

  _registerLifeCycleHandler() async {
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      switch (msg) {
        case "AppLifecycleState.resumed":
          final ensureResult = await ensureValidAccessToken();
          if (ensureResult == EnsureAccessTokenResult.unauthenticated) {
            _isLogin.value = false;
          } else if (_token != null) {
            _isLogin.value = true;
          }
          break;
        default:
      }
      return null;
    });
  }

  @override
  bool? get isLogin => _isLogin.value;

  @override
  Future<AuthResult> authenticate(String username, String password) async {
    var authResult = await _authApi.tokenAuth(username, password);
    if (authResult is AuthSuccess) {
      _logger.d("loginResule ${authResult.token}");
      await saveTokenAndFetchProfile(authResult);
    }
    return authResult;
  }

  @override
  Future<void> logout() async {
    if (_logoutInFlight != null) {
      return _logoutInFlight!;
    }
    final flight = _performLogout();
    _logoutInFlight = flight;
    try {
      await flight;
    } finally {
      if (identical(_logoutInFlight, flight)) {
        _logoutInFlight = null;
      }
    }
  }

  Future<void> _performLogout() async {
    // Invalidate in-flight refresh/commit immediately (S3).
    _sessionGeneration++;
    _logoutInProgress = true;
    _isLogin.value = false;
    _token = null;
    _refreshToken = null;
    _userProfile = null;
    _selectedVillage.value = null;

    try {
      await _secureStorageService.deleteAll();
      await _reportService.removeAllPendingReports();
      await _observationRecordService.removeAllPendingRecords();
      await _reportTypeService.removeAll();
      await _observationDefinitionService.removeAll();
      await _gqlService.clearCookies();
      await _gqlService.clearGraphqlCache();
      _featureCapabilityService.reset();
    } finally {
      _logoutInProgress = false;
    }
  }

  @override
  Future<void> saveTokenAndFetchProfile(AuthSuccess authSuccess) async {
    _sessionGeneration++;
    _logoutInProgress = false;
    await _saveToken(authSuccess, expectedGeneration: _sessionGeneration);
    await _fetchProfile();
    _isLogin.value = true;
  }

  /// Durable write then memory. Returns false if [expectedGeneration] is stale
  /// after the write (S3/S4) — undoes or repairs storage accordingly.
  Future<bool> _saveToken(
    AuthSuccess authSuccess, {
    required int expectedGeneration,
  }) async {
    if (expectedGeneration != _sessionGeneration) {
      return false;
    }

    await _secureStorageService.setLoginSuccess(authSuccess);

    // S3: logout/login may have raced during the durable write.
    if (expectedGeneration != _sessionGeneration) {
      await _repairStorageAfterStaleCommit();
      return false;
    }

    _token = authSuccess.token;
    _refreshToken = authSuccess.refreshToken;
    return true;
  }

  Future<void> _repairStorageAfterStaleCommit() async {
    if (_token != null &&
        _refreshToken != null &&
        _refreshToken!.isNotEmpty) {
      // A newer login owns memory — rewrite durable state from memory.
      await _secureStorageService.setLoginSuccess(AuthSuccess(
        token: _token!,
        refreshToken: _refreshToken!,
        refreshExpiresIn: 0,
      ));
    } else {
      // Logged out (or empty session) — do not leave resurrected tokens.
      await _secureStorageService.deleteAll();
    }
  }

  _fetchProfile() async {
    var profile = await _authApi.getUserProfile();
    await _refreshFeatureCapabilitiesAndAssignedVillages(profile);
    _userProfile = profile;
    await _syncSelectedVillage();

    await _secureStorageService.setUserProfile(profile);
    await _reportTypeService.sync();
    await _observationDefinitionService.sync();
  }

  Future<void> _refreshFeatureCapabilitiesAndAssignedVillages(
      UserProfile profile) async {
    await _featureCapabilityService.refresh();
    if (_featureCapabilityService.villageEnabled) {
      try {
        profile.assignedVillages = await _authApi.getAssignedVillages();
      } catch (e) {
        _logger.w('Cannot fetch assigned villages: $e');
      }
    }
  }

  @override
  Future<EnsureAccessTokenResult> ensureValidAccessToken({
    bool force = false,
    String? failedAccessToken,
  }) async {
    await _rehydrateTokensIfNeeded();

    // S1: another refresh already replaced the access token that failed.
    if (failedAccessToken != null &&
        _token != null &&
        _token != failedAccessToken) {
      return EnsureAccessTokenResult.valid;
    }

    if (_token == null) {
      // No session to clear — avoid destructive logout on cold/timer ticks.
      return EnsureAccessTokenResult.unauthenticated;
    }

    if (!force && !Jwt.isExpired(_token!)) {
      return EnsureAccessTokenResult.valid;
    }

    if (_ensureInFlight != null) {
      return _ensureInFlight!;
    }

    final flight = _refreshAccessToken();
    _ensureInFlight = flight;
    try {
      return await flight;
    } finally {
      if (identical(_ensureInFlight, flight)) {
        _ensureInFlight = null;
      }
    }
  }

  Future<void> _rehydrateTokensIfNeeded() async {
    if (_logoutInProgress) {
      return;
    }
    if (_token == null) {
      final stored = await _secureStorageService.get('token');
      if (_logoutInProgress) {
        return;
      }
      _token = stored;
    }
    if (_refreshToken == null) {
      final stored = await _secureStorageService.get('refreshToken');
      if (_logoutInProgress) {
        return;
      }
      _refreshToken = stored;
    }
  }

  Future<EnsureAccessTokenResult> _refreshAccessToken() async {
    final generation = _sessionGeneration;
    final refreshToken = _refreshToken;

    if (refreshToken == null || refreshToken.isEmpty) {
      _logger.d("token expired; no refresh token");
      return _invalidateSessionIfPresent();
    }

    _logger.d("token expired; refreshing");
    try {
      final authResult = await _authApi.refreshToken(refreshToken);
      if (authResult is AuthSuccess) {
        if (generation != _sessionGeneration) {
          // S3: logout/login happened while refresh was in flight.
          return EnsureAccessTokenResult.transientFailure;
        }
        final retainedRefresh = (authResult.refreshToken.isNotEmpty)
            ? authResult.refreshToken
            : refreshToken;
        final committed = await _saveToken(
          AuthSuccess(
            token: authResult.token,
            refreshToken: retainedRefresh,
            refreshExpiresIn: authResult.refreshExpiresIn,
          ),
          expectedGeneration: generation,
        );
        if (!committed) {
          return EnsureAccessTokenResult.transientFailure;
        }
        return EnsureAccessTokenResult.valid;
      }
      if (authResult is AuthFailure) {
        if (AuthTokenFailureMessages.anyHardRefreshFailure(
            authResult.messages)) {
          return _invalidateSessionIfPresent();
        }
        _logger.w("refresh failed (soft): ${authResult.messages}");
        return EnsureAccessTokenResult.transientFailure;
      }
      return _invalidateSessionIfPresent();
    } on InvalidRefreshTokenError {
      // Interceptor may already have logged out; still ensure full cleanup.
      return _invalidateSessionIfPresent();
    } catch (e) {
      // Network / transport / unexpected — keep session (S2).
      _logger.w("refresh failed (transient): $e");
      return EnsureAccessTokenResult.transientFailure;
    }
  }

  /// Full logout when a session (or login flag) is present; otherwise no-op.
  Future<EnsureAccessTokenResult> _invalidateSessionIfPresent() async {
    final hadSession = _token != null ||
        _refreshToken != null ||
        _isLogin.value == true ||
        await _secureStorageService.get('token') != null;
    if (hadSession) {
      await logout();
    }
    return EnsureAccessTokenResult.unauthenticated;
  }

  /// return true if session is unusable (should treat as logged out)
  /// return false if access is valid, refreshed, or only transiently failed
  @override
  Future<bool> requestAccessTokenIfExpired() async {
    final result = await ensureValidAccessToken();
    return result == EnsureAccessTokenResult.unauthenticated;
  }

  @override
  Future<void> fetchProfile() async {
    await _fetchProfile();
  }

  @override
  Future<AuthResult> verifyQrToken(String token) async {
    var authResult = await _authApi.verifyLoginQrToken(token);
    if (authResult is AuthSuccess) {
      _logger.d("loginResult success ${authResult.token}");
      await saveTokenAndFetchProfile(authResult);
    }
    return authResult;
  }

  @override
  updateConfirmedConsent() {
    if (_userProfile != null) {
      _userProfile!.consent = true;
      _secureStorageService.setUserProfile(_userProfile!);
    }
  }

  @override
  updateAvatarUrl(String avatarUrl) {
    if (_userProfile != null) {
      _userProfile!.avatarUrl = avatarUrl;
      _secureStorageService.setUserProfile(_userProfile!);
    }
  }

  Future<void> _syncSelectedVillage() async {
    final villages = _userProfile?.assignedVillages ?? const <Village>[];
    if (villages.isEmpty) {
      _selectedVillage.value = null;
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final storedVillageId = prefs.getInt(selectedVillageIdKey);
    final selected = villages.firstWhere(
      (village) => village.id == storedVillageId,
      orElse: () => villages.first,
    );

    _selectedVillage.value = selected;
    await prefs.setInt(selectedVillageIdKey, selected.id);
  }

  @override
  Future<void> selectVillage(int villageId) async {
    final villages = _userProfile?.assignedVillages ?? const <Village>[];
    Village? selected;
    for (final village in villages) {
      if (village.id == villageId) {
        selected = village;
        break;
      }
    }

    if (selected == null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    _selectedVillage.value = selected;
    await prefs.setInt(selectedVillageIdKey, selected.id);
  }
}
