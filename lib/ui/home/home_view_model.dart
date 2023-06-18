import 'package:podd_app/locator.dart';
import 'package:podd_app/models/user_profile.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/file_service.dart';
import 'package:podd_app/services/image_service.dart';
import 'package:podd_app/services/notification_service.dart';
import 'package:podd_app/services/observation_record_service.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends IndexTrackingViewModel {
  final INotificationService notificationService =
      locator<INotificationService>();
  IAuthService authService = locator<IAuthService>();
  IReportService reportService = locator<IReportService>();
  IObservationRecordService recordService =
      locator<IObservationRecordService>();
  IImageService imageService = locator<IImageService>();
  IFileService fileService = locator<IFileService>();

  List get pendingReports => reportService.pendingReports;
  List get pendingSubjectRecords => recordService.pendingSubjectRecords;
  List get pendingMonitoringRecords => recordService.pendingMonitoringRecords;
  List get pendingImages => imageService.pendingImages;
  List get pendingFiles => fileService.pendingReportFiles;

  int get numberOfPendingSubmissions =>
      pendingReports.length +
      pendingSubjectRecords.length +
      pendingMonitoringRecords.length +
      pendingImages.length +
      pendingFiles.length;

  @override
  List<ReactiveServiceMixin> get reactiveServices =>
      [reportService, recordService, imageService, fileService];

  UserProfile? get userProfile => authService.userProfile;

  String? get username => userProfile?.username;

  bool get isConsent => userProfile?.consent ?? false;

  bool get hasObservationFeature =>
      userProfile?.hasFeatureEnabled("observation") ?? false;

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
