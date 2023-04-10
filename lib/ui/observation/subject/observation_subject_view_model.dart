import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/services/observation_definition_service.dart';
import 'package:podd_app/services/observation_record_service.dart';
import 'package:stacked/stacked.dart';

class ObservationSubjectViewModel
    extends FutureViewModel<ObservationSubjectRecord> {
  IObservationRecordService observationService =
      locator<IObservationRecordService>();
  IObservationDefinitionService observationDefinitionService =
      locator<IObservationDefinitionService>();

  String definitionId;
  String subjectId;

  ObservationSubjectViewModel(this.definitionId, this.subjectId);

  @override
  Future<ObservationSubjectRecord> futureToRun() {
    var id = int.parse(definitionId);
    return observationDefinitionService.getObservationDefinition(id).then(
      (definition) async {
        if (definition != null) {
          var subject = await observationService.getSubject(subjectId);
          subject.definition = definition;
          return subject;
        }
        throw Exception('Definition not found');
      },
    );
  }

  List<double>? get latlng {
    List<double>? latlng;
    var location = data?.gpsLocation;
    if (location != null) {
      if (location.isNotEmpty) {
        var lnglat = data!.gpsLocation!.split(",");
        latlng = [double.parse(lnglat[1]), double.parse(lnglat[0])];
      }
    }
    return latlng;
  }
}
