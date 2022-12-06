import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/services/observation_service.dart';
import 'package:stacked/stacked.dart';

class ObservationSubjectListViewModel extends ReactiveViewModel {
  IObservationService observationService = locator<IObservationService>();

  String definitionId;

  ObservationSubjectListViewModel(this.definitionId);

  @override
  List<ReactiveServiceMixin> get reactiveServices => [observationService];

  List<ObservationSubject> get observationSubjects =>
      observationService.observationSubjects;

  refetchSubjects() {
    observationService.fetchAllObservationSubjects(false, definitionId);
  }
}
