import 'package:podd_app/models/operation_exception_failure.dart';

class InvitationCodeResult {}

class InvitationCodeSuccess extends InvitationCodeResult {
  String authorityName;

  InvitationCodeSuccess(this.authorityName);
}

class InvitationCodeFailure extends OperationExceptionFailure
    with InvitationCodeResult {
  InvitationCodeFailure(e) : super(e);
}
