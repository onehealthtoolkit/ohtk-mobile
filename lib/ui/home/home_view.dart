import 'dart:async';

import 'package:flutter/material.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:podd_app/components/notification_appbar_action.dart';
import 'package:podd_app/components/test_id.dart';
import 'package:podd_app/ui/home/consent_view.dart';
import 'package:podd_app/ui/home/home_view_model.dart';
import 'package:podd_app/ui/notification/user_message_view.dart';
import 'package:podd_app/ui/resubmit/resubmit_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

// todo: refactor ให้รับ parameter ในการแสดง navigationBarItems จากคนเรียกใช้
// เพื่อลดการ switch, if ช่วงบรรทัด 143-178

class HomeView extends HookWidget {
  final Widget child;

  const HomeView({Key? key, required this.child}) : super(key: key);

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
      fireOnViewModelReadyOnce: true,
      onViewModelReady: (viewModel) {
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
      builder: (context, viewModel, _) {
        var navigationBarItems = [
          BottomNavigationBarItem(
            label:
                AppLocalizations.of(context)?.incidentsTabTitle ?? 'Incidents',
            icon: const TestId(
              id: 'home.nav.incidents_tab',
              button: true,
              child: Icon(Icons.art_track),
            ),
          ),
          if (viewModel.hasObservationFeature)
            BottomNavigationBarItem(
              label: AppLocalizations.of(context)?.observationsTabTitle ??
                  'Observations',
              icon: const TestId(
                id: 'home.nav.observations_tab',
                button: true,
                child: Icon(Icons.format_list_bulleted),
              ),
            ),
          if (viewModel.hasAnimalCensusFeature)
            const BottomNavigationBarItem(
              label: 'Census',
              icon: TestId(
                id: 'home.nav.census_tab',
                button: true,
                child: Icon(Icons.fact_check_outlined),
              ),
            ),
          BottomNavigationBarItem(
            label: AppLocalizations.of(context)?.profileTabTitle ?? 'Profile',
            icon: const TestId(
              id: 'home.nav.profile_tab',
              button: true,
              child: Icon(Icons.account_circle),
            ),
          ),
        ];

        return Scaffold(
          appBar: AppBar(
            elevation: viewModel.numberOfPendingSubmissions > 0 ? 0 : 1,
            centerTitle: true,
            title: Text(AppLocalizations.of(context)!.appName),
            actions: [
              NotificationAppBarAction(),
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
            currentIndex: _calculateSelectedIndex(context, viewModel),
            onTap: (int index) => _onItemTapped(index, context, viewModel),
            items: navigationBarItems,
          ),
          body: child,
        );
      },
    );
  }

  static int _calculateSelectedIndex(
      BuildContext context, HomeViewModel viewModel) {
    try {
      final String location = GoRouterState.of(context).uri.path;
      if (location.startsWith('/reports')) {
        return 0;
      }
      if (location.startsWith('/observations') &&
          viewModel.hasObservationFeature) {
        return 1;
      }
      if (location.startsWith('/census') && viewModel.hasAnimalCensusFeature) {
        return viewModel.hasObservationFeature ? 2 : 1;
      }
      if (location.startsWith('/profile')) {
        return 1 +
            (viewModel.hasObservationFeature ? 1 : 0) +
            (viewModel.hasAnimalCensusFeature ? 1 : 0);
      }
    } on AssertionError catch (e) {
      debugPrint(e.toString());
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context, HomeViewModel viewModel) {
    final paths = [
      '/reports',
      if (viewModel.hasObservationFeature) '/observations',
      if (viewModel.hasAnimalCensusFeature) '/census',
      '/profile',
    ];

    if (index >= 0 && index < paths.length) {
      GoRouter.of(context).go(paths[index]);
    }
  }
}

class _ReSubmitBlock extends StackedHookView<HomeViewModel> {
  @override
  Widget builder(BuildContext context, HomeViewModel viewModel) {
    var localize = AppLocalizations.of(context);

    return viewModel.numberOfPendingSubmissions > 0
        ? Container(
            width: double.infinity,
            height: kToolbarHeight * .6,
            color: Colors.red.shade400,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ReSubmitView(),
                  ),
                );
              },
              child: Text(
                localize!.numberOfPendingSubmissions(
                    viewModel.numberOfPendingSubmissions),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
