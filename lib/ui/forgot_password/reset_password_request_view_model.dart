import 'package:podd_app/locator.dart';
import 'package:podd_app/models/forgot_password_result.dart';
import 'package:podd_app/services/forgot_password_service.dart';
import 'package:stacked/stacked.dart';

class ResetPasswordRequestViewModel extends BaseViewModel {
  IForgotPasswordService forgotPasswordService =
      locator<IForgotPasswordService>();

  String? email;

  _clearErrorForKey(String key) {
    if (hasErrorForKey(key)) {
      setErrorForObject(key, null);
    }
  }

  void setEmail(String value) {
    email = value;
    _clearErrorForKey('email');
  }

  Future<ForgotPasswordResult> resetPasswordRequest() async {
    setBusy(true);
    var isValidData = true;
    if (email == null || email!.isEmpty) {
      setErrorForObject("email", "Email is required");
      isValidData = false;
    }

    if (!isValidData) {
      setBusy(false);
      return ForgotPasswordInvalidData();
    }

    var result = await forgotPasswordService.resetPasswordRequest(
      email!,
    );
    if (result is ForgotPasswordSuccess) {
      notifyListeners();
    } else if (result is ForgotPasswordFailure) {
      setErrorForObject("general", result.messages.join(','));
    }
    setBusy(false);
    return result;
  }
}
