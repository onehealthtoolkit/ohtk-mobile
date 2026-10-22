import 'package:flutter/material.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/ui/home/incidents_theme.dart';

/// Shared presentation for list and detail; CASE alone only means linked.
class ReportCaseBadge extends StatelessWidget {
  final IncidentReport report;

  const ReportCaseBadge({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    if (report.caseId == null) return const SizedBox.shrink();
    final localize = AppLocalizations.of(context)!;
    final outcome = report.caseStatus?.outcome ?? ReportCaseOutcome.unknown;
    final closed = outcome == ReportCaseOutcome.closed;
    final neutral = outcome == ReportCaseOutcome.automaticClose ||
        outcome == ReportCaseOutcome.falsePositive;
    final label = switch (outcome) {
      ReportCaseOutcome.closed => localize.caseClosedTag,
      ReportCaseOutcome.automaticClose => localize.caseAutomaticCloseTag,
      ReportCaseOutcome.falsePositive => localize.caseFalsePositiveTag,
      _ => localize.caseTag,
    };
    final foreground = closed
        ? const Color(0xFF166534)
        : neutral
            ? const Color(0xFF374151)
            : incidentsCasePillFg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: closed
            ? const Color(0xFFDCFCE7)
            : neutral
                ? const Color(0xFFF3F4F6)
                : incidentsCasePillBg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (closed) ...[
            Icon(Icons.check, size: 12, color: foreground),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
