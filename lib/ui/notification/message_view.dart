import 'package:flutter/material.dart';
import 'package:podd_app/models/notification_message.dart';
import 'package:podd_app/ui/notification/message_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class MessageView extends StatelessWidget {
  final NotificationMessage message;
  const MessageView({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MessageViewModel>.nonReactive(
      viewModelBuilder: () => MessageViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Messages"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(message.id),
              Text(message.title),
              Text(message.message),
            ],
          ),
        ),
      ),
    );
  }
}
