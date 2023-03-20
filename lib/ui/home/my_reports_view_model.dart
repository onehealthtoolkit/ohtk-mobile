import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:podd_app/services/report_type_service.dart';
import 'package:stacked/stacked.dart';

import 'all_reports_view_model.dart';

class MyReportsViewModel extends ReactiveViewModel
    implements BaseReportViewModel {
  IReportTypeService reportTypeService = locator<IReportTypeService>();
  IReportService reportService = locator<IReportService>();

  final List<ReportType> _reportTypes = [];

  @override
  List<IncidentReport> get incidentReports => reportService.myIncidentReports;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [reportService];

  MyReportsViewModel() {
    reportTypeService.addListener(() {
      if (reportTypeService.isReportTypeSynced) {
        refetchReportTypes();
      }
    });
  }

  @override
  resolveImagePath(String path) {
    return path;
  }

  Future<void> refetchIncidentReports() async {
    setBusy(true);
    await reportService.fetchMyIncidents(true);
    setBusy(false);
  }

  Future<void> refetchReportTypes() async {
    final items = await reportTypeService.fetchAllReportType();
    _reportTypes.clear();
    _reportTypes.addAll(items);
  }

  bool canFollow(String reportTypeId) {
    final reportType = getReportType(reportTypeId);
    return reportType != null && reportType.followupEnable;
  }

  ReportType? getReportType(String id) {
    ReportType? result;
    try {
      result = _reportTypes.firstWhere((it) => it.id == id);
      // ignore: empty_catches
    } catch (e) {}
    return result;
  }
}
