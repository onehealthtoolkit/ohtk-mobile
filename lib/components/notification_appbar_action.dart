import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/services/notification_service.dart';
import 'package:podd_app/ui/notification/user_message_list.dart';
import 'package:podd_app/ui/notification/user_message_view_model.dart';
import 'package:stacked/stacked.dart';

class NotificationAppBarAction extends StatelessWidget {
  final INotificationService notificationService =
      locator<INotificationService>();

  NotificationAppBarAction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => UserMessageListViewModel(),
      builder: (context, viewModel, child) => Stack(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
              ),
              tooltip: 'Messages',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserMessageList(),
                  ),
                );
              },
            ),
          ),
          // show notification badge
          Positioned(
            right: 6.w,
            top: 6.w,
            child: viewModel.hasUnseenMessages
                ? Container(
                    padding: const EdgeInsets.all(1),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 10.w,
                      minHeight: 10.w,
                    ),
                    child: Container(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
