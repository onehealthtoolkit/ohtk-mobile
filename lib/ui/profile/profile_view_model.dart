import 'package:image_picker/image_picker.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/profile_result.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

const languageKey = "language";

class ProfileViewModel extends BaseViewModel {
  IAuthService authService = locator<IAuthService>();
  IProfileService profileService = locator<IProfileService>();

  String? username;
  String? authorityName;
  String? firstName;
  String? lastName;
  String? email;
  String? telephone;
  String? avatarUrl;

  String? password;
  String? confirmPassword;

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

  void setPassword(String value) {
    password = value;
    _clearErrorForKey('password');
  }

  void setConfirmPassword(String value) {
    confirmPassword = value;
    _clearErrorForKey('confirmPassword');
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
      setErrorForObject("firstName", "First name is required");
      isValidData = false;
    }
    if (lastName == null || lastName!.isEmpty) {
      setErrorForObject("lastName", "Last name is required");
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

  Future<ProfileResult> changePassword() async {
    setBusy(true);
    var isValidData = true;
    if (password == null || password!.isEmpty) {
      setErrorForObject("password", "Password is required");
      isValidData = false;
    }
    if (confirmPassword == null || confirmPassword!.isEmpty) {
      setErrorForObject("confirmPassword", "Confirm Password is required");
      isValidData = false;
    }

    if (password != confirmPassword) {
      isValidData = false;
      setErrorForObject(
          "generalChangePassword", "Password does not match confirm password");
    }
    if (!isValidData) {
      setBusy(false);
      return ProfileInvalidData();
    }

    var result = await profileService.changePassword(password!);

    if (result is ProfileSuccess) {
      if (!result.success) {
        setErrorForObject("generalChangePassword", result.message);
      }
    } else if (result is ProfileFailure) {
      setErrorForObject("generalChangePassword", result.messages.join(','));
    }
    setBusy(false);
    return result;
  }

  logout() {
    authService.logout();
  }
}
