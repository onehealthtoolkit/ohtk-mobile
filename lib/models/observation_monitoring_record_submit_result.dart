import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/models/operation_exception_failure.dart';

abstract class ObservationMonitoringRecordSubmitResult {}

class ObservationMonitoringRecordSubmitSuccess
    extends ObservationMonitoringRecordSubmitResult {
  final ObservationSubjectMonitoring _monitoringRecord;

  ObservationMonitoringRecordSubmitSuccess(this._monitoringRecord);

  ObservationSubjectMonitoring get monitoringRecord => _monitoringRecord;
}

class ObservationMonitoringRecordSubmitFailure extends OperationExceptionFailure
    with ObservationMonitoringRecordSubmitResult {
  ObservationMonitoringRecordSubmitFailure(e) : super(e);
}

class ObservationMonitoringRecordSubmitPending
    extends ObservationMonitoringRecordSubmitResult {}
