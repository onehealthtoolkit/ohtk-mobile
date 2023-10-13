import 'package:podd_app/models/operation_exception_failure.dart';

class InvitationCodeResult {}

class InvitationCodeSuccess extends InvitationCodeResult {
  String authorityName;
  String? generatedUsername;
  String? generatedEmail;

  InvitationCodeSuccess(
      this.authorityName, this.generatedUsername, this.generatedEmail);
}

class InvitationCodeFailure extends OperationExceptionFailure
    with InvitationCodeResult {
  InvitationCodeFailure(e) : super(e);
}
