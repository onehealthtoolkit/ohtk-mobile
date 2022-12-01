import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:podd_app/ui/home/consent_view.dart';
import 'package:podd_app/ui/home/home_view_model.dart';
import 'package:podd_app/ui/home/observation/observation_home_view.dart';
import 'package:podd_app/ui/home/report_home_view.dart';
import 'package:podd_app/ui/notification/user_message_list.dart';
import 'package:podd_app/ui/notification/user_message_view.dart';
import 'package:stacked/stacked.dart';

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
    return ViewModelBuilder<HomeViewModel>.reactive(
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
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          width: MediaQuery.of(context).size.width * 0.95,
                          height: MediaQuery.of(context).size.height * 0.95,
                          padding: const EdgeInsets.all(20),
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
          elevation: 1,
          centerTitle: true,
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
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue[700],
          currentIndex: viewModel.currentIndex,
          onTap: viewModel.setIndex,
          items: const [
            BottomNavigationBarItem(
              label: 'Incidents',
              icon: Icon(Icons.art_track),
            ),
            BottomNavigationBarItem(
              label: 'Observation',
              icon: Icon(Icons.search),
            ),
            BottomNavigationBarItem(
              label: 'Profile',
              icon: Icon(Icons.account_circle),
            ),
          ],
        ),
        body: getViewForIndex(viewModel.currentIndex),
      ),
    );
  }

  Widget getViewForIndex(int index) {
    switch (index) {
      case 0:
        return const ReportHomeView();
      case 1:
        return const ObservationHomeView();
      case 2:
        return const ProfileView();
      default:
        return const ReportHomeView();
    }
  }
}
