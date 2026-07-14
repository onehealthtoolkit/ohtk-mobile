import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/models/entities/user_message.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/home/incidents_theme.dart';
import 'package:podd_app/ui/notification/user_message_view_model.dart';
import 'package:stacked/stacked.dart';

Color get _brandPrimary => OhtkTheme.palette.teal700;
Color get _brandDeep => OhtkTheme.palette.teal900;
Color get _brandTint => OhtkTheme.palette.teal700.withValues(alpha: 0.10);

class UserMessageView extends StatelessWidget {
  final String id;
  const UserMessageView({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<UserMessageViewViewModel>.reactive(
      viewModelBuilder: () => UserMessageViewViewModel(id),
      builder: (context, viewModel, child) => Scaffold(
        backgroundColor: Colors.white,
        appBar: _NotificationAppBar(
          title: AppLocalizations.of(context)!.notificationDetailTitle,
        ),
        body: viewModel.isBusy
            ? const Center(child: OhtkProgressIndicator(size: 100))
            : viewModel.hasError || viewModel.data == null
                ? const _MessageError()
                : _MessageDetail(userMessage: viewModel.data!),
      ),
    );
  }
}

class _MessageDetail extends StatelessWidget {
  final UserMessage userMessage;

  const _MessageDetail({required this.userMessage});

  @override
  Widget build(BuildContext context) {
    final relatedReportId = _findReportId(userMessage.message.body);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _HeroHeader(userMessage: userMessage),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
          child: Text(
            userMessage.message.body,
            style: const TextStyle(
              color: incidentsInk,
              fontFamily: incidentsFontFamily,
              fontFamilyFallback: incidentsFontFamilyFallback,
              fontSize: 15.5,
              fontWeight: FontWeight.w400,
              height: 1.65,
            ),
          ),
        ),
        if (relatedReportId != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
            child: _RelatedReportTile(reportId: relatedReportId),
          ),
      ],
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final UserMessage userMessage;

  const _HeroHeader({required this.userMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: incidentsHair),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
            decoration: ShapeDecoration(
              color: _brandTint,
              shape: const StadiumBorder(),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_outlined,
                  color: _brandPrimary,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  'REPORT ACKNOWLEDGED',
                  style: TextStyle(
                    color: _brandPrimary,
                    fontFamily: incidentsFontFamily,
                    fontFamilyFallback: incidentsFontFamilyFallback,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            userMessage.message.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: incidentsInk,
              fontFamily: incidentsFontFamily,
              fontFamilyFallback: incidentsFontFamilyFallback,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: Text(
                  _authorName(userMessage),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: incidentsMuted,
                    fontFamily: incidentsFontFamily,
                    fontFamilyFallback: incidentsFontFamilyFallback,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 3,
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: const BoxDecoration(
                  color: incidentsMuted,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                DateFormat('dd/MM/yy HH:mm')
                    .format(userMessage.createdAt.toLocal()),
                style: const TextStyle(
                  color: incidentsMuted,
                  fontFamily: incidentsFontFamily,
                  fontFamilyFallback: incidentsFontFamilyFallback,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RelatedReportTile extends StatelessWidget {
  final String reportId;

  const _RelatedReportTile({required this.reportId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: incidentsHair),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _brandTint,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              Icons.verified_outlined,
              color: _brandPrimary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RELATED REPORT',
                  style: TextStyle(
                    color: incidentsMuted,
                    fontFamily: incidentsFontFamily,
                    fontFamilyFallback: incidentsFontFamilyFallback,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reportId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: incidentsInk,
                    fontFamily: incidentsFontFamily,
                    fontFamilyFallback: incidentsFontFamilyFallback,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageError extends StatelessWidget {
  const _MessageError();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          "Message not found",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: incidentsMuted,
            fontFamily: incidentsFontFamily,
            fontFamilyFallback: incidentsFontFamilyFallback,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
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

String _authorName(UserMessage userMessage) {
  final user = userMessage.user;
  if (user == null) {
    return 'OHTK Authority';
  }

  final fullName = '${user.firstName} ${user.lastName}'.trim();
  if (fullName.isNotEmpty) {
    return fullName;
  }

  return user.username;
}

String? _findReportId(String body) {
  return RegExp(r'REP-\d{4}-\d+').firstMatch(body)?.group(0);
}
