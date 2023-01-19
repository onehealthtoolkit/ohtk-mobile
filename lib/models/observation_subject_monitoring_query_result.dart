import 'package:podd_app/models/entities/observation_subject_monitoring.dart';

class MonitoringRecordQueryResult {
  List<ObservationMonitoringRecord> data;

  MonitoringRecordQueryResult(this.data);

  factory MonitoringRecordQueryResult.fromJson(Map<String, dynamic> json) {
    return MonitoringRecordQueryResult(
      (json["results"] as List)
          .map((item) => ObservationMonitoringRecord.fromJson(item))
          .toList(),
    );
  }
}

class MonitoringRecordGetResult {
  ObservationMonitoringRecord data;

  MonitoringRecordGetResult({
    required this.data,
  });

  factory MonitoringRecordGetResult.fromJson(Map<String, dynamic> jsonMap) {
    return MonitoringRecordGetResult(
        data: ObservationMonitoringRecord.fromJson(jsonMap));
  }
}
