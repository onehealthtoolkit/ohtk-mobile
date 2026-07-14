import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:podd_app/components/submit_success_overlay.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/router.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/home/incidents_theme.dart';
import 'package:podd_app/ui/report_type/report_type_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

final _zeroReportTimestamp = DateFormat('dd/MM · HH:mm');

Color get _brandPrimary => OhtkTheme.palette.teal700;
Color get _brandDeep => OhtkTheme.palette.teal900;
Color _brandTint(double alpha) =>
    OhtkTheme.palette.teal700.withValues(alpha: alpha);

class ReportTypeView extends StatelessWidget {
  const ReportTypeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReportTypeViewModel>.reactive(
      viewModelBuilder: () => ReportTypeViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        backgroundColor: incidentsSand,
        body: Column(
          children: [
            const _ChooserAppBar(),
            const _UtilityRow(),
            const _TestBanner(),
            Expanded(child: _ChooserBody(viewModel: viewModel)),
            const _ZeroReportFooter(),
          ],
        ),
      ),
    );
  }
}

class _ChooserAppBar extends StatelessWidget {
  const _ChooserAppBar();

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      color: _brandDeep,
      padding: EdgeInsets.fromLTRB(12, topInset + 10, 12, 10),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              onPressed: () => GoRouter.of(context).pop(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 40),
              child: Text(
                localize.reportTypeTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: incidentsFontFamily,
                  fontFamilyFallback: incidentsFontFamilyFallback,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UtilityRow extends StackedHookView<ReportTypeViewModel> {
  const _UtilityRow();

  @override
  Widget builder(BuildContext context, ReportTypeViewModel viewModel) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: incidentsHair, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          _TestModeChip(
            on: viewModel.testFlag,
            onToggle: () => viewModel.testFlag = !viewModel.testFlag,
          ),
        ],
      ),
    );
  }
}

class _TestModeChip extends StatelessWidget {
  final bool on;
  final VoidCallback onToggle;

  const _TestModeChip({required this.on, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    final fg = on ? incidentsTestPillFg : incidentsMuted;
    final bg = on ? incidentsTestPillBg : incidentsSand;
    final border = on ? incidentsTestPillBorder : incidentsHair;
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: 1),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, size: 15, color: fg),
            const SizedBox(width: 8),
            Text(
              localize.testModeLabel.toUpperCase(),
              style: TextStyle(
                fontFamily: incidentsFontFamily,
                fontFamilyFallback: incidentsFontFamilyFallback,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: fg,
              ),
            ),
            const SizedBox(width: 8),
            _MiniSwitch(on: on, fg: fg),
          ],
        ),
      ),
    );
  }
}

class _MiniSwitch extends StatelessWidget {
  final bool on;
  final Color fg;

