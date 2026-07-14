import 'dart:async';

import 'package:flutter/material.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/home/consent_view.dart';
import 'package:podd_app/ui/home/home_view_model.dart';
import 'package:podd_app/ui/home/incidents_theme.dart';
import 'package:podd_app/ui/notification/user_message_list.dart';
import 'package:podd_app/ui/notification/user_message_view.dart';
import 'package:podd_app/ui/notification/user_message_view_model.dart';
import 'package:podd_app/ui/resubmit/resubmit_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

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
            const Text(
              'You have a new message',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            trailing: Builder(builder: (context) {
              return TextButton(
                onPressed: () {
                  OverlaySupportEntry.of(context)!.dismiss();
                  _viewUserMessage(context, userMessageId);
                },
                child: const Text(
                  'VIEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              );
            }),
            background: OhtkTheme.palette.teal900,
            slideDismissDirection: DismissDirection.horizontal,
            duration: const Duration(seconds: 4),
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
        const appBarContentHeight = OhtkLayout.headerH;
        final topInset = MediaQuery.of(context).padding.top;
        final resubmitExtra = viewModel.numberOfPendingSubmissions > 0
            ? kToolbarHeight * .6
            : 0.0;
        return Scaffold(
          primary: false,
          backgroundColor: incidentsSand,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(
              topInset + appBarContentHeight + resubmitExtra,
            ),
            child: Column(
              children: [
                const _IncidentsAppBar(),
                _ReSubmitBlock(),
              ],
            ),
          ),
          bottomNavigationBar: _IncidentsBottomNav(viewModel: viewModel),
          body: child,
        );
      },
    );
  }
}

