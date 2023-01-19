import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/services/observation_record_service.dart';
import 'package:stacked/stacked.dart';

class ObservationSubjectListViewModel extends ReactiveViewModel {
  IObservationRecordService observationService =
      locator<IObservationRecordService>();

  ObservationDefinition definition;

  ObservationSubjectListViewModel(this.definition);

  @override
  List<ReactiveServiceMixin> get reactiveServices => [observationService];

  List<ObservationSubjectRecord> get observationSubjects =>
      observationService.subjectRecords;

  refetchSubjects() {
    observationService.fetchAllSubjectRecords(false, definition.id);
  }
}
