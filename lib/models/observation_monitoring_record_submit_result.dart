import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/models/operation_exception_failure.dart';
import 'package:podd_app/models/submission_problem.dart';

abstract class MonitoringRecordSubmitResult {}

class MonitoringRecordSubmitSuccess extends MonitoringRecordSubmitResult {
  final ObservationMonitoringRecord _monitoringRecord;

  int pendingAttachments = 0;
  final attachmentProblems = <String, SubmissionProblem>{};

  MonitoringRecordSubmitSuccess(this._monitoringRecord);

  ObservationMonitoringRecord get monitoringRecord => _monitoringRecord;
}

class MonitoringRecordSubmitFailure extends OperationExceptionFailure
    implements MonitoringRecordSubmitResult {
  final SubmissionProblem? problem;
  MonitoringRecordSubmitFailure(e, {this.problem}) : super(e);
}

class MonitoringRecordSubmitPending extends MonitoringRecordSubmitResult {
  final SubmissionProblem? problem;
  MonitoringRecordSubmitPending([this.problem]);
}
