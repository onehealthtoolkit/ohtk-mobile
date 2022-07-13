import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/notification_message.dart';
import 'package:stacked/stacked.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

typedef NotificationMessageCallback = void Function(NotificationMessage);

abstract class INotificationService with ReactiveServiceMixin {
  final _logger = locator<Logger>();

  List<NotificationMessage> get messages;
}

class NotificationService extends INotificationService {
  final ReactiveList<NotificationMessage> _messages =
      ReactiveList<NotificationMessage>();

  NotificationService() {
    listenToReactiveValues([_messages]);
    _init();
  }

  _init() async {
    // TODO register fcm token to server
    final fcmToken = await FirebaseMessaging.instance.getToken();
    _logger.d("fcm token: " + (fcmToken ?? "???"));

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      // TODO: If necessary send token to application server.

      // Note: This callback is fired at each app startup and whenever a new
      // token is generated.
      print("fcm token refresh: " + fcmToken);
    }).onError((err) {
      // Error getting token.
      throw Exception(err);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // app is already in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.i("Notification message received whilst in the foreground");
      if (message.messageId != null && message.notification != null) {
        _messages.add(NotificationMessage.fromRemoteNotification(
            message.messageId!, message.notification!));
      }
    });
  }

  @override
  List<NotificationMessage> get messages => _messages;
}
