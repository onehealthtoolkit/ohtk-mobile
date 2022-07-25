import 'package:podd_app/models/entities/incident_report.dart';

class IncidentReportQueryResult {
  List<IncidentReport> data;
  bool hasNextPage;

  IncidentReportQueryResult(this.data, this.hasNextPage);

  factory IncidentReportQueryResult.fromJson(Map<String, dynamic> json) {
    return IncidentReportQueryResult(
      (json["results"] as List)
          .map((item) => IncidentReport.fromJson(item))
          .toList(),
      (json["pageInfo"] as Map)["hasNextPage"],
    );
  }
}

class IncidentReportGetResult {
  IncidentReport data;

  IncidentReportGetResult({
    required this.data,
  });

  factory IncidentReportGetResult.fromJson(Map<String, dynamic> jsonMap) {
    return IncidentReportGetResult(data: IncidentReport.fromJson(jsonMap));
  }
}
