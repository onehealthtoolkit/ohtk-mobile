import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/services/observation_service.dart';
import 'package:stacked/stacked.dart';

class ObservationSubjectMonitoringViewModel extends ReactiveViewModel {
  IObservationService observationService = locator<IObservationService>();

  int subjectId;

  ObservationSubjectMonitoringViewModel(this.subjectId) {
    fetchSubjectMonitorings();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [observationService];

  List<ObservationSubjectMonitoring> get observationSubjectMonitorings =>
      observationService.observationSubjectMonitorings;

  fetchSubjectMonitorings() {
    observationService.fetchAllObservationSubjectMonitorings(subjectId);
  }
}