  const _MiniSwitch({required this.on, required this.fg});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 16,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: on ? fg : incidentsHair,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 150),
            top: 2,
            left: on ? 14 : 2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestBanner extends StackedHookView<ReportTypeViewModel> {
  const _TestBanner();

  @override
  Widget builder(BuildContext context, ReportTypeViewModel viewModel) {
    if (!viewModel.testFlag) return const SizedBox.shrink();
    final localize = AppLocalizations.of(context)!;
    return Container(
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
                fontFamily: incidentsFontFamily,
                fontFamilyFallback: incidentsFontFamilyFallback,
                fontSize: 12,
                fontWeight: FontWeight.w600,
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

class _ChooserBody extends StatelessWidget {
  final ReportTypeViewModel viewModel;

  const _ChooserBody({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final visibleCategories = viewModel.categories
        .where((c) => c.reportTypes.isNotEmpty)
        .toList(growable: false);

    return RefreshIndicator(
      color: _brandPrimary,
      onRefresh: () async {
        await viewModel.syncReportTypes();
      },
      child: visibleCategories.isEmpty
          ? _EmptyState(onRetry: () => viewModel.syncReportTypes())
          : _CategoryList(
              categories: visibleCategories,
              viewModel: viewModel,
            ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final List<CategoryAndReportType> categories;
  final ReportTypeViewModel viewModel;

  const _CategoryList({required this.categories, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionEyebrow(label: cat.category.name),
            ...cat.reportTypes.map(
              (rt) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _TypeRow(
                  reportType: rt,
                  categoryIconUrl: cat.category.icon,
                  onTap: () async {
                    final allow = await viewModel.createReport(rt.id);
                    if (allow && context.mounted) {
                      GoRouter.of(context).pushReplacementNamed(
                        OhtkRouter.reportForm,
                        pathParameters: {'reportTypeId': rt.id},
                        queryParameters: {
                          'test': viewModel.testFlag ? '1' : '0'
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  final String label;

  const _SectionEyebrow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: _brandPrimary,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
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
    );
  }
}

class _TypeRow extends StatelessWidget {
  final ReportType reportType;
  final String categoryIconUrl;
  final VoidCallback onTap;

  const _TypeRow({
    required this.reportType,
    required this.categoryIconUrl,
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
            children: [
              _CategoryIconTile(iconUrl: categoryIconUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  reportType.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: incidentsFontFamily,
                    fontFamilyFallback: incidentsFontFamilyFallback,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: incidentsInk,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.chevron_right,
                size: 22,
                color: incidentsMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryIconTile extends StatelessWidget {
  final String iconUrl;

  const _CategoryIconTile({required this.iconUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _brandTint(0.10),
        borderRadius: BorderRadius.circular(11),
      ),
      padding: const EdgeInsets.all(8),
      child: iconUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: iconUrl,
              fit: BoxFit.contain,
              color: _brandPrimary,
              colorBlendMode: BlendMode.srcIn,
              placeholder: (context, url) => const SizedBox.shrink(),
              errorWidget: (context, url, error) => Icon(
                Icons.assignment_outlined,
                size: 22,
                color: _brandPrimary,
              ),
            )
          : Icon(
              Icons.assignment_outlined,
              size: 22,
              color: _brandPrimary,
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 56, 28, 28),
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _brandTint(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code_2,
              size: 32,
              color: _brandPrimary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          localize.noReportTypesTitle,
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
          localize.noReportTypesHelper,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: incidentsFontFamily,
            fontFamilyFallback: incidentsFontFamilyFallback,
            fontSize: 12.5,
            height: 1.5,
            color: incidentsMuted,
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh, size: 16, color: _brandPrimary),
            label: Text(
              localize.tryAgainButton,
              style: TextStyle(
                fontFamily: incidentsFontFamily,
                fontFamilyFallback: incidentsFontFamilyFallback,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _brandPrimary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              side: BorderSide(color: _brandPrimary, width: 1.5),
              shape: const StadiumBorder(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ZeroReportFooter extends StackedHookView<ReportTypeViewModel> {
  const _ZeroReportFooter();

  @override
  Widget builder(BuildContext context, ReportTypeViewModel viewModel) {
    final localize = AppLocalizations.of(context)!;
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shouldStackAction = constraints.maxWidth < 360 ||
              localize.zeroReportPillLabel.length > 14;

          Widget statusIcon() {
            return Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _brandTint(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 18,
                color: _brandPrimary,
              ),
            );
          }

          Widget statusCopy() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  localize.nothingToReportTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: incidentsFontFamily,
                    fontFamilyFallback: incidentsFontFamilyFallback,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: incidentsInk,
                  ),
                ),
                const SizedBox(height: 1),
                _LastZeroReport(viewModel: viewModel),
              ],
            );
          }

          final statusRow = Row(
            children: [
              statusIcon(),
              const SizedBox(width: 12),
              Expanded(child: statusCopy()),
            ],
          );

          if (shouldStackAction) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                statusRow,
                const SizedBox(height: 10),
                _ZeroReportButton(viewModel: viewModel, expand: true),
              ],
            );
          }

          return Row(
            children: [
              statusIcon(),
              const SizedBox(width: 12),
              Expanded(child: statusCopy()),
              const SizedBox(width: 12),
              _ZeroReportButton(viewModel: viewModel),
            ],
          );
        },
      ),
    );
  }
}

class _LastZeroReport extends StatelessWidget {
  final ReportTypeViewModel viewModel;

  const _LastZeroReport({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return FutureBuilder<DateTime?>(
      future: viewModel.getLatestZeroReport(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            !snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final stamp = _zeroReportTimestamp.format(snapshot.data!.toLocal());
        return Text(
          localize.lastZeroReportLabel(stamp),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: incidentsFontFamily,
            fontFamilyFallback: incidentsFontFamilyFallback,
            fontSize: 11,
            color: incidentsMuted,
            height: 1.3,
          ),
        );
      },
    );
  }
}

class _ZeroReportButton extends StatelessWidget {
  final ReportTypeViewModel viewModel;
  final bool expand;

  const _ZeroReportButton({required this.viewModel, this.expand = false});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    final button = TextButton(
      onPressed: () async {
        final success = await viewModel.submitZeroReport();
        if (context.mounted) {
          _showZeroReportResult(context, success);
        }
      },
      style: TextButton.styleFrom(
        backgroundColor: _brandPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: const StadiumBorder(),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        localize.zeroReportPillLabel,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: incidentsFontFamily,
          fontFamilyFallback: incidentsFontFamilyFallback,
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  void _showZeroReportResult(BuildContext context, bool success) {
    final localize = AppLocalizations.of(context)!;
    if (success) {
      SubmitSuccessOverlay.show(
        context,
        message: localize.zeroReportSubmitSuccess,
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Text(
          'Failed to submit',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: incidentsFontFamily,
            fontFamilyFallback: incidentsFontFamilyFallback,
            fontSize: 14,
            color: incidentsErrorRed,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: _brandPrimary,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            ),
            child: Text(
              localize.ok,
              style: const TextStyle(
                fontFamily: incidentsFontFamily,
                fontFamilyFallback: incidentsFontFamilyFallback,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
