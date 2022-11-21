import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:podd_app/ui/home/all_reports_view.dart';
import 'package:podd_app/ui/home/consent_view.dart';
import 'package:podd_app/ui/home/home_view_model.dart';
import 'package:podd_app/ui/home/my_reports_view.dart';
import 'package:podd_app/ui/notification/user_message_list.dart';
import 'package:podd_app/ui/notification/user_message_view.dart';
import 'package:podd_app/ui/report_type/report_type_view.dart';
import 'package:podd_app/ui/resubmit/resubmit_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

import '../profile/profile_view.dart';

class HomeView extends HookWidget {
  const HomeView({Key? key}) : super(key: key);

  _viewUserMessage(BuildContext context, String userMessageId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserMessageView(id: userMessageId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TabController _tabController = useTabController(initialLength: 2);

    return ViewModelBuilder<HomeViewModel>.nonReactive(
      viewModelBuilder: () => HomeViewModel(),
      fireOnModelReadyOnce: true,
      onModelReady: (viewModel) {
        viewModel.setupFirebaseMessaging(onBackgroundMessage: (userMessageId) {
          _viewUserMessage(context, userMessageId);
        }, onForegroundMessage: (userMessageId) {
          showSimpleNotification(
            const Text("You've got a new message"),
            trailing: Builder(builder: (context) {
              return TextButton(
                onPressed: () {
                  OverlaySupportEntry.of(context)!.dismiss();
                  _viewUserMessage(context, userMessageId);
                },
                child: const Text(
                  'View message',
                  style: TextStyle(color: Colors.amber),
                ),
              );
            }),
            background: Colors.blueAccent.shade700,
            slideDismissDirection: DismissDirection.horizontal,
            duration: const Duration(seconds: 3),
          );
        });

        Timer.run(() {
          if (!viewModel.isConsent) {
            showGeneralDialog(
                context: context,
                barrierDismissible: false,
                barrierLabel:
                    MaterialLocalizations.of(context).modalBarrierDismissLabel,
                barrierColor: Colors.black45,
                transitionDuration: const Duration(milliseconds: 500),
                pageBuilder: (BuildContext buildContext,
                    Animation<double> animation, Animation secondaryAnimation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.95,
                          height: MediaQuery.of(context).size.height * 0.95,
                          padding: const EdgeInsets.all(20),
                          color: Colors.white,
                          child: const ConsentView(),
                        ),
                      ),
                    ),
                  );
                });
          }
        });
      },
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(child: Text(AppLocalizations.of(context)!.allReportTabLabel)),
              Tab(child: Text(AppLocalizations.of(context)!.myReportTabLabel)),
            ],
          ),
          title: Text(AppLocalizations.of(context)!.appName),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
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
            IconButton(
              icon: const Icon(Icons.account_circle),
              tooltip: 'Profile',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileView(),
                  ),
                );
              },
            ),
            // IconButton(
            //   icon: const Icon(Icons.logout),
            //   tooltip: 'Logout',
            //   onPressed: () {
            //     viewModel.logout();
            //   },
            // )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReportTypeView(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ReSubmitBlock(),
              Expanded(
                child: TabBarView(controller: _tabController, children: [
                  AllReportsView(),
                  MyReportsView(),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReSubmitBlock extends HookViewModelWidget<HomeViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.numberOfReportPendingToSubmit > 0) {
      return TextButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ReSubmitView(),
            ),
          );
        },
        child: Text(
            "${viewModel.numberOfReportPendingToSubmit} reports still pending to submit tap here to re-submit"),
      );
    }
    return Container();
  }
}
