import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/login_result.dart';
import 'package:podd_app/models/user_profile.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/ui/login/login_view_model.dart';

class AuthServiceMock implements IAuthService {
  String? username;
  String? password;

  @override
  Future<AuthResult> authenticate(String _username, String _password) {
    username = _username;
    password = _password;
    return Future.value(
      AuthSuccess(
          token: "token",
          refreshToken: "refreshToken",
          refreshExpiresIn: 123232323232),
    );
  }

  @override
  Future<void> logout() async {}

  @override
  bool? get isLogin => throw UnimplementedError();

  reset() {
    username = null;
    password = null;
  }

  @override
  UserProfile? get userProfile => null;

  @override
  Future<void> saveTokenAndFetchProfile(AuthSuccess loginSuccess) {
    throw UnimplementedError();
  }

  @override
  Future<void> requestAccessTokenIfExpired() {
    // TODO: implement requestAccessTokenIfExpired
    throw UnimplementedError();
  }
}

void main() {
  group('Login View Model', () {
    AuthServiceMock authService = AuthServiceMock();

    setUpAll(() {
      locator.registerSingleton<IAuthService>(authService);
      authService.reset();
    });

    test('update username', () {
      LoginViewModel model = LoginViewModel();
      expect(model.username, null);
      model.setUsername("test");
      expect(model.username, "test");
    });

    test('update password', () {
      LoginViewModel model = LoginViewModel();
      expect(model.password, null);
      model.setPassword("passtest");
      expect(model.password, "passtest");
    });

    test('authenticate', () {
      LoginViewModel model = LoginViewModel();
      model.setUsername("test");
      model.setPassword("testpass");
      model.authenticate();
      expect(model.username, authService.username);
      expect(model.password, authService.password);
    });

    group('validate', () {
      test('username and password should not be empty', () {
        LoginViewModel model = LoginViewModel();
        model.authenticate();
        expect(model.hasErrorForKey('username'), isTrue);
        expect(model.hasErrorForKey('password'), isTrue);
      });

      test('Clear usernameError is setUsername is called', () {
        LoginViewModel model = LoginViewModel();
        model.setErrorForObject('username', "test error");
        model.setUsername("anyname");
        expect(model.hasErrorForKey('username'), isFalse);
      });

      test('Clear passwordError is setPassword is called', () {
        LoginViewModel model = LoginViewModel();
        model.setErrorForObject('password', "test error");
        model.setPassword("anyname");
        expect(model.hasErrorForKey('password'), isFalse);
      });

      test('isUsernameError and isPasswordError is working', () {
        LoginViewModel model = LoginViewModel();
        expect(model.hasErrorForKey('username'), isFalse);
        expect(model.hasErrorForKey('password'), isFalse);
        model.authenticate();
        expect(model.hasErrorForKey('username'), isTrue);
        expect(model.hasErrorForKey('password'), isTrue);
      });
    });
  });
}
