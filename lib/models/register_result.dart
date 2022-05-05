import 'package:podd_app/models/login_result.dart';
import 'package:podd_app/models/operation_exception_failure.dart';

class RegisterResult {}

class RegisterSuccess extends RegisterResult {
  LoginSuccess loginSuccess;

  RegisterSuccess({required this.loginSuccess});
}

class RegisterFailure extends OperationExceptionFailure with RegisterResult {
  RegisterFailure(e) : super(e);
}
