import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_subject_report.dart';
import 'package:podd_app/services/observation_record_service.dart';
import 'package:stacked/stacked.dart';

class ObservationSubjectReportViewModel extends ReactiveViewModel {
  IObservationRecordService observationService =
      locator<IObservationRecordService>();

  int subjectId;

  ObservationSubjectReportViewModel(this.subjectId) {
    fetchSubjectReports();
  }

  @override
  List<ListenableServiceMixin> get listenableServices => [observationService];

  List<ObservationSubjectReport> get observationSubjectReports =>
      observationService.observationSubjectReports;

  fetchSubjectReports() {
    observationService.fetchAllObservationSubjectReports(subjectId);
  }
}
