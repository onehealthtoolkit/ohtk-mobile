import 'package:podd_app/models/entities/followup_report.dart';
import 'package:podd_app/models/operation_exception_failure.dart';

abstract class FollowupSubmitResult {}

class FollowupSubmitSuccess extends FollowupSubmitResult {
  final FollowupReport _followupReport;

  FollowupSubmitSuccess(this._followupReport);

  FollowupReport get followupReport => _followupReport;
}

class FollowupSubmitFailure extends OperationExceptionFailure
    with FollowupSubmitResult {
  FollowupSubmitFailure(e) : super(e);
}
