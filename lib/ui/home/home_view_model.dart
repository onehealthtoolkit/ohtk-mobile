import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report.dart';
import 'package:podd_app/models/user_profile.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends ReactiveViewModel {
  IAuthService authService = locator<IAuthService>();
  IReportService reportService = locator<IReportService>();
  UserProfile? get userProfile => authService.userProfile;

  int get numberOfReportPendingToSubmit => reportService.pendingReports.length;

  List<Report> get pendingReports => reportService.pendingReports;

  logout() {
    authService.logout();
  }

  String? get username => userProfile?.username;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [reportService];
}
