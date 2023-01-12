import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/services/observation_service.dart';
import 'package:stacked/stacked.dart';

class ObservationSubjectListViewModel extends ReactiveViewModel {
  IObservationService observationService = locator<IObservationService>();

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
