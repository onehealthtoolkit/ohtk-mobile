import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/services/observation_service.dart';
import 'package:stacked/stacked.dart';

class ObservationSubjectViewModel extends FutureViewModel<ObservationSubject> {
  IObservationService observationService = locator<IObservationService>();

  String id;

  ObservationSubjectViewModel(this.id);

  @override
  Future<ObservationSubject> futureToRun() {
    return observationService.getObservationSubject(id);
  }
}
