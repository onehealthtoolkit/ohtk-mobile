import 'package:podd_app/models/operation_exception_failure.dart';

class FcmTokenRegisterResult {}

class FcmTokenRegisterSuccess extends FcmTokenRegisterResult {
  bool success;

  FcmTokenRegisterSuccess(this.success);
}

class FcmTokenRegisterFailure extends OperationExceptionFailure
    with FcmTokenRegisterResult {
  FcmTokenRegisterFailure(e) : super(e);
}
