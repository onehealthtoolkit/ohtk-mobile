import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/ui/home/incidents_theme.dart';
import 'package:podd_app/ui/resubmit/resubmit_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ReSubmitView extends StatelessWidget {
  const ReSubmitView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return ViewModelBuilder<ReSubmitViewModel>.nonReactive(
      viewModelBuilder: () => ReSubmitViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        backgroundColor: incidentsSand,
        appBar: _PendingAppBar(title: localize.pendingAppLabel),
        body: _Body(),
      ),
    );
  }
}

class _Body extends StackedHookView<ReSubmitViewModel> {
  @override
  Widget builder(BuildContext context, ReSubmitViewModel viewModel) {
    if (viewModel.isBusy) {
      return const Center(child: OhtkProgressIndicator(size: 100));
    }

    return viewModel.isEmpty
        ? _EmptyState(onBack: () => Navigator.maybePop(context))
        : _PendingListBody(viewModel: viewModel);
  }
}

class _PendingListBody extends StatelessWidget {
  final ReSubmitViewModel viewModel;

  const _PendingListBody({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    final totalCount = _totalPendingCount(viewModel);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
            children: [
              _SummaryPanel(count: totalCount),
              const SizedBox(height: 14),
              _PendingSection(
                title: localize.pendingReportsTitle,
                icon: Icons.assignment_outlined,
                items: viewModel.pendingReports,
                onDismissed: viewModel.deletePendingReport,
              ),
              _PendingSection(
                title: localize.pendingSubjectsTitle,
                icon: Icons.fact_check_outlined,
                items: viewModel.pendingSubjectRecords,
                onDismissed: viewModel.deletePendingSubjectRecord,
              ),
              _PendingSection(
                title: localize.pendingMonitoringsTitle,
                icon: Icons.monitor_heart_outlined,
                items: viewModel.pendingMonitoringRecords,
                onDismissed: viewModel.deletePendingMonitoringRecord,
              ),
              _PendingSection(
                title: localize.pendingImagesTitle,
                icon: Icons.image_outlined,
                items: viewModel.pendingImages,
                onDismissed: viewModel.deletePendingImage,
              ),
              _PendingSection(
                title: localize.pendingFilesTitle,
                icon: Icons.attach_file,
                items: viewModel.pendingFiles,
                onDismissed: viewModel.deletePendingFile,
              ),
            ],
          ),
        ),
        _BottomActionBar(viewModel: viewModel),
      ],
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  final int count;

  const _SummaryPanel({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: incidentsTestBannerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: incidentsTestBannerBorder),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: incidentsTestPillFg,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: incidentsTestBannerBorder),
                      ),
                      child: const Icon(
                        Icons.sync_problem_outlined,
                        color: incidentsTestPillFg,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$count pending ${count == 1 ? 'item' : 'items'}',
                            style: const TextStyle(
                              color: incidentsInk,
                              fontFamily: incidentsFontFamily,
                              fontFamilyFallback: incidentsFontFamilyFallback,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Saved on this device until the app can send them.',
                            style: TextStyle(
                              color: incidentsTestPillFg,
                              fontFamily: incidentsFontFamily,
                              fontFamilyFallback: incidentsFontFamilyFallback,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<SubmissionState> items;
  final Future<void> Function(String id) onDismissed;

  const _PendingSection({
    required this.title,
    required this.icon,
    required this.items,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
            child: Row(
              children: [
                Icon(icon, size: 17, color: incidentsMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: incidentsMuted,
                      fontFamily: incidentsFontFamily,
                      fontFamilyFallback: incidentsFontFamilyFallback,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Text(
                  '${items.length}',
                  style: const TextStyle(
                    color: incidentsTeal,
                    fontFamily: incidentsFontFamily,
                    fontFamilyFallback: incidentsFontFamilyFallback,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: incidentsHair),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    _DismissiblePendingSubmission(
                      state: items[i],
                      sectionIcon: icon,
                      onDismissed: onDismissed,
                    ),
                    if (i != items.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        indent: 66,
                        color: incidentsHair,
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DismissiblePendingSubmission extends StatelessWidget {
  final SubmissionState state;
  final IconData sectionIcon;
  final Future<void> Function(String id) onDismissed;

  const _DismissiblePendingSubmission({
    required this.state,
    required this.sectionIcon,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(state.item.id),
      background: const _DeleteBackground(alignment: Alignment.centerLeft),
      secondaryBackground:
          const _DeleteBackground(alignment: Alignment.centerRight),
      onDismissed: (_) => onDismissed(state.item.id),
      child: _PendingSubmission(
        state: state,
        sectionIcon: sectionIcon,
      ),
    );
  }
}

class _PendingSubmission extends StatelessWidget {
  final SubmissionState state;
  final IconData sectionIcon;

  _PendingSubmission({
    required this.state,
    required this.sectionIcon,
  });

  final formatter = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _statusBackground(state.state),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                sectionIcon,
                size: 19,
                color: _statusColor(state.state),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.item.name.isNotEmpty
                        ? state.item.name
                        : state.item.id,
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
                  const SizedBox(height: 4),
                  Text(
                    _subtitleFor(state.item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: incidentsMuted,
                      fontFamily: incidentsFontFamily,
                      fontFamilyFallback: incidentsFontFamilyFallback,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _ProgressBadge(status: state.state),
          ],
        ),
      ),
    );
  }

  String _subtitleFor(SubmissionItem item) {
    if (item.date != null) {
      return formatter.format(item.date!.toLocal());
    }
    return item.id;
  }
}

class _ProgressBadge extends StatelessWidget {
  final Progress status;

  const _ProgressBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case Progress.pending:
        return const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.3,
            color: incidentsTeal,
          ),
        );
      case Progress.complete:
        return const _StatusPill(
          icon: Icons.check_rounded,
          label: 'SENT',
          color: incidentsTeal,
          background: Color(0x1A0F8A82),
        );
      case Progress.fail:
        return const _StatusPill(
          icon: Icons.priority_high_rounded,
          label: 'FAILED',
          color: incidentsErrorRed,
          background: incidentsErrorTint,
        );
      default:
        return const Icon(
          Icons.chevron_left,
          color: incidentsNavInactive,
          size: 18,
        );
    }
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: background,
        shape: StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontFamily: incidentsFontFamily,
              fontFamilyFallback: incidentsFontFamilyFallback,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: .7,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  final Alignment alignment;

  const _DeleteBackground({required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: incidentsErrorRed,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: const Icon(
        Icons.delete_outline,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final ReSubmitViewModel viewModel;

  const _BottomActionBar({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: incidentsHair)),
        ),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: viewModel.isOffline
            ? _OfflineBanner(message: localize.offlineWarning)
            : SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: incidentsTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: viewModel.isEmpty || viewModel.isSubmittingAll
                      ? null
                      : viewModel.submitAllPendings,
                  icon: viewModel.isSubmittingAll
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.cloud_upload_outlined, size: 20),
                  label: Text(
                    localize.resubmit.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: incidentsFontFamily,
                      fontFamilyFallback: incidentsFontFamilyFallback,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  final String message;

  const _OfflineBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: incidentsOfflineBannerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: incidentsOfflineBannerBorder),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: incidentsOfflineBannerFg,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: incidentsOfflineBannerFg,
                fontFamily: incidentsFontFamily,
                fontFamilyFallback: incidentsFontFamilyFallback,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onBack;

  const _EmptyState({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0x1A0F8A82),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.cloud_done_outlined,
                color: incidentsTeal,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              localize.noPendingSubmissions,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: incidentsInk,
                fontFamily: incidentsFontFamily,
                fontFamilyFallback: incidentsFontFamilyFallback,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: incidentsTeal,
                side: const BorderSide(color: incidentsTeal, width: 1.5),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                minimumSize: const Size(0, 38),
              ),
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, size: 16),
              label: Text(
                localize.formBackButton.toUpperCase(),
                style: const TextStyle(
                  fontFamily: incidentsFontFamily,
                  fontFamilyFallback: incidentsFontFamilyFallback,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const _PendingAppBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: incidentsTealDeep,
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

Color _statusColor(Progress status) {
  switch (status) {
    case Progress.complete:
      return incidentsTeal;
    case Progress.fail:
      return incidentsErrorRed;
    case Progress.pending:
      return incidentsTeal;
    default:
      return incidentsMuted;
  }
}

Color _statusBackground(Progress status) {
  switch (status) {
    case Progress.complete:
    case Progress.pending:
      return const Color(0x1A0F8A82);
    case Progress.fail:
      return incidentsErrorTint;
    default:
      return const Color(0x146B7370);
  }
}

int _totalPendingCount(ReSubmitViewModel viewModel) {
  return viewModel.pendingReports.length +
      viewModel.pendingSubjectRecords.length +
      viewModel.pendingMonitoringRecords.length +
      viewModel.pendingImages.length +
      viewModel.pendingFiles.length;
}
