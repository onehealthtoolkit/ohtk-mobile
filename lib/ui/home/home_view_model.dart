import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/models/entities/report.dart';
import 'package:podd_app/models/user_profile.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/config_service.dart';
import 'package:podd_app/services/notification_service.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends IndexTrackingViewModel {
  final INotificationService notificationService =
      locator<INotificationService>();
  IAuthService authService = locator<IAuthService>();
  IReportService reportService = locator<IReportService>();
  ConfigService configService = locator<ConfigService>();
  UserProfile? get userProfile => authService.userProfile;

  int get numberOfReportPendingToSubmit => reportService.pendingReports.length;

  List<Report> get pendingReports => reportService.pendingReports;

  logout() {
    authService.logout();
  }

  String? get username => userProfile?.username;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [reportService];

  setupFirebaseMessaging({
    NotificationMessageCallback? onBackgroundMessage,
    NotificationMessageCallback? onForegroundMessage,
  }) {
    if (userProfile != null) {
      notificationService.setupFirebaseMessaging(
        userProfile!.id.toString(),
        onInitialMessage: onBackgroundMessage,
        onMessageOpenedApp: onBackgroundMessage,
        onForegroundMessage: onForegroundMessage,
      );
    }
  }
}
