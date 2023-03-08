import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/locator.dart';
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
  final AppTheme appTheme = locator<AppTheme>();

  @override
  Widget buildViewModelWidget(
      BuildContext context, UserMessageListViewModel viewModel) {
    return viewModel.isBusy
        ? const Center(child: OhtkProgressIndicator(size: 100))
        : ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(height: 4),
            itemCount: viewModel.userMessages.length,
            itemBuilder: (context, index) {
              var userMessage = viewModel.userMessages[index];
              return InkWell(
                onTap: () {
                  viewModel.markSeen(userMessage);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserMessageView(id: userMessage.id),
                    ),
                  );
                },
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.all(6),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: -5,
                        top: -5,
                        child: !userMessage.isSeen
                            ? Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(""),
                              )
                            : Container(),
                      ),
                      Positioned.fill(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: userMessage.isSeen
                                  ? appTheme.sub2
                                  : Colors.red,
                            ),
                            borderRadius: BorderRadius.circular(
                              appTheme.borderRadius,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatter
                                    .format(userMessage.createdAt.toLocal()),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(color: appTheme.sub2),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userMessage.message.title,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
