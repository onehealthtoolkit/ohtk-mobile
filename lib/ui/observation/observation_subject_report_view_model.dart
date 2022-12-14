import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_subject_report.dart';
import 'package:podd_app/services/observation_service.dart';
import 'package:stacked/stacked.dart';

class ObservationSubjectReportViewModel extends ReactiveViewModel {
  IObservationService observationService = locator<IObservationService>();

  int subjectId;

  ObservationSubjectReportViewModel(this.subjectId) {
    fetchSubjectReports();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [observationService];

  List<ObservationSubjectReport> get observationSubjectReports =>
      observationService.observationSubjectReports;

  fetchSubjectReports() {
    observationService.fetchAllObservationSubjectReports(subjectId);
  }
}
