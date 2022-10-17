import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/user_message.dart';
import 'package:podd_app/services/notification_service.dart';
import 'package:stacked/stacked.dart';

class UserMessageListViewModel extends ReactiveViewModel {
  INotificationService notificationService = locator<INotificationService>();

  UserMessageListViewModel() {
    fetch();
  }

  fetch() async {
    setBusy(true);
    await notificationService.fetchMyMessages(true);
    setBusy(false);
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [notificationService];

  List<UserMessage> get userMessages => notificationService.userMessages;
}

class UserMessageViewViewModel extends FutureViewModel<UserMessage> {
  INotificationService notificationService = locator<INotificationService>();
  String id;

  UserMessageViewViewModel(this.id);

  @override
  Future<UserMessage> futureToRun() => notificationService.getMyMessage(id);
}
