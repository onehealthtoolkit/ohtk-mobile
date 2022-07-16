import 'package:flutter/material.dart';
import 'package:podd_app/ui/notification/user_message_view_model.dart';
import 'package:stacked/stacked.dart';

class UserMessageView extends StatelessWidget {
  final String id;
  const UserMessageView({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<UserMessageViewViewModel>.reactive(
      viewModelBuilder: () => UserMessageViewViewModel(id),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Message detail"),
        ),
        body: Center(
          child: viewModel.isBusy
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: !viewModel.hasError
                      ? [
                          Text(viewModel.data!.id),
                          Text(viewModel.data!.message.title),
                          Text(viewModel.data!.message.body),
                        ]
                      : [
                          const Text("Message not found"),
                        ],
                ),
        ),
      ),
    );
  }
}
