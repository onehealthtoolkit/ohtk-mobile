import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

abstract class IAuthService extends Listenable {
  bool? get isLogin;

  UserProfile? get userProfile;

  Future<AuthResult> authenticate(String username, String password);

  Future<void> logout();

  Future<void> saveTokenAndFetchProfile(AuthSuccess loginSuccess);

  Future<void> fetchProfile();

  // return true if token is expired and cannot refresh
  // return false if token is not expired or expired but refresh successfully
  Future<bool> requestAccessTokenIfExpired();

  Future<AuthResult> verifyQrToken(String token);

  updateConfirmedConsent();

  updateAvatarUrl(String avatarUrl);
}

class AuthService with ListenableServiceMixin implements IAuthService {
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
      var isExpired = await requestAccessTokenIfExpired();
      if (isExpired) {
        _isLogin.value = false;
      } else {
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
          var isExpired = await requestAccessTokenIfExpired();
          if (isExpired) {
            _isLogin.value = false;
          } else {
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
    _isLogin.value = false;
    _token = null;
    await _secureStorageService.deleteAll();
    await _reportService.removeAllPendingReports();
    await _observationRecordService.removeAllPendingRecords();
    await _reportTypeService.removeAll();
    await _observationDefinitionService.removeAll();
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
    _token = authSuccess.token;
    await _secureStorageService.setLoginSuccess(authSuccess);
  }

  _fetchProfile() async {
    var profile = await _authApi.getUserProfile();
    _userProfile = profile;

    await _secureStorageService.setUserProfile(profile);
    await _reportTypeService.sync();
    await _observationDefinitionService.sync();
  }

  // return true if token is expired and cannot refresh
  // return false if token is not expired or expired but refresh successfully
  /* 
    1. If there is a token, and it 's expire then try to refresh it.
    2. If the token is refreshed, return false.
    3. If the token is not refreshed, return true.
    4. If there is no token, return true. 
  */
  @override
  Future<bool> requestAccessTokenIfExpired() async {
    if (_token != null) {
      if (Jwt.isExpired(_token!)) {
        _logger.d("token expired");
        try {
          var authResult = await _authApi.refreshToken();
          if (authResult is AuthSuccess) {
            await _saveToken(authResult);
            return false;
          }
        } catch (e) {
          // could be network error
        }
        return true; // try to refresh token but failed
      } else {
        return false;
      }
    }
    return true; // token is null, then token is expired for sure.
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
}
