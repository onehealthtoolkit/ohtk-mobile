import 'package:image_picker/image_picker.dart';
import 'package:podd_app/constants.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/profile_result.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileViewModel extends BaseViewModel {
  IAuthService authService = locator<IAuthService>();
  IProfileService profileService = locator<IProfileService>();
  final localize = locator<AppLocalizations>();

  String? username;
  String? authorityName;
  String? firstName;
  String? lastName;
  String? email;
  String? telephone;
  String? avatarUrl;

  String language = "en";
  XFile? photo;

  ProfileViewModel() {
    initValue();
  }

  initValue() async {
    final userProfile = authService.userProfile;
    final prefs = await SharedPreferences.getInstance();

    if (userProfile != null) {
      firstName = userProfile.firstName;
      lastName = userProfile.lastName;
      telephone = userProfile.telephone;
      username = userProfile.username;
      email = userProfile.email;
      authorityName = userProfile.authorityName;
      avatarUrl = userProfile.avatarUrl;
      notifyListeners();
    }
    language = prefs.getString(languageKey) ?? "en";
  }

  void setFirstName(String value) {
    firstName = value;
    _clearErrorForKey('firstName');
  }

  void setLastName(String value) {
    lastName = value;
    _clearErrorForKey('lastName');
  }

  void setTelephone(String value) {
    telephone = value;
    _clearErrorForKey('telephone');
  }

  Future<void> setPhoto(XFile value) async {
    photo = value;
    await uploadAvatar();
    notifyListeners();
  }

  _clearErrorForKey(String key) {
    if (hasErrorForKey(key)) {
      setErrorForObject(key, null);
    }
  }

  changeLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(languageKey, value);
  }

  Future<ProfileResult> updateProfile() async {
    setBusy(true);
    var isValidData = true;
    if (firstName == null || firstName!.isEmpty) {
      setErrorForObject("firstName", localize.fieldRequired);
      isValidData = false;
    }
    if (lastName == null || lastName!.isEmpty) {
      setErrorForObject("lastName", localize.fieldRequired);
      isValidData = false;
    }

    if (!isValidData) {
      setBusy(false);
      return ProfileInvalidData();
    }

    var result = await profileService.updateProfile(
      firstName: firstName!,
      lastName: lastName!,
      telephone: telephone,
    );

    if (result is ProfileSuccess) {
      if (!result.success) {
        setErrorForObject("general", "Update profile not success!!!");
      }
    } else if (result is ProfileFailure) {
      setErrorForObject("general", result.messages.join(','));
    }
    setBusy(false);
    return result;
  }

  Future<ProfileResult> uploadAvatar() async {
    setBusy(true);
    var result = await profileService.uploadAvatar(photo!);

    if (result is ProfileUploadSuccess) {
      if (result.success) avatarUrl = authService.userProfile?.avatarUrl;
      if (!result.success) {
        setErrorForObject("uploadFail", "Update avatar not success!!!");
      }
    } else if (result is ProfileFailure) {
      setErrorForObject("uploadFail", result.messages.join(','));
    }
    setBusy(false);
    return result;
  }

  Future<String> downloadLoginQrCode() async {
    final userProfile = authService.userProfile;
    setBusyForObject('downloadQrcode', true);
    final token = await profileService.getLoginQrToken(userProfile!.id);
    setBusyForObject('downloadQrcode', false);
    return token;
  }

  logout() {
    authService.logout();
  }
}
