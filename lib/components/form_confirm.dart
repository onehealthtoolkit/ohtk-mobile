import 'package:flutter/material.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/home/incidents_theme.dart';

typedef OnSubmit = Future<void> Function();

Color get _brandPrimary => OhtkTheme.palette.teal700;
Color _brandTint(double alpha) =>
    OhtkTheme.palette.teal700.withValues(alpha: alpha);

class FormConfirmSubmit extends StatelessWidget {
  final OnSubmit onSubmit;
  final VoidCallback onBack;

  /// Authority radio block (or any auxiliary section) rendered inside a
  /// teal-tinted "ONE MORE THING" card above the summary. Pass `null` to omit.
  final Widget? authority;

  /// Override for the primary submit pill copy. Defaults to
  /// `formChromeSubmitReportLabel`.
  final String? submitText;

  final String? dataSummary;
  final bool showDataSummary;
  final bool busy;

  const FormConfirmSubmit({
    required this.onSubmit,
    required this.onBack,
    this.authority,
    this.submitText,
    this.dataSummary,
    this.showDataSummary = false,
    this.busy = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return Column(
      children: [
        _ReviewHeader(
          eyebrow: localize.reviewHeaderEyebrow,
          title: localize.reviewHeaderTitle,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            children: [
              if (authority != null) ...[
                _AuthorityCard(child: authority!),
                const SizedBox(height: 12),
              ],
              if (showDataSummary) ...[
                _DataSummaryCard(
                  dataSummary: dataSummary,
                  onEdit: onBack,
                ),
                const SizedBox(height: 12),
              ],
              _ReminderStrip(message: localize.reviewReminderBody),
              const SizedBox(height: 8),
            ],
          ),
        ),
        _ReviewFooter(
          busy: busy,
          submitText: submitText ?? localize.formChromeSubmitReportLabel,
          backText: localize.reviewBackToFormButton,
          onSubmit: onSubmit,
          onBack: onBack,
        ),
      ],
    );
  }
}

class _ReviewHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  const _ReviewHeader({required this.eyebrow, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: incidentsHair, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              fontFamily: incidentsFontFamily,
              fontFamilyFallback: incidentsFontFamilyFallback,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: incidentsMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontFamily: incidentsFontFamily,
              fontFamilyFallback: incidentsFontFamilyFallback,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: incidentsInk,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthorityCard extends StatelessWidget {
  final Widget child;
  const _AuthorityCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: _brandTint(0.05),
        border: Border.all(
          color: _brandTint(0.18),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localize.authorityEyebrow,
            style: TextStyle(
              fontFamily: incidentsFontFamily,
              fontFamilyFallback: incidentsFontFamilyFallback,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: _brandPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            localize.incidentInAuthority,
            style: const TextStyle(
              fontFamily: incidentsFontFamily,
              fontFamilyFallback: incidentsFontFamilyFallback,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: incidentsInk,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            localize.authorityHelper,
            style: const TextStyle(
              fontFamily: incidentsFontFamily,
              fontFamilyFallback: incidentsFontFamilyFallback,
              fontSize: 12,
              color: incidentsMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DataSummaryCard extends StatelessWidget {
  final String? dataSummary;
  final VoidCallback onEdit;

  const _DataSummaryCard({
    required this.dataSummary,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    final body = (dataSummary != null && dataSummary!.isNotEmpty)
        ? dataSummary!
        : localize.reportDataSummaryNotFound;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: incidentsHair, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  localize.reportDataSummary,
                  style: const TextStyle(
                    fontFamily: incidentsFontFamily,
                    fontFamilyFallback: incidentsFontFamilyFallback,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: incidentsInk,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Text(
                    localize.reviewEditButton,
                    style: TextStyle(
                      fontFamily: incidentsFontFamily,
                      fontFamilyFallback: incidentsFontFamilyFallback,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _brandPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              fontFamily: incidentsFontFamily,
              fontFamilyFallback: incidentsFontFamilyFallback,
              fontSize: 13.5,
              color: incidentsBody,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderStrip extends StatelessWidget {
  final String message;
  const _ReminderStrip({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: incidentsTestBannerBg,
        border: Border.all(color: incidentsTestBannerBorder, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline,
              size: 16,
              color: incidentsTestPillFg,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: incidentsFontFamily,
                fontFamilyFallback: incidentsFontFamilyFallback,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: incidentsTestPillFg,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewFooter extends StatelessWidget {
  final bool busy;
  final String submitText;
  final String backText;
  final OnSubmit onSubmit;
  final VoidCallback onBack;

  const _ReviewFooter({
    required this.busy,
    required this.submitText,
    required this.backText,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: incidentsHair, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, -6),
            blurRadius: 18,
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(14, 10, 14, 10 + media.padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: busy ? null : () => onSubmit(),
              style: TextButton.styleFrom(
                backgroundColor: _brandPrimary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _brandTint(0.5),
                disabledForegroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(0, 48),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          submitText,
                          style: const TextStyle(
                            fontFamily: incidentsFontFamily,
                            fontFamilyFallback: incidentsFontFamilyFallback,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.send_rounded, size: 16),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: busy ? null : onBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: incidentsInk,
                side: const BorderSide(color: incidentsHair, width: 1.5),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(0, 44),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                backText,
                style: const TextStyle(
                  fontFamily: incidentsFontFamily,
                  fontFamilyFallback: incidentsFontFamilyFallback,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
