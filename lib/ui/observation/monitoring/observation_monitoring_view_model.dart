import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_monitoring_definition.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/services/observation_service.dart';
import 'package:stacked/stacked.dart';

class ObservationMonitoringRecordViewModel
    extends FutureViewModel<ObservationSubjectMonitoring> {
  IObservationService observationService = locator<IObservationService>();

  ObservationMonitoringDefinition monitoringDefinition;
  ObservationSubject subject;
  ObservationSubjectMonitoring monitoringRecord;

  ObservationMonitoringRecordViewModel({
    required this.monitoringDefinition,
    required this.subject,
    required this.monitoringRecord,
  });

  @override
  Future<ObservationSubjectMonitoring> futureToRun() {
    return observationService
        .getObservationSubjectMonitoring(monitoringRecord.id);
  }
}
