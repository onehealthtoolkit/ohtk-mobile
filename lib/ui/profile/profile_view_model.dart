import 'package:podd_app/locator.dart';
import 'package:podd_app/models/profile_result.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/profile_service.dart';
import 'package:stacked/stacked.dart';

class ProfileViewModel extends BaseViewModel {
  IAuthService authService = locator<IAuthService>();
  IProfileService profileService = locator<IProfileService>();

  String? firstName;
  String? lastName;
  String? telephone;

  String? password;
  String? confirmPassword;

  ProfileViewModel() {
    initValue();
  }

  initValue() async {
    if (authService.userProfile?.email == null) {
      await authService.fetchProfile();
    }
    final userProfile = authService.userProfile;
    if (userProfile != null) {
      firstName = userProfile.firstName;
      lastName = userProfile.lastName;
      telephone = userProfile.telephone;
      notifyListeners();
    }
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

    final userProfile = authService.userProfile;
    if (userProfile?.email == null) {
      setErrorForObject("general", "Email not found. some problem occurred!!!");
      isValidData = false;
    }
    if (!isValidData) {
      setBusy(false);
      return ProfileInvalidData();
    }

    var result = await profileService.updateProfile(
        id: userProfile!.id.toString(),
        authorityId: userProfile.authorityId,
        email: userProfile.email!,
        username: userProfile.username,
        firstName: firstName!,
        lastName: lastName!,
        telephone: telephone,
        role: userProfile.role);

    if (result is ProfileSuccess) {
      if (!result.success) {
        setErrorForObject("general", result.message);
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