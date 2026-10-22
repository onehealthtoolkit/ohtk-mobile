import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/ui/report/incident_report_view_model.dart';
import '../fixtures/case_report.dart';
import '../fixtures/report_services.dart';

void main() {
  tearDown(() async => locator.reset());
  for (final row in [
    ('officer', 'close_case', ReportCaseOutcome.closed),
    ('officer', 'false_positive', ReportCaseOutcome.falsePositive),
    ('system', '', ReportCaseOutcome.automaticClose),
    ('system', 'close_case', ReportCaseOutcome.automaticClose),
  ]) {
    test(
        'successful detail ${row.$1}/${row.$2} updates both loaded lists without insert/reorder',
        () async {
      final (api, service) = registerReportServices();
      service.incidentReports.addAll([caseReport(id: 'other'), caseReport()]);
      service.myIncidentReports
          .addAll([caseReport(), caseReport(id: 'mine-other')]);
      api.nextReport = caseReport(status: caseStatusJson(row.$1, row.$2));
      var notifications = 0;
      service.addListener(() => notifications++);
      final result = await IncidentReportViewModel('report-1').futureToRun();
      expect(result.caseStatus!.outcome, row.$3);
      expect(service.incidentReports.map((r) => r.id), ['other', 'report-1']);
      expect(service.myIncidentReports.map((r) => r.id),
          ['report-1', 'mine-other']);
      expect(service.incidentReports.last.caseStatus!.outcome, row.$3);
      expect(service.myIncidentReports.first.caseStatus!.outcome, row.$3);
      await Future<void>.delayed(Duration.zero);
      expect(notifications, greaterThan(0));
      service.updateLoadedIncident(caseReport(id: 'not-loaded'));
      expect(service.incidentReports, hasLength(2));
      expect(service.myIncidentReports, hasLength(2));
    });

    test('successful reload applies ${row.$1}/${row.$2} to both lists',
        () async {
      final (api, service) = registerReportServices();
      service.incidentReports.add(caseReport());
      service.myIncidentReports.add(caseReport());
      api.nextReport = caseReport(status: caseStatusJson(row.$1, row.$2));
      await service.fetchIncidents(true);
      await service.fetchMyIncidents(true);
      expect(service.incidentReports.single.caseStatus!.outcome, row.$3);
      expect(service.myIncidentReports.single.caseStatus!.outcome, row.$3);
    });
  }

  test('failed detail and list loads preserve last known finish state',
      () async {
    final (api, service) = registerReportServices();
    final known = caseReport(status: caseStatusJson('officer', 'close_case'));
    service.incidentReports.add(known);
    service.myIncidentReports.add(known);
    api.error = StateError('network failed');
    await expectLater(
        IncidentReportViewModel('report-1').futureToRun(), throwsStateError);
    await expectLater(service.fetchIncidents(true), throwsStateError);
    await expectLater(service.fetchMyIncidents(true), throwsStateError);
    expect(service.incidentReports.single, same(known));
    expect(service.myIncidentReports.single, same(known));
  });
}
