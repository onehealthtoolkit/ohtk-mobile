import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/models/entities/observation_monitoring_definition.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/services/observation_service.dart';
import 'package:stacked/stacked.dart';

class ObservationSubjectMonitoringViewModel extends ReactiveViewModel {
  IObservationService observationService = locator<IObservationService>();

  ObservationDefinition definition;
  ObservationSubject subject;

  ObservationSubjectMonitoringViewModel({
    required this.definition,
    required this.subject,
  });

  @override
  List<ReactiveServiceMixin> get reactiveServices => [observationService];

  List<ObservationMonitoringDefinition> get observationMonitoringDefinitions =>
      definition.monitoringDefinitions;

  List<ObservationSubjectMonitoring> get observationSubjectMonitoringRecords =>
      observationService.observationSubjectMonitorings;

  List<ObservationSubjectMonitoring> getSortedMonitoringRecords(
      int monitoringDefinitionId) {
    return observationSubjectMonitoringRecords
        .where(
            (record) => record.monitoringDefinitionId == monitoringDefinitionId)
        .toList();
  }

  fetchSubjectMonitorings() {
    observationService.fetchAllObservationSubjectMonitorings(subject.id);
  }
}
