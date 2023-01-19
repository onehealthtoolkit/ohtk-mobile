import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/login_result.dart';
import 'package:podd_app/models/user_profile.dart';
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

abstract class IAuthService {
  bool? get isLogin;

  UserProfile? get userProfile;

  Future<AuthResult> authenticate(String username, String password);

  Future<void> logout();

  Future<void> saveTokenAndFetchProfile(AuthSuccess loginSuccess);

  Future<void> fetchProfile();

  Future<void> requestAccessTokenIfExpired();

  Future<AuthResult> verifyQrToken(String token);

  updateConfirmedConsent();
}

class AuthService with ReactiveServiceMixin implements IAuthService {
  final ISecureStorageService _secureStorageService =
      locator<ISecureStorageService>();

  final _logger = locator<Logger>();

  final _authApi = locator<AuthApi>();

  final _reportTypeService = locator<IReportTypeService>();

  final _reportService = locator<IReportService>();

  final _gqlService = locator<GqlService>();

  final _observationDefinitionService =
      locator<IObservationDefinitionService>();

  final _observationRecordService = locator<IObservationRecordService>();

  final ReactiveValue<bool?> _isLogin = ReactiveValue<bool?>(null);

  String? _token;

  UserProfile? _userProfile;
  @override
  UserProfile? get userProfile => _userProfile;

  AuthService() {
    listenToReactiveValues([_isLogin]);
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
      _userProfile = await _secureStorageService.getUserProfile();
      await requestAccessTokenIfExpired();
      _isLogin.value = true;
    } else {
      _isLogin.value = false;
    }
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
    _isLogin.value = false;
    await _secureStorageService.deleteAll();
    await _reportService.removeAllPendingReports();
    await _observationRecordService.removeAllPendingRecords();
    await _reportTypeService.removeAll();
    await _gqlService.clearCookies();
    await _gqlService.clearGraphqlCache();
  }

  @override
  Future<void> saveTokenAndFetchProfile(AuthSuccess authSuccess) async {
    await _saveToken(authSuccess);
    await _fetchProfile();
    _isLogin.value = true;
  }

  _saveToken(AuthSuccess authSuccess) async {
    await _secureStorageService.setLoginSuccess(authSuccess);
    _token = authSuccess.token;
  }

  _fetchProfile() async {
    var profile = await _authApi.getUserProfile();
    _userProfile = profile;

    await _secureStorageService.setUserProfile(profile);
    await _reportTypeService.sync();
    await _observationDefinitionService.sync();
  }

  @override
  Future<void> requestAccessTokenIfExpired() async {
    if (_token != null) {
      if (Jwt.isExpired(_token!)) {
        _logger.d("token expired");
        var authResult = await _authApi.refreshToken();
        if (authResult is AuthSuccess) {
          await _saveToken(authResult);
        }
      }
    }
  }

  @override
  Future<void> fetchProfile() async {
    _fetchProfile();
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
}
