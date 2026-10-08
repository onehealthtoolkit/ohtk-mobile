import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:podd_app/components/motion.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/router.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/home/incidents_theme.dart';

import 'all_reports_view_model.dart';

final _timestampFormatter = DateFormat('dd/MM/yy HH:mm');

class ReportListView<T extends BaseReportViewModel> extends StatelessWidget {
  final T viewModel;

  const ReportListView({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reports = viewModel.incidentReports;
    if (reports.isEmpty) {
      return _EmptyState();
    }

    final groups = _groupReports(reports);
    final localize = AppLocalizations.of(context)!;

    final List<Widget> children = [];
    for (final group in groups) {
      children.add(_SectionEyebrow(label: group.labelFor(localize)));
      for (final report in group.reports) {
        children.add(_IncidentReportCard(
          report: report,
          imagePath: _resolveImagePath(viewModel, report),
        ));
      }
    }

    return ListView(
      key: key,
      padding: const EdgeInsets.fromLTRB(
        OhtkLayout.pagePad,
        OhtkSpace.lg,
        OhtkLayout.pagePad,
        120,
      ),
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: OhtkLayout.rowGap),
          children[i],
        ],
      ],
    );
  }

  String? _resolveImagePath(T vm, IncidentReport report) {
    final image =
        (report.images?.isNotEmpty ?? false) ? report.images!.first : null;
    if (image == null) return null;
    return vm.resolveImagePath(image.thumbnailPath);
  }

  List<_ReportGroup> _groupReports(List<IncidentReport> reports) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recentCutoff = today.subtract(const Duration(days: 7));

    final recent = <IncidentReport>[];
    final earlier = <IncidentReport>[];

    for (final r in reports) {
      final created = r.createdAt.toLocal();
      if (!created.isBefore(recentCutoff)) {
        recent.add(r);
      } else {
        earlier.add(r);
      }
    }

    final groups = <_ReportGroup>[];
    if (recent.isNotEmpty) {
      groups.add(_ReportGroup(_GroupKind.recent, recent));
    }
    if (earlier.isNotEmpty) {
      groups.add(_ReportGroup(_GroupKind.earlier, earlier));
    }
    return groups;
  }
}

enum _GroupKind { recent, earlier }

class _ReportGroup {
  final _GroupKind kind;
  final List<IncidentReport> reports;

  _ReportGroup(this.kind, this.reports);

  String labelFor(AppLocalizations localize) {
    switch (kind) {
      case _GroupKind.recent:
        return localize.recentSectionLabel;
      case _GroupKind.earlier:
        return localize.earlierSectionLabel;
    }
  }
}

class _SectionEyebrow extends StatelessWidget {
  final String label;

  const _SectionEyebrow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
      child: OhtkEyebrow(label: label),
    );
  }
}

class _IncidentReportCard extends StatelessWidget {
  final IncidentReport report;
  final String? imagePath;

  const _IncidentReportCard({
    required this.report,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return OhtkCard(
      onTap: () {
        GoRouter.of(context).goNamed(
          OhtkRouter.incidentDetail,
          pathParameters: {'incidentId': report.id},
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Thumbnail(
            imagePath: imagePath,
            fallbackLabel: report.reportTypeName,
          ),
          const SizedBox(width: OhtkSpace.md),
          Expanded(child: _Content(report: report)),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String? imagePath;
  final String fallbackLabel;

  const _Thumbnail({
    required this.imagePath,
    required this.fallbackLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null) {
      return const _FallbackTile();
    }
    return ClipRRect(
      borderRadius: OhtkRadius.tile,
      child: SizedBox(
        width: 56,
        height: 56,
        child: CachedNetworkImage(
          imageUrl: imagePath!,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              Container(color: OhtkTheme.palette.teal100),
          errorWidget: (context, url, error) => const _FallbackTile(),
        ),
      ),
    );
  }
}

class _FallbackTile extends StatelessWidget {
  const _FallbackTile();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: ClipRRect(
        borderRadius: OhtkRadius.tile,
        child: CustomPaint(
          painter: _FallbackPainter(),
          size: const Size(56, 56),
        ),
      ),
    );
  }
}

class _FallbackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = OhtkTheme.palette.teal100;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final glyphSide = size.width * 0.55;
    final origin = Offset(
      (size.width - glyphSide) / 2,
      (size.height - glyphSide) / 2,
    );
    final scale = glyphSide / 60.0;

    final darkStem = Paint()..color = const Color(0xFFB9D6DD);
    final lightStem = Paint()..color = const Color(0xFFCFE2E8);

    final left = Rect.fromLTWH(
      origin.dx + 8 * scale,
      origin.dy + 6 * scale,
      12 * scale,
      48 * scale,
    );
    final right = Rect.fromLTWH(
      origin.dx + 26 * scale,
      origin.dy + 12 * scale,
      12 * scale,
      42 * scale,
    );
    final bar = Rect.fromLTWH(
      origin.dx + 20 * scale,
      origin.dy + 26 * scale,
      6 * scale,
      10 * scale,
    );

    canvas.drawRect(left, darkStem);
    canvas.drawRect(right, lightStem);
    canvas.drawRect(bar, darkStem);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Content extends StatelessWidget {
  final IncidentReport report;

  const _Content({required this.report});

  @override
  Widget build(BuildContext context) {
    final showCase = report.caseId != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                report.reportTypeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                  color: incidentsInk,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _timestampFormatter.format(report.createdAt.toLocal()),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: incidentsMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          report.trimWhitespaceDescription.isEmpty
              ? report.reportTypeName
              : report.trimWhitespaceDescription,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15,
            height: 1.45,
            color: incidentsBody,
          ),
        ),
        if (showCase) ...[
          const SizedBox(height: 4),
          const _CasePill(),
        ],
      ],
    );
  }
}

class _CasePill extends StatelessWidget {
  const _CasePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: incidentsCasePillBg,
        borderRadius: OhtkRadius.chip,
      ),
      child: Text(
        (AppLocalizations.of(context)?.caseTag ?? 'Case').toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: incidentsCasePillFg,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 90),
      children: [
        EmptyStateAppear(
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: incidentsTeal.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assignment_outlined,
                    color: incidentsTeal,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                localize.noReportsTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: incidentsInk,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                localize.noReportsHelper,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: incidentsMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
