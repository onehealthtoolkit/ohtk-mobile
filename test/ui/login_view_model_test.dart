import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/login_result.dart';
import 'package:podd_app/models/user_profile.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/config_service.dart';
import 'package:podd_app/services/gql_service.dart';
import 'package:podd_app/services/secure_storage_service.dart';
import 'package:podd_app/ui/login/login_view_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/services.dart';

class AuthServiceMock extends ChangeNotifier implements IAuthService {
  String? username;
  String? password;

  @override
  Future<AuthResult> authenticate(String username, String password) {
    this.username = username;
    this.password = password;
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
  Future<bool> requestAccessTokenIfExpired() {
    throw UnimplementedError();
  }

  @override
  Future<void> fetchProfile() {
    throw UnimplementedError();
  }

  @override
  Future<AuthResult> verifyQrToken(String token) {
    throw UnimplementedError();
  }

  @override
  updateConfirmedConsent() {
    throw UnimplementedError();
  }

  @override
  updateAvatarUrl(String avatarUrl) {
    throw UnimplementedError();
  }
}

class ConfigServiceMock extends ConfigService {}

class GqlServiceMock extends GqlService {}

class SecureStorageServiceMock implements ISecureStorageService {
  @override
  Future<void> deleteAll() {
    throw UnimplementedError();
  }

  @override
  Future<String?> get(String key) {
    throw UnimplementedError();
  }

  @override
  Future<UserProfile?> getUserProfile() {
    throw UnimplementedError();
  }

  @override
  Future<void> set(String key, String value) {
    throw UnimplementedError();
  }

  @override
  Future<void> setLoginSuccess(AuthSuccess info) {
    throw UnimplementedError();
  }

  @override
  Future<void> setUserProfile(UserProfile profile) {
    throw UnimplementedError();
  }
}

void main() {
  group('Login View Model', () {
    AuthServiceMock authService = AuthServiceMock();
    ConfigServiceMock configService = ConfigServiceMock();
    SecureStorageServiceMock secureStorageService = SecureStorageServiceMock();

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();

      const MethodChannel channel1 =
          MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel1, (MethodCall methodCall) async {
        return ".";
      });

      const MethodChannel channel2 =
          MethodChannel('plugins.flutter.io/shared_preferences');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel2, (MethodCall methodCall) async {
        return {};
      });

      await initHiveForFlutter();

      locator.registerSingleton<IAuthService>(authService);
      locator.registerSingleton<ConfigService>(configService);
      locator.registerSingleton<ISecureStorageService>(secureStorageService);

      GqlServiceMock gqlService = GqlServiceMock();
      locator.registerSingleton<GqlService>(gqlService);
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

    test('authenticate', () async {
      LoginViewModel model = LoginViewModel();
      model.setUsername("test");
      model.setPassword("testpass");
      await model.authenticate();
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
