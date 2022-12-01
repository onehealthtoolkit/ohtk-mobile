import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:stacked/stacked.dart';

class ReportHomeViewModel extends IndexTrackingViewModel {
  IReportService reportService = locator<IReportService>();

  int get numberOfReportPendingToSubmit => reportService.pendingReports.length;

  List<Report> get pendingReports => reportService.pendingReports;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [reportService];
}
