import 'package:podd_app/locator.dart';
import 'package:podd_app/models/user_profile.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/notification_service.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends IndexTrackingViewModel {
  final INotificationService notificationService =
      locator<INotificationService>();
  IAuthService authService = locator<IAuthService>();

  UserProfile? get userProfile => authService.userProfile;

  String? get username => userProfile?.username;

  bool get isConsent => userProfile?.consent ?? false;

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
