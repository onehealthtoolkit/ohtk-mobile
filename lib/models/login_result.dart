import 'package:podd_app/models/operation_exception_failure.dart';

abstract class LoginResult {}

class LoginSuccess extends LoginResult {
  String token;
  String refreshToken;
  // seconds since epoch
  int refreshExpiresIn;

  LoginSuccess({
    required this.token,
    required this.refreshToken,
    required this.refreshExpiresIn,
  });
}

class LoginFailure extends OperationExceptionFailure with LoginResult {
  LoginFailure(e) : super(e);
}
