import 'package:flutter/material.dart';
import 'package:podd_app/ui/notification/user_message_view_model.dart';
import 'package:podd_app/ui/notification/user_message_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class UserMessageList extends StatelessWidget {
  const UserMessageList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<UserMessageListViewModel>.nonReactive(
      viewModelBuilder: () => UserMessageListViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Messages"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _UserMessageList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserMessageList extends HookViewModelWidget<UserMessageListViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, UserMessageListViewModel viewModel) {
    return ListView.builder(
      itemCount: viewModel.userMessages.length,
      itemBuilder: (context, index) {
        var userMessage = viewModel.userMessages[index];

        return ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserMessageView(id: userMessage.id),
            ),
          ),
          title: Text(userMessage.message.title,
              style: TextStyle(
                  color: userMessage.isSeen
                      ? Colors.grey.shade600
                      : Colors.black)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userMessage.message.body),
            ],
          ),
        );
      },
    );
  }
}
