import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/models/entities/observation_monitoring_definition.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/services/observation_record_service.dart';
import 'package:stacked/stacked.dart';

class ObservationSubjectMonitoringViewModel extends ReactiveViewModel {
  IObservationRecordService observationService =
      locator<IObservationRecordService>();

  ObservationDefinition definition;
  ObservationSubjectRecord subject;

  ObservationSubjectMonitoringViewModel({
    required this.definition,
    required this.subject,
  });

  @override
  List<ListenableServiceMixin> get listenableServices => [observationService];

  List<ObservationMonitoringDefinition> get observationMonitoringDefinitions =>
      definition.monitoringDefinitions
        ..sort((a, b) => a.name.compareTo(b.name));

  List<ObservationMonitoringRecord> get observationSubjectMonitoringRecords =>
      observationService.monitoringRecords;

  List<ObservationMonitoringRecord> getSortedMonitoringRecords(
      int monitoringDefinitionId) {
    return observationSubjectMonitoringRecords
        .where(
            (record) => record.monitoringDefinitionId == monitoringDefinitionId)
        .toList();
  }

  fetchSubjectMonitorings() {
    observationService.fetchAllMonitoringRecords(subject.id);
  }
}
