import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationMessage {
  String id;
  String title;
  String message;
  bool isRead = false;

  NotificationMessage({
    required this.id,
    required this.title,
    required this.message,
  });

  NotificationMessage.fromRemoteNotification(
      String messageId, RemoteNotification notification)
      : id = messageId,
        title = notification.title ?? "",
        message = notification.body ?? "";
}
