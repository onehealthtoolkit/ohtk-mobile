import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/services/observation_definition_service.dart';
import 'package:podd_app/services/observation_record_service.dart';
import 'package:stacked/stacked.dart';

class ObservationViewModel extends BaseViewModel {
  IObservationRecordService observationService =
      locator<IObservationRecordService>();
  IObservationDefinitionService observationDefinitionService =
      locator<IObservationDefinitionService>();

  String definitionId;
  ObservationDefinition? definition;

  ObservationViewModel(this.definitionId) {
    setBusy(true);
    getObservationDefinition();
  }

  getObservationDefinition() async {
    var id = int.parse(definitionId);
    definition =
        await observationDefinitionService.getObservationDefinition(id);
    if (definition != null) {
      fetchObservationSubjects();
    }
  }

  Future<void> fetchObservationSubjects() async {
    await observationService.fetchAllSubjectRecords(true, definition!.id);
    setBusy(false);
  }
}
