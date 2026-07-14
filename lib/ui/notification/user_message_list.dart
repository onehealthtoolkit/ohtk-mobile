import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:podd_app/components/motion.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/models/entities/user_message.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/home/incidents_theme.dart';
import 'package:podd_app/ui/notification/user_message_view.dart';
import 'package:podd_app/ui/notification/user_message_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

Color get _brandPrimary => OhtkTheme.palette.teal700;
Color get _brandDeep => OhtkTheme.palette.teal900;
Color get _brandTint => OhtkTheme.palette.teal700.withValues(alpha: 0.10);

class UserMessageList extends StatelessWidget {
  const UserMessageList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<UserMessageListViewModel>.nonReactive(
      viewModelBuilder: () => UserMessageListViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        backgroundColor: incidentsSand,
        appBar: _NotificationAppBar(
          title: AppLocalizations.of(context)!.notificationsTitle,
        ),
        body: _UserMessageList(),
      ),
    );
  }
}

class _UserMessageList extends StackedHookView<UserMessageListViewModel> {
  @override
  Widget builder(BuildContext context, UserMessageListViewModel viewModel) {
    if (viewModel.isBusy) {
      return const _NotificationsLoading();
    }

    if (viewModel.hasFetchError) {
      return _StateMessage(
        icon: Icons.warning_amber_rounded,
        iconColor: incidentsErrorRed,
        iconBackground: incidentsErrorTint,
        title: "Can't load your messages",
        helper:
            'Check your connection and try again. Your reports are saved on this device - nothing is lost.',
        actionLabel: 'TRY AGAIN',
        filledAction: true,
        onAction: viewModel.fetch,
      );
    }

    if (viewModel.userMessages.isEmpty) {
      return _StateMessage(
        icon: Icons.mark_email_read_outlined,
        iconColor: _brandPrimary,
        iconBackground: _brandPrimary.withValues(alpha: 0.08),
        title: "You're all caught up",
        helper:
            'New messages from the authority will appear here when your reports are reviewed.',
        actionLabel: 'REFRESH',
        onAction: viewModel.fetch,
      );
    }

    final localize = AppLocalizations.of(context)!;
    final groups = _groupMessages(viewModel.userMessages);

    final List<Widget> children = [];
    for (final group in groups) {
      children.add(_SectionEyebrow(label: group.labelFor(localize)));
      for (int i = 0; i < group.messages.length; i++) {
        final isLast = i == group.messages.length - 1;
        children.add(_NotificationRow(
          userMessage: group.messages[i],
          hasBottomDivider: !isLast,
          onTap: () {
            viewModel.markSeen(group.messages[i]);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserMessageView(id: group.messages[i].id),
              ),
            );
          },
        ));
      }
    }

    return RefreshIndicator(
      color: _brandPrimary,
      onRefresh: viewModel.fetch,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          top: 4,
          bottom: 24 + MediaQuery.of(context).padding.bottom,
        ),
        children: children,
      ),
    );
  }
}

enum _GroupKind { recent, earlier }

class _MessageGroup {
  final _GroupKind kind;
  final List<UserMessage> messages;

  _MessageGroup(this.kind, this.messages);

  String labelFor(AppLocalizations localize) {
    switch (kind) {
      case _GroupKind.recent:
        return localize.recentSectionLabel;
      case _GroupKind.earlier:
        return localize.earlierSectionLabel;
    }
  }
}

List<_MessageGroup> _groupMessages(List<UserMessage> messages) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final recentCutoff = today.subtract(const Duration(days: 7));

  final recent = <UserMessage>[];
  final earlier = <UserMessage>[];

  for (final m in messages) {
    final created = m.createdAt.toLocal();
    if (!created.isBefore(recentCutoff)) {
      recent.add(m);
    } else {
      earlier.add(m);
    }
  }

  final groups = <_MessageGroup>[];
  if (recent.isNotEmpty) groups.add(_MessageGroup(_GroupKind.recent, recent));
  if (earlier.isNotEmpty) {
    groups.add(_MessageGroup(_GroupKind.earlier, earlier));
  }
  return groups;
}

class _SectionEyebrow extends StatelessWidget {
  final String label;

  const _SectionEyebrow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: incidentsMuted,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  final UserMessage userMessage;
  final VoidCallback onTap;
  final bool hasBottomDivider;

