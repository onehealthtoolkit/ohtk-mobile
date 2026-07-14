import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/models/entities/followup_report.dart';
import 'package:podd_app/router.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/home/incidents_theme.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

import 'followup_list_view_model.dart';

final _followupTimestamp = DateFormat('dd/MM/yyyy HH:mm');
Color get _brandPrimary => OhtkTheme.palette.teal700;
Color get _brandTint => OhtkTheme.palette.teal700.withValues(alpha: 0.08);

class FollowupListView extends StatelessWidget {
  final String incidentId;

  const FollowupListView(this.incidentId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FollowupListViewModel>.nonReactive(
      viewModelBuilder: () => FollowupListViewModel(incidentId),
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      builder: (context, viewModel, child) => _FollowupList(),
    );
  }
}

class _FollowupList extends StackedHookView<FollowupListViewModel> {
  @override
  Widget builder(BuildContext context, FollowupListViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.refetchFollowups();
      },
      child: viewModel.followupReport.isEmpty
          ? _FollowupEmptyState()
          : _FollowupContent(viewModel: viewModel),
    );
  }
}

class _FollowupContent extends StatelessWidget {
  final FollowupListViewModel viewModel;

  const _FollowupContent({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    final reports = viewModel.followupReport;
    return ListView.separated(
      key: const PageStorageKey('all-followups-storage-key'),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 96),
      itemCount: reports.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
            child: Text(
              localize.followupsCount(reports.length).toUpperCase(),
              style: const TextStyle(
                fontFamily: incidentsFontFamily,
                fontFamilyFallback: incidentsFontFamilyFallback,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: incidentsMuted,
              ),
            ),
          );
        }
        final report = reports[index - 1];
        return _FollowupRow(
          report: report,
          imagePath: _firstImagePath(viewModel, report),
          onTap: () {
            GoRouter.of(context).goNamed(
              OhtkRouter.incidentFollowup,
              pathParameters: {
                'incidentId': viewModel.incidentId,
                'followupId': report.id,
              },
            );
          },
        );
      },
    );
  }

  String? _firstImagePath(FollowupListViewModel vm, FollowupReport report) {
    final image =
        (report.images?.isNotEmpty ?? false) ? report.images!.first : null;
    if (image == null) return null;
    return vm.resolveImagePath(image.thumbnailPath);
  }
}

class _FollowupRow extends StatelessWidget {
  final FollowupReport report;
  final String? imagePath;
  final VoidCallback onTap;

  const _FollowupRow({
    required this.report,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: incidentsHair),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FollowupThumbnail(imagePath: imagePath),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _followupTimestamp.format(report.createdAt.toLocal()),
                      style: const TextStyle(
                        fontFamily: incidentsFontFamily,
                        fontFamilyFallback: incidentsFontFamilyFallback,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: incidentsMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      report.trimWhitespaceDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: incidentsFontFamily,
                        fontFamilyFallback: incidentsFontFamilyFallback,
                        fontSize: 13,
                        height: 1.45,
                        color: incidentsBody,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 22),
                child: Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: _brandPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FollowupThumbnail extends StatelessWidget {
  final String? imagePath;

  const _FollowupThumbnail({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 72,
          height: 72,
          child: CachedNetworkImage(
            imageUrl: imagePath!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: incidentsHair),
            errorWidget: (context, url, error) => _HFallback(),
          ),
        ),
      );
    }
    return _HFallback();
  }
}

class _HFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CustomPaint(
          painter: _HFallbackPainter(),
          size: const Size(72, 72),
        ),
      ),
    );
  }
}

class _HFallbackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = incidentsFallbackTile;
    canvas.drawRect(Offset.zero & size, bg);

    final glyphSide = size.width * 0.55;
    final origin = Offset(
      (size.width - glyphSide) / 2,
      (size.height - glyphSide) / 2,
    );
    final scale = glyphSide / 60.0;

    final dark = Paint()..color = incidentsFallbackStemDark;
    final light = Paint()..color = incidentsFallbackStemLight;

    canvas.drawRect(
      Rect.fromLTWH(
          origin.dx + 8 * scale, origin.dy + 6 * scale, 12 * scale, 48 * scale),
      dark,
    );
    canvas.drawRect(
      Rect.fromLTWH(origin.dx + 26 * scale, origin.dy + 12 * scale, 12 * scale,
          42 * scale),
      light,
    );
    canvas.drawRect(
      Rect.fromLTWH(origin.dx + 20 * scale, origin.dy + 26 * scale, 6 * scale,
          10 * scale),
      dark,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FollowupEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 96),
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _brandTint,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.update,
              size: 32,
              color: _brandPrimary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          localize.noFollowupsTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: incidentsFontFamily,
            fontFamilyFallback: incidentsFontFamilyFallback,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: incidentsInk,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          localize.noFollowupsHelper,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: incidentsFontFamily,
            fontFamilyFallback: incidentsFontFamilyFallback,
            fontSize: 12.5,
            height: 1.5,
            color: incidentsMuted,
          ),
        ),
      ],
    );
  }
}
