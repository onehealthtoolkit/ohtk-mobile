import 'package:podd_app/models/entities/observation_subject_report.dart';

class ObservationSubjectReportQueryResult {
  List<ObservationSubjectReport> data;

  ObservationSubjectReportQueryResult(this.data);

  factory ObservationSubjectReportQueryResult.fromJson(
      Map<String, dynamic> json) {
    return ObservationSubjectReportQueryResult(
      (json["results"] as List)
          .map((item) => ObservationSubjectReport.fromJson(item))
          .toList(),
    );
  }
}

class ObservationSubjectReportGetResult {
  ObservationSubjectReport data;

  ObservationSubjectReportGetResult({
    required this.data,
  });

  factory ObservationSubjectReportGetResult.fromJson(
      Map<String, dynamic> jsonMap) {
    return ObservationSubjectReportGetResult(
        data: ObservationSubjectReport.fromJson(jsonMap));
  }
}
