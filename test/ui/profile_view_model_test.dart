import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:podd_app/constants.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/login_result.dart';
import 'package:podd_app/models/profile_result.dart';
import 'package:podd_app/models/user_profile.dart';
import 'package:podd_app/models/village.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/profile_service.dart';
import 'package:podd_app/ui/profile/profile_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AuthServiceMock extends ChangeNotifier implements IAuthService {
  @override
  UserProfile? get userProfile => UserProfile(
        id: 1,
        username: 'tester',
        firstName: 'Test',
        lastName: 'User',
        authorityName: 'Authority',
        authorityId: 10,
      );

  @override
  Village? get selectedVillage => null;

  @override
  bool? get isLogin => true;

  @override
  Future<AuthResult> authenticate(String username, String password) {
    throw UnimplementedError();
  }

  @override
  Future<void> fetchProfile() {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    throw UnimplementedError();
  }

  @override
  Future<bool> requestAccessTokenIfExpired() {
    throw UnimplementedError();
  }

  @override
  Future<void> saveTokenAndFetchProfile(AuthSuccess loginSuccess) {
    throw UnimplementedError();
  }

  @override
  Future<void> selectVillage(int villageId) {
    throw UnimplementedError();
  }

  @override
  updateAvatarUrl(String avatarUrl) {}

  @override
  updateConfirmedConsent() {}

  @override
  Future<AuthResult> verifyQrToken(String token) {
    throw UnimplementedError();
  }
}

class _ProfileServiceMock implements IProfileService {
  @override
  Future<ProfileResult> changePassword(String newPassword) {
    throw UnimplementedError();
  }

  @override
  Future<bool> confirmConsent() {
    throw UnimplementedError();
  }

  @override
  Future<String> getLoginQrToken(int userId) {
    throw UnimplementedError();
  }

  @override
  Future<ProfileResult> updateProfile({
    required String firstName,
    required String lastName,
    String? telephone,
    String? address,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ProfileResult> uploadAvatar(XFile image) {
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await locator.reset();
    SharedPreferences.setMockInitialValues({languageKey: 'lo'});
    locator.registerSingleton<IAuthService>(_AuthServiceMock());
    locator.registerSingleton<IProfileService>(_ProfileServiceMock());
    locator.registerSingleton<AppLocalizations>(
      await AppLocalizations.delegate.load(const Locale('en')),
    );
  });

  tearDown(() async {
    await locator.reset();
  });

  test('loads stored language and notifies listeners', () async {
    final viewModel = ProfileViewModel();
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    await viewModel.initValue();

    expect(viewModel.language, 'lo');
    expect(notifications, greaterThan(0));
  });

  test('persists selected language and updates state', () async {
    final viewModel = ProfileViewModel();
    await viewModel.changeLanguage('th');
    final prefs = await SharedPreferences.getInstance();

    expect(viewModel.language, 'th');
    expect(prefs.getString(languageKey), 'th');
  });
}
