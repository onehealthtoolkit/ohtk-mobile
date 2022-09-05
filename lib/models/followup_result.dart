import 'package:podd_app/models/entities/followup_report.dart';

class FollowupQueryResult {
  List<FollowupReport> data;

  FollowupQueryResult(this.data);
}

class FollowupReportGetResult {
  FollowupReport data;

  FollowupReportGetResult({
    required this.data,
  });

  factory FollowupReportGetResult.fromJson(Map<String, dynamic> jsonMap) {
    return FollowupReportGetResult(data: FollowupReport.fromJson(jsonMap));
  }
}
