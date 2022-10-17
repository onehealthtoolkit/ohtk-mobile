import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _UserMessageList(),
        ),
      ),
    );
  }
}

class _UserMessageList extends HookViewModelWidget<UserMessageListViewModel> {
  final formatter = DateFormat("dd/MM/yyyy HH:mm");

  @override
  Widget buildViewModelWidget(
      BuildContext context, UserMessageListViewModel viewModel) {
    return viewModel.isBusy
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: viewModel.userMessages.length,
            itemBuilder: (context, index) {
              var userMessage = viewModel.userMessages[index];

              return Card(
                shadowColor: Colors.transparent,
                child: ListTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserMessageView(id: userMessage.id),
                    ),
                  ),
                  title: Text(
                    userMessage.message.title,
                    style: const TextStyle(color: Colors.black),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatter.format(userMessage.createdAt.toLocal()),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              );
            },
          );
  }
}
