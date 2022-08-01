import 'package:podd_app/models/operation_exception_failure.dart';

abstract class AuthResult {}

class AuthSuccess extends AuthResult {
  String token;
  String refreshToken;
  // seconds since epoch
  int refreshExpiresIn;

  AuthSuccess({
    required this.token,
    required this.refreshToken,
    required this.refreshExpiresIn,
  });
}

class AuthFailure extends OperationExceptionFailure with AuthResult {
  AuthFailure(e) : super(e);
}
