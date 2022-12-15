import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/services/observation_service.dart';
import 'package:stacked/stacked.dart';

class ObservationHomeViewModel extends BaseViewModel {
  final IObservationService _observationService =
      locator<IObservationService>();

  List<ObservationDefinition> observationDefinitions = [];

  ObservationHomeViewModel() {
    setBusy(true);
    fetch();
  }

  fetch() async {
    observationDefinitions =
        await _observationService.fetchAllObservationDefinitions();
    setBusy(false);
  }
}
