import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import '../fixtures/case_report.dart';

void main() {
  test('missing and malformed cached status parse as unknown', () {
    for (final value in [
      null,
      'old',
      {},
      {'isFinished': 'true'},
      {'isFinished': true}
    ]) {
      final json = caseReportJson()..['caseStatus'] = value;
      expect(
          IncidentReport.fromJson(json).caseStatus?.outcome ??
              ReportCaseOutcome.unknown,
          ReportCaseOutcome.unknown);
    }
    final json = caseReportJson()..remove('caseStatus');
    expect(IncidentReport.fromJson(json).caseStatus, isNull);
  });

  test('finish classification checks finished and source before outcome', () {
    final rows = [
      (false, 'officer', 'close_case', ReportCaseOutcome.open),
      (true, 'officer', 'close_case', ReportCaseOutcome.closed),
      (true, 'officer', 'false_positive', ReportCaseOutcome.falsePositive),
      (true, 'system', '', ReportCaseOutcome.automaticClose),
      (true, 'system', 'close_case', ReportCaseOutcome.automaticClose),
      (true, '', '', ReportCaseOutcome.unknown),
      (true, 'future', 'close_case', ReportCaseOutcome.unknown),
      (true, 'officer', 'future', ReportCaseOutcome.unknown),
    ];
    for (final row in rows) {
      expect(
          caseReport(status: caseStatusJson(row.$2, row.$3, finished: row.$1))
              .caseStatus!
              .outcome,
          row.$4,
          reason: row.toString());
    }
  });
}
