import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/services/observation_definition_service.dart';
import 'package:stacked/stacked.dart';

class ObservationHomeViewModel extends BaseViewModel {
  final IObservationDefinitionService _definitonService =
      locator<IObservationDefinitionService>();

  List<ObservationDefinition> observationDefinitions = [];

  ObservationHomeViewModel() {
    setBusy(true);
    fetch();
  }

  fetch() async {
    observationDefinitions =
        await _definitonService.fetchAllObservationDefinitions();
    setBusy(false);
  }

  syncDefinitions() async {
    setBusy(true);
    await _definitonService.sync();
    await fetch();
    setBusy(false);
  }
}
