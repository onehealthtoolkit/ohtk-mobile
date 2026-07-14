import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:podd_app/components/motion.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/opsv_form/opsv_form.dart' as opsv;
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/home/incidents_theme.dart';

const _appBarHeight = OhtkLayout.headerH;

class FormChromeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBack;

  const FormChromeAppBar({
    required this.title,
    required this.onBack,
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(_appBarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: OhtkTheme.palette.teal900,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: _appBarHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 40, minHeight: 40),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBack,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
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

class FormChromeTestBanner extends StatelessWidget {
  final bool testFlag;

  const FormChromeTestBanner({required this.testFlag, super.key});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return AnimatedNotice(
      visible: testFlag,
      child: Container(
        decoration: const BoxDecoration(
          color: incidentsTestBannerBg,
          border: Border(
            bottom: BorderSide(color: incidentsTestBannerBorder, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 14,
              color: incidentsTestPillFg,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                localize.testModeBannerMessage,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: incidentsTestPillFg,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FormChromeProgressStrip extends StatelessWidget {
  final opsv.Form form;

  const FormChromeProgressStrip({required this.form, super.key});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final total = form.numberOfSections;
        if (total <= 1) return const SizedBox.shrink();
        final localize = AppLocalizations.of(context)!;
        final current = form.currentSectionIdx;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: incidentsHair, width: 1),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    localize.formStepLabel(current + 1, total).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: incidentsMuted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      form.currentSection.label,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: incidentsInk,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(total, (i) {
                  final isPast = i < current;
                  final isCurrent = i == current;
                  final color = isCurrent
                      ? incidentsAccent
                      : isPast
                          ? OhtkTheme.palette.teal700
                          : incidentsHair;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: i == total - 1 ? 0 : 4,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        height: 4,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FormChromeFooter extends StatelessWidget {
  final bool canGoBack;
  final bool isLastSection;
  final bool isReviewing;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const FormChromeFooter({
    required this.canGoBack,
    required this.isLastSection,
    required this.isReviewing,
    required this.onBack,
    required this.onNext,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    final media = MediaQuery.of(context);
    final nextLabel = isLastSection
        ? localize.formChromeReviewLabel
        : localize.formChromeNextLabel;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: OhtkColor.line, width: 1)),
        boxShadow: OhtkShadow.sticky,
      ),
      padding: EdgeInsets.fromLTRB(14, 10, 14, 10 + media.padding.bottom),
      child: Row(
        children: [
          SizedBox(
            height: 44,
            child: OhtkSecondaryButton(
              label: localize.formChromeBackLabel,
              onPressed: canGoBack ? onBack : null,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 150,
            height: 44,
            child: OhtkPrimaryButton(
              label: nextLabel,
              onPressed: onNext,
              icon: Icon(
                isLastSection ? Icons.check : Icons.arrow_forward,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> showExitConfirmDialog(BuildContext context) async {
  final localize = AppLocalizations.of(context)!;
  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black54,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: incidentsTestBannerBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 28,
                color: incidentsTestPillFg,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              localize.exitDialogTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: incidentsInk,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localize.exitDialogBody,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: incidentsMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: TextButton.styleFrom(
                  backgroundColor: incidentsErrorRed,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  localize.exitDialogDiscardButton,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: incidentsInk,
                  side: const BorderSide(color: incidentsHair, width: 1),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  localize.exitDialogKeepButton,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}
