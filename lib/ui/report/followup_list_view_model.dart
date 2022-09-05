import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/followup_report.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:stacked/stacked.dart';

class FollowupListViewModel extends ReactiveViewModel {
  IReportService reportService = locator<IReportService>();

  List<FollowupReport> get followupReport => reportService.followupReports;
  String incidentId;

  FollowupListViewModel(this.incidentId) {
    refetchFollowups();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [reportService];

  resolveImagePath(String path) {
    return path;
  }

  Future<void> refetchFollowups() async {
    setBusy(true);
    await reportService.fetchFollowups(incidentId);
    setBusy(false);
  }
}
