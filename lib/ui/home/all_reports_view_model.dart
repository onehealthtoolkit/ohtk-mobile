import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:stacked/stacked.dart';

class AllReportsViewModel extends ReactiveViewModel {
  IReportService reportService = locator<IReportService>();

  List<IncidentReport> get incidentReports => reportService.incidentReports;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [reportService];

  resolveImagePath(String path) {
    return path;
  }

  Future<void> refetchIncidentReports() async {
    setBusy(true);
    await reportService.fetchIncidents(true);
    setBusy(false);
  }
}
