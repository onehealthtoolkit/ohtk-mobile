import 'package:podd_app/models/entities/report.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:stacked/stacked.dart';

import 'package:podd_app/locator.dart';

class ReSubmitViewModel extends ReactiveViewModel {
  final IReportService _reportService = locator<IReportService>();

  List<Report> get pendingReports => _reportService.pendingReports;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_reportService];

  void submit() async {
    await _reportService.submitAllPendingReport();
  }
}