class _IncidentsAppBar extends StatelessWidget {
  const _IncidentsAppBar();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Container(
      color: OhtkTheme.palette.teal900,
      padding: EdgeInsets.fromLTRB(
        OhtkLayout.pagePad,
        mediaQuery.padding.top,
        OhtkLayout.pagePad,
        0,
      ),
      height: mediaQuery.padding.top + OhtkLayout.headerH,
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context)?.appName ?? 'OHTK Mobile',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
                color: Colors.white,
              ),
            ),
          ),
          const _NotificationBell(),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<UserMessageListViewModel>.reactive(
      viewModelBuilder: () => UserMessageListViewModel(),
      builder: (context, viewModel, child) {
        return SizedBox(
          width: 36,
          height: 36,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserMessageList(),
                        ),
                      );
                    },
                    child: const Center(
                      child: Icon(
                        Icons.notifications_none_outlined,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              if (viewModel.hasUnseenMessages)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: incidentsBadgeDot,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: OhtkTheme.palette.teal900, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _IncidentsBottomNav extends StatelessWidget {
  final HomeViewModel viewModel;

  const _IncidentsBottomNav({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context);
    final items = <_NavItem>[
      _NavItem(
        path: '/reports',
        label: localize?.incidentsTabTitle ?? 'Incidents',
        iconPainter: _NavIconPainter.clipboard,
      ),
      if (viewModel.hasObservationFeature)
        _NavItem(
          path: '/observations',
          label: localize?.observationsTabTitle ?? 'Observations',
          iconPainter: _NavIconPainter.eye,
        ),
      if (viewModel.hasAnimalCensusFeature)
        _NavItem(
          path: '/census',
          label: localize?.censusTabTitle ?? 'Census',
          iconPainter: _NavIconPainter.users,
        ),
      _NavItem(
        path: '/profile',
        label: localize?.profileTabTitle ?? 'Profile',
        iconPainter: _NavIconPainter.user,
      ),
    ];

    final location = GoRouterState.of(context).uri.path;
    final activeIndex = items.indexWhere((it) => location.startsWith(it.path));
    final selected = activeIndex >= 0 ? activeIndex : 0;

    return Container(
      decoration: const BoxDecoration(
        color: OhtkColor.paper,
        border: Border(top: BorderSide(color: OhtkColor.line)),
      ),
      padding: EdgeInsets.only(
        top: 5,
        left: 4,
        right: 4,
        bottom: 7 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: _NavTab(
                item: items[i],
                selected: i == selected,
                onTap: () => GoRouter.of(context).go(items[i].path),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String path;
  final String label;
  final _NavIconPainter iconPainter;

  const _NavItem({
    required this.path,
    required this.label,
    required this.iconPainter,
  });
}

class _NavTab extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? OhtkTheme.palette.teal700 : OhtkColor.ink400;
    return InkResponse(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CustomPaint(
                painter: _NavStrokeIconPainter(
                  kind: item.iconPainter,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _NavIconPainter { clipboard, eye, users, user }

/// Stroke icons matching the design handoff's inline SVGs
/// (stroke-width 1.8, round caps/joins, 24×24 viewBox).
class _NavStrokeIconPainter extends CustomPainter {
  final _NavIconPainter kind;
  final Color color;

  _NavStrokeIconPainter({required this.kind, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    switch (kind) {
      case _NavIconPainter.clipboard:
        _paintClipboard(canvas, paint);
        break;
      case _NavIconPainter.eye:
        _paintEye(canvas, paint);
        break;
      case _NavIconPainter.users:
        _paintUsers(canvas, paint);
        break;
      case _NavIconPainter.user:
        _paintUser(canvas, paint);
        break;
    }

    canvas.restore();
  }

  void _paintClipboard(Canvas canvas, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(6, 4, 12, 18),
        const Radius.circular(2),
      ),
      paint,
    );
    final tab = Path()
      ..moveTo(9, 4)
      ..lineTo(9, 2)
      ..lineTo(15, 2)
      ..lineTo(15, 4);
    canvas.drawPath(tab, paint);
    canvas.drawLine(const Offset(9, 12), const Offset(15, 12), paint);
    canvas.drawLine(const Offset(9, 16), const Offset(13, 16), paint);
  }

  void _paintEye(Canvas canvas, Paint paint) {
    final outer = Path()
      ..moveTo(2, 12)
      ..cubicTo(2, 12, 5.5, 5, 12, 5)
      ..cubicTo(18.5, 5, 22, 12, 22, 12)
      ..cubicTo(22, 12, 18.5, 19, 12, 19)
      ..cubicTo(5.5, 19, 2, 12, 2, 12)
      ..close();
    canvas.drawPath(outer, paint);
    canvas.drawCircle(const Offset(12, 12), 3, paint);
  }

  void _paintUsers(Canvas canvas, Paint paint) {
    final p1 = Path()
      ..moveTo(17, 21)
      ..lineTo(17, 19)
      ..cubicTo(17, 16.79, 15.21, 15, 13, 15)
      ..lineTo(5, 15)
      ..cubicTo(2.79, 15, 1, 16.79, 1, 19)
      ..lineTo(1, 21);
    canvas.drawPath(p1, paint);
    canvas.drawCircle(const Offset(9, 7), 4, paint);

    final p2 = Path()
      ..moveTo(23, 21)
      ..lineTo(23, 19)
      ..cubicTo(23, 17.13, 21.7, 15.53, 20, 15.13);
    canvas.drawPath(p2, paint);

    final p3 = Path()
      ..moveTo(16, 3.13)
      ..cubicTo(17.76, 3.58, 19, 5.16, 19, 7)
      ..cubicTo(19, 8.84, 17.76, 10.42, 16, 10.87);
    canvas.drawPath(p3, paint);
  }

  void _paintUser(Canvas canvas, Paint paint) {
    canvas.drawCircle(const Offset(12, 8), 4, paint);
    final body = Path()
      ..moveTo(4, 21)
      ..cubicTo(4, 17, 8, 14, 12, 14)
      ..cubicTo(16, 14, 20, 17, 20, 21);
    canvas.drawPath(body, paint);
  }

  @override
  bool shouldRepaint(covariant _NavStrokeIconPainter old) =>
      old.kind != kind || old.color != color;
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
