import 'package:podd_app/locator.dart';
import 'package:podd_app/models/profile_result.dart';
import 'package:podd_app/services/profile_service.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChangePasswordViewModel extends BaseViewModel {
  IProfileService profileService = locator<IProfileService>();
  String? password;
  String? confirmPassword;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  final localize = locator<AppLocalizations>();

  void setPassword(String value) {
    password = value;
    _clearErrorForKey('password');
  }

  void setConfirmPassword(String value) {
    confirmPassword = value;
    _clearErrorForKey('confirmPassword');
  }

  void setObscurePassword(bool value) {
    obscurePassword = value;
    notifyListeners();
  }

  void setObscureConfirmPassword(bool value) {
    obscureConfirmPassword = value;
    notifyListeners();
  }

  _clearErrorForKey(String key) {
    if (hasErrorForKey(key)) {
      setErrorForObject(key, null);
    }
  }

  Future<ProfileResult> changePassword() async {
    setBusy(true);
    var isValidData = true;
    if (password == null || password!.isEmpty) {
      setErrorForObject("password", localize.fieldRequired);
      isValidData = false;
    }
    if (confirmPassword == null || confirmPassword!.isEmpty) {
      setErrorForObject("confirmPassword", localize.fieldRequired);
      isValidData = false;
    }

    if (password != confirmPassword) {
      isValidData = false;
      setErrorForObject("generalChangePassword", localize.passwordMismatch);
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
}
