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
      builder: (context, viewModel, child) {
        var navigationBarItems = [
          const BottomNavigationBarItem(
            label: 'Incidents',
            icon: Icon(Icons.art_track),
          ),
          if (viewModel.hasObservationFeature)
            const BottomNavigationBarItem(
              label: 'Observations',
              icon: Icon(Icons.format_list_bulleted),
            ),
          const BottomNavigationBarItem(
            label: 'Profile',
            icon: Icon(Icons.account_circle),
          ),
        ];

        return Scaffold(
          appBar: AppBar(
            elevation: viewModel.numberOfPendingSubmissions > 0 ? 0 : 1,
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
            bottom: PreferredSize(
              preferredSize: viewModel.numberOfPendingSubmissions > 0
                  ? const Size.fromHeight(kToolbarHeight * .6)
                  : Size.zero,
              child: _ReSubmitBlock(),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: viewModel.currentIndex,
            onTap: viewModel.setIndex,
            items: navigationBarItems,
          ),
          body: getViewForIndex(viewModel),
        );
      },
    );
  }

  Widget getViewForIndex(HomeViewModel viewModel) {
    int index = viewModel.currentIndex;
    if (index == 0) {
      return ReportHomeView();
    } else if (index == 1) {
      if (viewModel.hasObservationFeature) {
        return const ObservationHomeView();
      } else {
        return const ProfileView();
      }
    } else if (index == 2) {
      return const ProfileView();
    } else {
      return ReportHomeView();
    }
  }
}

class _ReSubmitBlock extends HookViewModelWidget<HomeViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, HomeViewModel viewModel) {
    return viewModel.numberOfPendingSubmissions > 0
        ? Container(
            width: double.infinity,
            height: kToolbarHeight * .6,
            color: Colors.white,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ReSubmitView(),
                  ),
                );
              },
              child: Text(viewModel.numberOfPendingSubmissions.toString() +
                  " pending submission${viewModel.numberOfPendingSubmissions > 1 ? 's' : ''}," +
                  " tap here to re-submit"),
            ),
          )
        : const SizedBox.shrink();
  }
}
