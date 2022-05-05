import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/login_result.dart';
import 'package:podd_app/models/user_profile.dart';
import 'package:podd_app/services/secure_storage_service.dart';
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

  final ReactiveValue<bool?> _isLogin = ReactiveValue<bool?>(null);

  String? _token;
  String? get token => _token;

  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  AuthService() {
    listenToReactiveValues([_isLogin]);
  }

  init() async {
    var token = await secureStorageService.get('token');
    logger.d("token $token");
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
