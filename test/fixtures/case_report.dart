import 'package:podd_app/models/entities/incident_report.dart';

Map<String, dynamic> caseReportJson({
  String id = 'report-1',
  String? caseId = 'case-1',
  Map<String, dynamic>? status,
}) =>
    {
      '__typename': 'IncidentReportType',
      'id': id,
      'incidentDate': '2026-10-22',
      'rendererData': 'Sick animal',
      'createdAt': '2026-10-22T08:00:00Z',
      'updatedAt': '2026-10-22T08:00:00Z',
      'gpsLocation': null,
      'reportType': {
        '__typename': 'ReportTypeType',
        'id': 'type-1',
        'name': 'Animal Sick/Death',
        'isFollowable': false
      },
      'reportedBy': {
        '__typename': 'UserType',
        'id': 'user-1',
        'username': 'vvw'
      },
      'images': <dynamic>[],
      'uploadFiles': <dynamic>[],
      'caseId': caseId,
      'caseStatus': status,
      'threadId': 1,
      'testFlag': false,
      'authorities': <dynamic>[],
      'accumulatedMetrics': null,
    };

Map<String, dynamic> caseStatusJson(String source, String outcome,
        {bool finished = true}) =>
    {
      '__typename': 'ReportCaseStatus',
      'isFinished': finished,
      'closeSource': source,
      'closeOutcome': outcome,
    };

IncidentReport caseReport(
        {String id = 'report-1',
        String? caseId = 'case-1',
        Map<String, dynamic>? status}) =>
    IncidentReport.fromJson(
        caseReportJson(id: id, caseId: caseId, status: status));
