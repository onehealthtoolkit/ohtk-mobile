import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/models/operation_exception_failure.dart';

abstract class MonitoringRecordSubmitResult {}

class MonitoringRecordSubmitSuccess extends MonitoringRecordSubmitResult {
  final ObservationMonitoringRecord _monitoringRecord;

  MonitoringRecordSubmitSuccess(this._monitoringRecord);

  ObservationMonitoringRecord get monitoringRecord => _monitoringRecord;
}

class MonitoringRecordSubmitFailure extends OperationExceptionFailure
    with MonitoringRecordSubmitResult {
  MonitoringRecordSubmitFailure(e) : super(e);
}

class MonitoringRecordSubmitPending extends MonitoringRecordSubmitResult {}
