import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:podd_app/components/motion.dart';
import 'package:podd_app/components/submit_success_overlay.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/models/census_definition.dart';
import 'package:podd_app/models/village_census.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/census/census_view_model.dart';
import 'package:podd_app/ui/home/incidents_theme.dart';
import 'package:stacked/stacked.dart';

final _censusDateFormat = DateFormat('dd/MM/yy');

class CensusView extends StatelessWidget {
  final String? kind;

  const CensusView({Key? key, this.kind}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CensusViewModel>.reactive(
      viewModelBuilder: () => CensusViewModel(kind: kind),
      builder: (context, viewModel, _) {
        final localize = AppLocalizations.of(context)!;
        if (viewModel.isBusy) {
          if (kind != null) {
            return _CensusFormScaffold(
              title: _kindTitle(localize, kind),
              body: const _CensusLoading(),
            );
          }
          return const _CensusLoading();
        }

        if (!viewModel.hasCensusAccess) {
          final state = _FullState(
            icon: Icons.lock_outline,
            title: localize.censusUnavailableTitle,
            message: localize.censusUnavailableMessage,
          );
          if (kind != null) {
            return _CensusFormScaffold(
              title: _kindTitle(localize, kind),
              body: state,
            );
          }
          return state;
        }

        if (viewModel.hasError && !viewModel.hasRows) {
          final state = _FullState(
            icon: Icons.cloud_off_outlined,
            title: localize.censusLoadFailedTitle,
            message: viewModel.modelError.toString(),
            actionLabel: localize.tryAgainButton,
            onAction: viewModel.init,
          );
          if (viewModel.isHubMode) {
            return state;
          }
          return _CensusFormScaffold(
            title: viewModel.activeKindName,
            body: state,
          );
        }

        if (viewModel.isHubMode) {
          return _CensusHub(viewModel: viewModel);
        }

        if (viewModel.definitionInactive) {
          return _CensusFormScaffold(
            title: viewModel.activeKindName,
            body: _FullState(
              icon: Icons.pause_circle_outline,
              iconColor: Color(0xFFA07015),
              iconBackground: Color(0x1AA07015),
              title: localize.censusInactiveTitle,
              message: localize.censusInactiveMessage,
              actionLabel: localize.backButton,
              actionIcon: Icons.arrow_back_rounded,
              onAction: () => _goBackToCensusHub(context),
            ),
          );
        }

        if (viewModel.unsupportedSchema) {
          return _CensusFormScaffold(
            title: viewModel.activeKindName,
            body: _FullState(
              icon: Icons.warning_amber_rounded,
              iconColor: Color(0xFFA07015),
              iconBackground: Color(0x1AA07015),
              title: localize.censusUnsupportedTitle,
              message: localize.censusUnsupportedMessage,
            ),
          );
        }

        return _CensusFormScaffold(
          title: viewModel.activeKindName,
          footer: _StickyFooter(viewModel: viewModel),
          body: RefreshIndicator(
            color: incidentsTeal,
            onRefresh: viewModel.init,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _VillageHeader(viewModel: viewModel),
                AnimatedNotice(
                  visible: viewModel.cachedDefinitionNotice != null,
                  child: _NoticeBanner(
                    tone: _NoticeTone.warn,
                    icon: Icons.warning_amber_rounded,
                    text: viewModel.cachedDefinitionNotice ?? '',
                  ),
                ),
                AnimatedNotice(
                  visible: viewModel.oldSnapshotNotice != null,
                  child: _NoticeBanner(
                    tone: _NoticeTone.warn,
                    icon: Icons.history_rounded,
                    text: viewModel.oldSnapshotNotice ?? '',
                  ),
                ),
                AnimatedNotice(
                  visible: viewModel.definitionChanged,
                  child: _NoticeBanner(
                    tone: _NoticeTone.error,
                    icon: Icons.sync_problem_rounded,
                    text: viewModel.definitionChangedMessage,
                    actionLabel:
                        AppLocalizations.of(context)!.censusReloadFormAction,
                    actionIcon: Icons.refresh_rounded,
                    onAction: viewModel.reloadDefinition,
                  ),
                ),
                AnimatedNotice(
                  visible: viewModel.message != null,
                  child: _NoticeBanner(
                    tone: _NoticeTone.ok,
                    icon: Icons.check_circle_outline,
                    text: viewModel.message ?? '',
                  ),
                ),
                AnimatedNotice(
                  visible: viewModel.hasErrorForKey('submit'),
                  child: _NoticeBanner(
                    tone: _NoticeTone.error,
                    icon: Icons.error_outline,
                    text: viewModel.hasErrorForKey('submit')
                        ? viewModel.error('submit').toString()
                        : '',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.formInstruction,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: incidentsMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!viewModel.hasRows)
                        Text(
                          localize.censusNoRowsConfigured,
                          style: const TextStyle(
                            color: incidentsBody,
                          ),
                        )
                      else
                        for (var i = 0; i < viewModel.rows.length; i++)
                          _CensusRowSection(
                            row: viewModel.rows[i],
                            viewModel: viewModel,
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _kindTitle(AppLocalizations localize, String? kind) {
  final normalized = kind?.trim().toUpperCase();
  if (normalized == 'ANIMAL') {
    return localize.censusAnimalTitle;
  }
  if (normalized == 'HUMAN') {
    return localize.censusHumanTitle;
  }
  return localize.censusGenericTitle;
}

class _CensusFormScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? footer;

  const _CensusFormScaffold({
    required this.title,
    required this.body,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: incidentsSand,
      appBar: AppBar(
        backgroundColor: incidentsTealDeep,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => _goBackToCensusHub(context),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: body),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}

void _goBackToCensusHub(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/census');
  }
}

class _CensusHub extends StatelessWidget {
  final CensusViewModel viewModel;

  const _CensusHub({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    if (viewModel.censusKinds.isEmpty) {
      return Column(
        children: [
          _VillageHubHeader(viewModel: viewModel),
          Expanded(
            child: _FullState(
              icon: Icons.info_outline,
              iconColor: incidentsTeal,
              iconBackground: Color(0x1A0F8A82),
              title: localize.censusNoSetupTitle,
              message: localize.censusNoSetupMessage,
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      color: incidentsTeal,
      onRefresh: viewModel.init,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _VillageHubHeader(viewModel: viewModel),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              OhtkLayout.pagePad,
              OhtkSpace.md,
              OhtkLayout.pagePad,
              OhtkSpace.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.censusHubHelperMulti,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: incidentsMuted,
                  ),
                ),
                const SizedBox(height: 14),
                for (final summary in viewModel.censusKinds)
                  _CensusKindCard(
                    summary: summary,
                    onTap: () async {
                      await context
                          .push('/census/${summary.kind.toLowerCase()}');
                      if (context.mounted) {
                        await viewModel.init();
                      }
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CensusKindCard extends StatelessWidget {
  final CensusKindSummary summary;
  final VoidCallback onTap;

  const _CensusKindCard({
    required this.summary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    final snapshot = summary.latestSnapshot;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: OhtkCard(
        onTap: onTap,
        child: Row(
          children: [
            OhtkIconTile(
              size: 44,
              icon: summary.kind == 'HUMAN'
                  ? Icons.groups_outlined
                  : Icons.pets_outlined,
            ),
            const SizedBox(width: OhtkSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _kindTitle(localize, summary.kind),
                    style: OhtkType.h3,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        snapshot != null
                            ? Icons.access_time_rounded
                            : Icons.edit_outlined,
                        size: 13,
                        color: incidentsMuted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          snapshot != null
                              ? localize.censusLastUpdatedLabel(
                                  _dateOnly(snapshot.censusDate),
                                )
                              : localize.censusNotSubmittedYet,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: incidentsMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: incidentsMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  static String _dateOnly(DateTime? date) {
    if (date == null) return '';
    return _censusDateFormat.format(date);
  }
}

class _VillageHubHeader extends StatelessWidget {
  final CensusViewModel viewModel;

  const _VillageHubHeader({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    final village = viewModel.selectedVillage;
    final villageName = village?.name.isNotEmpty == true
        ? village!.name
        : localize.censusNoVillage;
    final district = viewModel.authorityName?.isNotEmpty == true
        ? viewModel.authorityName!
        : '—';

    return Container(
      width: double.infinity,
      color: const Color(0xFFEFEAE0),
      padding: const EdgeInsets.fromLTRB(
        OhtkLayout.pagePad,
        OhtkSpace.lg,
        OhtkLayout.pagePad,
        OhtkSpace.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: incidentsTeal,
              ),
              const SizedBox(width: 6),
              OhtkEyebrow(
                label: localize.villageEyebrow,
                color: incidentsTeal,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            villageName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: OhtkType.h1,
          ),
          const SizedBox(height: 4),
          Text(
            district,
            style: const TextStyle(
              fontSize: 14,
              color: incidentsMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _VillageHeader extends StatelessWidget {
  final CensusViewModel viewModel;

  const _VillageHeader({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final village = viewModel.selectedVillage;
    final freshness = viewModel.freshnessLabel;
    final localize = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        OhtkLayout.pagePad,
        OhtkSpace.md,
        OhtkLayout.pagePad,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const OhtkIconTile(
            size: 44,
            icon: Icons.holiday_village_outlined,
          ),
          const SizedBox(width: OhtkSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  village?.name.isNotEmpty == true
                      ? village!.name
                      : localize.censusNoVillage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: OhtkType.h3,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      freshness == null
                          ? Icons.edit_outlined
                          : Icons.access_time_rounded,
                      size: 14,
                      color: incidentsMuted,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        freshness == null
                            ? localize.censusNoSubmittedYet
                            : localize.censusLastUpdatedLabel(freshness),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: incidentsMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CensusRowSection extends StatelessWidget {
  final CensusSchemaRow row;
  final CensusViewModel viewModel;

  const _CensusRowSection({
    required this.row,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final dirty = viewModel.isRowDirty(row);
    final invalid = viewModel.hasRowErrors(row);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    row.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: incidentsInk,
                    ),
                  ),
                ),
                if (dirty)
                  Text(
                    AppLocalizations.of(context)!.censusEditedBadge,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: incidentsTeal,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          OhtkCard(
            padding: EdgeInsets.zero,
            borderColor: invalid
                ? incidentsErrorRed
                : dirty
                    ? incidentsTeal
                    : incidentsHair,
            boxShadow: invalid
                ? [
                    BoxShadow(
                      color: incidentsErrorRed.withValues(alpha: 0.10),
                      spreadRadius: 3,
                      blurRadius: 0,
                    )
                  ]
                : dirty
                    ? [
                        BoxShadow(
                          color: incidentsTeal.withValues(alpha: 0.10),
                          spreadRadius: 3,
                          blurRadius: 0,
                        )
                      ]
                    : null,
            child: Column(
              children: [
                for (var i = 0; i < viewModel.measures.length; i++)
                  _MeasureInputRow(
                    row: row,
                    measure: viewModel.measures[i],
                    viewModel: viewModel,
                    last: i == viewModel.measures.length - 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasureInputRow extends StatelessWidget {
  final CensusSchemaRow row;
  final CensusSchemaMeasure measure;
  final CensusViewModel viewModel;
  final bool last;

  const _MeasureInputRow({
    required this.row,
    required this.measure,
    required this.viewModel,
    required this.last,
  });

  @override
  Widget build(BuildContext context) {
    final label = measure.label.isNotEmpty ? measure.label : measure.key;
    final errorText = viewModel.measureError(row, measure);
    final isInvalid = errorText != null && errorText.isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: incidentsHair)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                height: 1.2,
                fontWeight: FontWeight.w500,
                color: incidentsBody,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextFormField(
                  key: ValueKey(
                    '${row.rowKey}:${measure.key}:${viewModel.formValueRevision}',
                  ),
                  initialValue: viewModel.measureValue(row.rowKey, measure.key),
                  focusNode: viewModel.focusNodeFor(row, measure),
                  enabled: !viewModel.busy('submit'),
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  textInputAction: viewModel.textInputActionFor(row, measure),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onEditingComplete: () =>
                      viewModel.completeEditing(context, row, measure),
                  onChanged: (value) =>
                      viewModel.setMeasureValue(row.rowKey, measure.key, value),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: incidentsInk,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    filled: viewModel.busy('submit') || isInvalid,
                    fillColor: isInvalid ? Colors.white : incidentsSand,
                    border: _measureInputBorder(
                      isInvalid ? incidentsErrorRed : incidentsHair,
                      1.5,
                    ),
                    enabledBorder: _measureInputBorder(
                      isInvalid ? incidentsErrorRed : incidentsHair,
                      1.5,
                    ),
                    focusedBorder: _measureInputBorder(
                      isInvalid ? incidentsErrorRed : incidentsTeal,
                      1.8,
                    ),
                    errorBorder: _measureInputBorder(incidentsErrorRed, 1.5),
                    focusedErrorBorder:
                        _measureInputBorder(incidentsErrorRed, 1.8),
                  ),
                ),
                if (isInvalid) ...[
                  const SizedBox(height: 6),
                  Text(
                    errorText,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: incidentsErrorRed,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

OutlineInputBorder _measureInputBorder(Color color, double width) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color, width: width),
  );
}

class _StickyFooter extends StatelessWidget {
  final CensusViewModel viewModel;

  const _StickyFooter({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: OhtkColor.line)),
        boxShadow: OhtkShadow.sticky,
      ),
      padding: const EdgeInsets.fromLTRB(
        OhtkLayout.pagePad,
        OhtkSpace.sm,
        OhtkLayout.pagePad,
        18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (viewModel.hasDraft) ...[
            _DraftFooterNote(viewModel: viewModel),
            const SizedBox(height: 10),
            const Divider(height: 1, thickness: 1, color: OhtkColor.line),
            const SizedBox(height: 14),
          ],
          OhtkPrimaryButton(
            label: AppLocalizations.of(context)!.censusSaveCurrentButton,
            loading: viewModel.busy('submit'),
            onPressed: viewModel.canSubmit
                ? () async {
                    final result = await viewModel.submit();
                    if (context.mounted &&
                        result is VillageCensusSubmitSuccess) {
                      await SubmitSuccessOverlay.show(
                        context,
                        message: AppLocalizations.of(context)!
                            .censusSubmittedMessage,
                      );
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class _DraftFooterNote extends StatelessWidget {
  final CensusViewModel viewModel;

  const _DraftFooterNote({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(
            Icons.circle,
            size: 8,
            color: Color(0xFFA07015),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            viewModel.draftSavedNotice,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: incidentsMuted,
            ),
          ),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed:
              viewModel.busy('submit') ? null : () => viewModel.discardDraft(),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFA07015),
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: Text(localize.censusDiscardDraftAction),
        ),
      ],
    );
  }
}

enum _NoticeTone { ok, warn, error }

class _NoticeBanner extends StatelessWidget {
  final _NoticeTone tone;
  final IconData icon;
  final String text;
  final String? actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;

  const _NoticeBanner({
    required this.tone,
    required this.icon,
    required this.text,
    this.actionLabel,
    this.actionIcon = Icons.refresh_rounded,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      _NoticeTone.ok => incidentsTeal,
      _NoticeTone.warn => const Color(0xFFA07015),
      _NoticeTone.error => incidentsErrorRed,
    };
    final background = switch (tone) {
      _NoticeTone.ok => incidentsTeal.withValues(alpha: 0.10),
      _NoticeTone.warn => const Color(0x1AA07015),
      _NoticeTone.error => incidentsErrorTint,
    };
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onAction,
                icon: Icon(actionIcon, size: 16),
                label: Text(actionLabel!),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  minimumSize: const Size.fromHeight(40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FullState extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String message;
  final String? actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;

  const _FullState({
    required this.icon,
    required this.title,
    required this.message,
    this.iconColor = incidentsErrorRed,
    this.iconBackground = incidentsErrorTint,
    this.actionLabel,
    this.actionIcon = Icons.refresh,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
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
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: incidentsInk,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.55,
                color: incidentsMuted,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(actionIcon, size: 15),
                label: Text(actionLabel!.toUpperCase()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: incidentsTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CensusLoading extends StatelessWidget {
  const _CensusLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(14),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Skeleton(width: 120, height: 12),
              SizedBox(height: 8),
              _Skeleton(width: 240, height: 15),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: const [
              _SkeletonCard(),
              SizedBox(height: 12),
              _SkeletonCard(),
              SizedBox(height: 12),
              _SkeletonCard(),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: incidentsHair),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Skeleton(width: 120, height: 14),
          SizedBox(height: 14),
          _Skeleton(width: double.infinity, height: 42),
          SizedBox(height: 8),
          _Skeleton(width: double.infinity, height: 42),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  final double width;
  final double height;

  const _Skeleton({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: incidentsHair.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