  const _NotificationRow({
    required this.userMessage,
    required this.onTap,
    this.hasBottomDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final unread = !userMessage.isSeen;
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: hasBottomDivider
                ? const Border(
                    bottom: BorderSide(color: incidentsHair, width: 1),
                  )
                : null,
          ),
          child: Stack(
            children: [
              if (unread)
                Positioned(
                  left: 0,
                  top: 10,
                  bottom: 10,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: _brandPrimary,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(2),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MessageGlyph(unread: unread),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Expanded(
                                child: Text(
                                  userMessage.message.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: incidentsInk,
                                    fontFamily: incidentsFontFamily,
                                    fontFamilyFallback:
                                        incidentsFontFamilyFallback,
                                    fontSize: 14,
                                    fontWeight: unread
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatListTime(userMessage.createdAt),
                                style: TextStyle(
                                  color:
                                      unread ? _brandPrimary : incidentsMuted,
                                  fontFamily: incidentsFontFamily,
                                  fontFamilyFallback:
                                      incidentsFontFamilyFallback,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            userMessage.message.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: incidentsBody,
                              fontFamily: incidentsFontFamily,
                              fontFamilyFallback: incidentsFontFamilyFallback,
                              fontSize: 12.5,
                              fontWeight:
                                  unread ? FontWeight.w500 : FontWeight.w400,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageGlyph extends StatelessWidget {
  final bool unread;

  const _MessageGlyph({required this.unread});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: unread ? _brandTint : const Color(0x146B7370),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.verified_outlined,
        color: unread ? _brandPrimary : incidentsMuted,
        size: 18,
      ),
    );
  }
}

class _NotificationsLoading extends StatelessWidget {
  const _NotificationsLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 10),
      itemCount: 6,
      itemBuilder: (context, index) => _SkeletonRow(
        titleWidthFactor: <double>[.70, .55, .80, .45, .65, .50][index],
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  final double titleWidthFactor;

  const _SkeletonRow({required this.titleWidthFactor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SkeletonBlock(width: 36, height: 36, radius: 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: titleWidthFactor,
                  alignment: Alignment.centerLeft,
                  child: const _SkeletonBlock(height: 12),
                ),
                const SizedBox(height: 8),
                const _SkeletonBlock(height: 9),
                const SizedBox(height: 5),
                const FractionallySizedBox(
                  widthFactor: .70,
                  alignment: Alignment.centerLeft,
                  child: _SkeletonBlock(height: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const _SkeletonBlock({
    this.width,
    required this.height,
    this.radius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xB3E4E2DC),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String helper;
  final String actionLabel;
  final bool filledAction;
  final Future<void> Function() onAction;

  const _StateMessage({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.helper,
    required this.actionLabel,
    required this.onAction,
    this.filledAction = false,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: _brandPrimary,
      onRefresh: onAction,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: EmptyStateAppear(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: iconBackground,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(icon, color: iconColor, size: 38),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: incidentsInk,
                          fontFamily: incidentsFontFamily,
                          fontFamilyFallback: incidentsFontFamilyFallback,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: Text(
                          helper,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: incidentsMuted,
                            fontFamily: incidentsFontFamily,
                            fontFamilyFallback: incidentsFontFamilyFallback,
                            fontSize: 13.5,
                            height: 1.55,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      filledAction
                          ? ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: _brandPrimary,
                                foregroundColor: Colors.white,
                                shape: const StadiumBorder(),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                minimumSize: const Size(0, 44),
                              ),
                              onPressed: onAction,
                              icon: const Icon(Icons.refresh, size: 15),
                              label: _ActionLabel(actionLabel),
                            )
                          : OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _brandPrimary,
                                side: BorderSide(
                                  color: _brandPrimary,
                                  width: 1.5,
                                ),
                                shape: const StadiumBorder(),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 18),
                                minimumSize: const Size(0, 38),
                              ),
                              onPressed: onAction,
                              icon: const Icon(Icons.refresh, size: 14),
                              label: _ActionLabel(actionLabel),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionLabel extends StatelessWidget {
  final String label;

  const _ActionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: incidentsFontFamily,
        fontFamilyFallback: incidentsFontFamilyFallback,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _NotificationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;

  const _NotificationAppBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _brandDeep,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: preferredSize.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.maybePop(context),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: incidentsFontFamily,
                        fontFamilyFallback: incidentsFontFamilyFallback,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatListTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final now = DateTime.now();
  if (DateUtils.isSameDay(local, now)) {
    return DateFormat('HH:mm').format(local);
  }
  return DateFormat('dd/MM/yy').format(local);
}
