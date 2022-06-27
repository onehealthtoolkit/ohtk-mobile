import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/login_result.dart';
import 'package:podd_app/models/user_profile.dart';
import 'package:podd_app/services/report_type_service.dart';
import 'package:podd_app/services/secure_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

import 'api/auth_api.dart';

abstract class IAuthService {
  bool? get isLogin;

  String? get token;
  UserProfile? get userProfile;

  Future<LoginResult> authenticate(String username, String password);

  Future<void> logout();

  Future<void> saveTokenAndFetchProfile(LoginSuccess loginSuccess);
}

class AuthService with ReactiveServiceMixin implements IAuthService {
  final ISecureStorageService secureStorageService =
      locator<ISecureStorageService>();

  final logger = locator<Logger>();

  final _authApi = locator<AuthApi>();

  final _reportTypeService = locator<IReportTypeService>();

  final ReactiveValue<bool?> _isLogin = ReactiveValue<bool?>(null);

  String? _token;
  @override
  String? get token => _token;

  UserProfile? _userProfile;
  @override
  UserProfile? get userProfile => _userProfile;

  AuthService() {
    listenToReactiveValues([_isLogin]);
  }

  init() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('first_run') ?? true) {
      await secureStorageService.deleteAll();

      prefs.setBool('first_run', false);
    }

    var token = await secureStorageService.get('token');
    var refreshToken = await secureStorageService.get('refreshToken');
    logger.d("token $token");
    logger.d("refreshToken $refreshToken");
    if (token != null) {
      _token = token;
      _userProfile = await secureStorageService.getUserProfile();
      _isLogin.value = true;
    } else {
      _isLogin.value = false;
    }
  }

  @override
  bool? get isLogin => _isLogin.value;

  @override
  Future<LoginResult> authenticate(String username, String password) async {
    var loginResult = await _authApi.tokenAuth(username, password);
    if (loginResult is LoginSuccess) {
      logger.d("loginResule ${loginResult.token}");
      await saveTokenAndFetchProfile(loginResult);
      await _reportTypeService.sync();
    }
    return loginResult;
  }

  @override
  Future<void> logout() async {
    _isLogin.value = false;
    await secureStorageService.deleteAll();
  }

  @override
  Future<void> saveTokenAndFetchProfile(LoginSuccess loginSuccess) async {
    await secureStorageService.setLoginSuccess(loginSuccess);
    var profile = await _authApi.getUserProfile();
    await secureStorageService.setUserProfile(profile);
    _userProfile = profile;
    _token = loginSuccess.token;
    _isLogin.value = true;
  }
}
