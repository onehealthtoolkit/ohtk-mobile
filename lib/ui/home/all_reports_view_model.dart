import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:stacked/stacked.dart';

abstract class BaseReportViewModel {
  List<IncidentReport> get incidentReports;

  String resolveImagePath(String path);
}

class AllReportsViewModel extends ReactiveViewModel
    implements BaseReportViewModel {
  IReportService reportService = locator<IReportService>();

  @override
  List<IncidentReport> get incidentReports => reportService.incidentReports;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [reportService];

  @override
  resolveImagePath(String path) {
    return path;
  }

  Future<void> refetchIncidentReports() async {
    setBusy(true);
    await reportService.fetchIncidents(true);
    setBusy(false);
  }
}
