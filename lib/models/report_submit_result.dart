import 'package:podd_app/models/operation_exception_failure.dart';

abstract class ReportSubmitResult {}

class ReportSubmitSuccess extends ReportSubmitResult {
  final String id;
  ReportSubmitSuccess({required this.id});
}

class ReportSubmitFailure extends OperationExceptionFailure
    with ReportSubmitResult {
  ReportSubmitFailure(e) : super(e);
}

class ReportSubmitPending extends ReportSubmitResult {}
