import 'package:gql_dio_link/gql_dio_link.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/login_result.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:stacked/stacked.dart';

class LoginViewModel extends BaseViewModel {
  IAuthService authService = locator<IAuthService>();

  String? username;
  String? password;

  authenticate() async {
    setBusy(true);
    bool hasError = false;

    if (username == null || username!.isEmpty) {
      setErrorForObject("username", "Username is required");
      hasError = true;
    }
    if (password == null || password!.isEmpty) {
      setErrorForObject("password", "Password is required");
      hasError = true;
    }

    if (hasError) {
      setBusy(false);
      notifyListeners();
      return;
    }
    try {
      var loginResult = await authService.authenticate(username!, password!);
      if (loginResult is LoginFailure) {
        setErrorForObject("general", loginResult.messages.join("\n"));
      } else {
        clearErrors();
      }
    } on DioLinkServerException {
      setErrorForObject("general", "Server Error");
    } on DioLinkUnkownException {
      setErrorForObject("general", "Connection refused");
    }

    setBusy(false);
  }

  void setUsername(String value) {
    username = value;
    if (hasErrorForKey('username')) {
      setErrorForObject("username", null);
    }
  }

  void setPassword(String value) {
    password = value;
    if (hasErrorForKey('password')) {
      setErrorForObject("password", null);
    }
  }
}
