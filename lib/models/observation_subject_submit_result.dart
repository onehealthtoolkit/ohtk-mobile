import 'package:podd_app/models/entities/observation_report_subject.dart';
import 'package:podd_app/models/operation_exception_failure.dart';

abstract class ObservationSubjectSubmitResult {}

class ObservationSubjectSubmitSuccess extends ObservationSubjectSubmitResult {
  final ObservationReportSubject _report;

  ObservationSubjectSubmitSuccess(this._report);

  ObservationReportSubject get report => _report;
}

class ObservationSubjectSubmitFailure extends OperationExceptionFailure
    with ObservationSubjectSubmitResult {
  ObservationSubjectSubmitFailure(e) : super(e);
}

class ObservationSubjectSubmitPending extends ObservationSubjectSubmitResult {}
