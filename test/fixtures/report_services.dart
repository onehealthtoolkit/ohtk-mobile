import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/models/followup_result.dart';
import 'package:podd_app/models/incident_report_query_result.dart';
import 'package:podd_app/services/api/report_api.dart';
import 'package:podd_app/services/config_service.dart';
import 'package:podd_app/services/db_service.dart';
import 'package:podd_app/services/file_service.dart';
import 'package:podd_app/services/image_service.dart';
import 'package:podd_app/services/report_service.dart';
import 'case_report.dart';

class LoadedReportApi extends Fake implements ReportApi {
  IncidentReport nextReport = caseReport();
  Object? error;
  @override
  Future<IncidentReportGetResult> getIncidentReport(String id) async {
    if (error != null) throw error!;
    return IncidentReportGetResult(data: nextReport);
  }

  @override
  Future<IncidentReportQueryResult> fetchIncidentReports(
      {limit = 20, offset = 0, resetFlag = false}) async {
    if (error != null) throw error!;
    return IncidentReportQueryResult([nextReport], false);
  }

  @override
  Future<IncidentReportQueryResult> fetchMyIncidentReports(
          {limit = 20, offset = 0, resetFlag = false}) =>
      fetchIncidentReports(limit: limit, offset: offset, resetFlag: resetFlag);
  @override
  Future<FollowupQueryResult> fetchFollowupReports(String incidentId) async =>
      FollowupQueryResult([]);
}

class _Images extends Fake implements IImageService {}

class _Files extends Fake implements IFileService {}

class _Database extends Fake implements IDbService {}

(LoadedReportApi, ReportService) registerReportServices() {
  locator.registerSingleton<Logger>(Logger(level: Level.off));
  final api = LoadedReportApi();
  locator.registerSingleton<ReportApi>(api);
  locator.registerSingleton<IImageService>(_Images());
  locator.registerSingleton<IFileService>(_Files());
  locator.registerSingleton<IDbService>(_Database());
  locator.registerSingleton<ConfigService>(ConfigService());
  final service = ReportService();
  locator.registerSingleton<IReportService>(service);
  return (api, service);
}
