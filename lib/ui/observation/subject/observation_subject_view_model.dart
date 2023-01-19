import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/services/observation_record_service.dart';
import 'package:stacked/stacked.dart';

class ObservationSubjectViewModel
    extends FutureViewModel<ObservationSubjectRecord> {
  IObservationRecordService observationService =
      locator<IObservationRecordService>();

  ObservationDefinition definition;
  ObservationSubjectRecord subject;

  ObservationSubjectViewModel(this.definition, this.subject);

  @override
  Future<ObservationSubjectRecord> futureToRun() {
    return observationService.getSubject(subject.id);
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
