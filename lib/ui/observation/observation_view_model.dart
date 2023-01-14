import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/services/observation_record_service.dart';
import 'package:stacked/stacked.dart';

class ObservationViewModel extends BaseViewModel {
  IObservationRecordService observationService =
      locator<IObservationRecordService>();

  ObservationDefinition definition;

  ObservationViewModel(this.definition) {
    setBusy(true);
    fetchObservationSubjects();
  }

  Future<void> fetchObservationSubjects() async {
    await observationService.fetchAllSubjectRecords(true, definition.id);
    setBusy(false);
  }
}
