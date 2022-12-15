import 'package:podd_app/models/entities/observation_subject_monitoring.dart';

class ObservationSubjectMonitoringQueryResult {
  List<ObservationSubjectMonitoring> data;

  ObservationSubjectMonitoringQueryResult(this.data);

  factory ObservationSubjectMonitoringQueryResult.fromJson(
      Map<String, dynamic> json) {
    return ObservationSubjectMonitoringQueryResult(
      (json["results"] as List)
          .map((item) => ObservationSubjectMonitoring.fromJson(item))
          .toList(),
    );
  }
}

class ObservationSubjectMonitoringGetResult {
  ObservationSubjectMonitoring data;

  ObservationSubjectMonitoringGetResult({
    required this.data,
  });

  factory ObservationSubjectMonitoringGetResult.fromJson(
      Map<String, dynamic> jsonMap) {
    return ObservationSubjectMonitoringGetResult(
        data: ObservationSubjectMonitoring.fromJson(jsonMap));
  }
}
