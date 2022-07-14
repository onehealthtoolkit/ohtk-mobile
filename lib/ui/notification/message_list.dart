import 'package:flutter/material.dart';
import 'package:podd_app/ui/notification/message_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class MessageList extends StatelessWidget {
  const MessageList({Key? key}) : super(key: key);

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
              Expanded(
                child: _MessageList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageList extends HookViewModelWidget<MessageViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, MessageViewModel viewModel) {
    return ListView.builder(
      itemCount: viewModel.messages.length,
      itemBuilder: (context, index) {
        var message = viewModel.messages[index];

        return ListTile(
          title: Text(message.title,
              style: TextStyle(
                  color: message.isRead ? Colors.grey.shade600 : Colors.black)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.message,
                textScaleFactor: .75,
              ),
            ],
          ),
        );
      },
    );
  }
}
