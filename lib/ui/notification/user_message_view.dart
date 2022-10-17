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
          title: const Text("Message"),
        ),
        body: viewModel.isBusy
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: !viewModel.hasError
                      ? [
                          _title(viewModel),
                          const SizedBox(height: 10),
                          _body(viewModel),
                        ]
                      : [
                          const Text("Message not found"),
                        ],
                ),
              ),
      ),
    );
  }

  _title(UserMessageViewViewModel viewModel) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: double.infinity,
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Text(
        viewModel.data!.message.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  _body(UserMessageViewViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 10),
      constraints:
          const BoxConstraints(minWidth: double.infinity, minHeight: 100),
      child: Card(
        shadowColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            viewModel.data!.message.body,
          ),
        ),
      ),
    );
  }
}
