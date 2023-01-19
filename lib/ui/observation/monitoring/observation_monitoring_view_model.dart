import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_monitoring_definition.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/services/observation_record_service.dart';
import 'package:stacked/stacked.dart';

class ObservationMonitoringRecordViewModel
    extends FutureViewModel<ObservationMonitoringRecord> {
  IObservationRecordService observationService =
      locator<IObservationRecordService>();

  ObservationMonitoringDefinition monitoringDefinition;
  ObservationSubjectRecord subject;
  ObservationMonitoringRecord monitoringRecord;

  ObservationMonitoringRecordViewModel({
    required this.monitoringDefinition,
    required this.subject,
    required this.monitoringRecord,
  });

  @override
  Future<ObservationMonitoringRecord> futureToRun() {
    return observationService.getMonitoringRecord(monitoringRecord.id);
  }
}
