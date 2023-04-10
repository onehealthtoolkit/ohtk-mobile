import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/services/observation_record_service.dart';
import 'package:stacked/stacked.dart';

class ObservationMonitoringRecordViewModel
    extends FutureViewModel<ObservationMonitoringRecord> {
  IObservationRecordService observationService =
      locator<IObservationRecordService>();

  String monitoringRecordId;

  ObservationMonitoringRecordViewModel({
    required this.monitoringRecordId,
  });

  @override
  Future<ObservationMonitoringRecord> futureToRun() {
    return observationService.getMonitoringRecord(monitoringRecordId);
  }
}
