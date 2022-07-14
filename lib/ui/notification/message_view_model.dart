import 'package:podd_app/locator.dart';
import 'package:podd_app/models/notification_message.dart';
import 'package:podd_app/services/notification_service.dart';
import 'package:stacked/stacked.dart';

class MessageViewModel extends ReactiveViewModel {
  INotificationService notificationService = locator<INotificationService>();

  @override
  List<ReactiveServiceMixin> get reactiveServices => [notificationService];

  List<NotificationMessage> get messages => notificationService.messages;
}
