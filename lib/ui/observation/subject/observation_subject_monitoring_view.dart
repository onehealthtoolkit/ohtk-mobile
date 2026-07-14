import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:podd_app/components/motion.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/models/entities/observation_monitoring_definition.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/router.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/observation/subject/observation_subject_monitoring_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ObservationSubjectMonitoringView extends StatelessWidget {
  final ObservationDefinition definition;
  final ObservationSubjectRecord subject;

  const ObservationSubjectMonitoringView({
    Key? key,
    required this.definition,
    required this.subject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.nonReactive(
      viewModelBuilder: () => ObservationSubjectMonitoringViewModel(
        definition: definition,
        subject: subject,
      ),
      builder: (context, model, child) => _MonitoringDefinitionListing(),
    );
  }
}

class _MonitoringDefinitionListing
    extends StackedHookView<ObservationSubjectMonitoringViewModel> {
  @override
  Widget builder(
      BuildContext context, ObservationSubjectMonitoringViewModel viewModel) {
    final definitions = viewModel.observationMonitoringDefinitions;
    if (definitions.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => viewModel.fetchSubjectMonitorings(),
        child: _EmptyState(),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => viewModel.fetchSubjectMonitorings(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          OhtkLayout.pagePad,
          OhtkSpace.lg,
          OhtkLayout.pagePad,
          OhtkSpace.xxl,
        ),
        separatorBuilder: (_, __) =>
            const SizedBox(height: OhtkLayout.sectionGap),
        itemCount: definitions.length,
        itemBuilder: (context, index) {
          final monitoringDefinition = definitions[index];
          return _MonitoringDefinitionSection(
            viewModel: viewModel,
            monitoringDefinition: monitoringDefinition,
          );
        },
      ),
    );
  }
}

class _MonitoringDefinitionSection extends StatelessWidget {
  final ObservationSubjectMonitoringViewModel viewModel;
  final ObservationMonitoringDefinition monitoringDefinition;

  const _MonitoringDefinitionSection({
    required this.viewModel,
    required this.monitoringDefinition,
  });

  @override
  Widget build(BuildContext context) {
    final records =
        viewModel.getSortedMonitoringRecords(monitoringDefinition.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          label: monitoringDefinition.name,
          onAdd: () {
            GoRouter.of(context).goNamed(
              OhtkRouter.observationMonitoringForm,
              pathParameters: {
                'definitionId': viewModel.definition.id.toString(),
                'subjectId': viewModel.subject.id,
                'monitoringDefinitionId': monitoringDefinition.id.toString(),
              },
            );
          },
        ),
        const SizedBox(height: OhtkSpace.sm),
        if (records.isEmpty)
          _SectionEmpty(label: monitoringDefinition.name)
        else
          Column(
            children: [
              for (int i = 0; i < records.length; i++) ...[
                if (i > 0) const SizedBox(height: OhtkLayout.rowGap),
                MonitoringRecordItem(
                  monitoring: records[i],
                  onTap: () {
                    GoRouter.of(context).goNamed(
                      OhtkRouter.observationMonitoringDetail,
                      pathParameters: {
                        'definitionId': viewModel.definition.id.toString(),
                        'subjectId': viewModel.subject.id,
                        'monitoringId': records[i].id,
                      },
                    );
                  },
                ),
              ],
            ],
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final VoidCallback onAdd;

  const _SectionHeader({required this.label, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: OhtkColor.ink900,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(width: OhtkSpace.xs),
        SizedBox(
          height: 32,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: OhtkTheme.palette.teal700,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              minimumSize: const Size(0, 32),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('ADD'),
            onPressed: onAdd,
          ),
        ),
      ],
    );
  }
}

class _SectionEmpty extends StatelessWidget {
  final String label;

  const _SectionEmpty({required this.label});

  @override
  Widget build(BuildContext context) {
    return OhtkCard(
      tone: OhtkCardTone.cream,
      child: Text(
        'No $label entries yet.',
        style: const TextStyle(
          fontSize: 13,
          color: OhtkColor.ink500,
          height: 1.45,
        ),
      ),
    );
  }
}

class MonitoringRecordItem extends StatelessWidget {
  final ObservationMonitoringRecord monitoring;
  final VoidCallback onTap;

  const MonitoringRecordItem({
    Key? key,
    required this.monitoring,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OhtkCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Thumbnail(imageUrl: monitoring.imageUrl),
          const SizedBox(width: OhtkSpace.md),
          Expanded(child: _Content(monitoring: monitoring)),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String? imageUrl;

  const _Thumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: OhtkTheme.palette.teal100,
          borderRadius: OhtkRadius.tile,
        ),
        child: Icon(
          Icons.event_note_outlined,
          color: OhtkTheme.palette.teal700,
          size: 24,
        ),
      );
    }
    return ClipRRect(
      borderRadius: OhtkRadius.tile,
      child: SizedBox(
        width: 56,
        height: 56,
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: OhtkTheme.palette.teal100),
          errorWidget: (_, __, ___) => Container(
            color: OhtkTheme.palette.teal100,
            child: Icon(
              Icons.event_note_outlined,
              color: OhtkTheme.palette.teal700,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final ObservationMonitoringRecord monitoring;

  const _Content({required this.monitoring});

  @override
  Widget build(BuildContext context) {
    final title = monitoring.title.isNotEmpty ? monitoring.title : '—';
    final description = monitoring.description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: OhtkColor.ink900,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: OhtkColor.ink400,
            ),
          ],
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: OhtkColor.ink500,
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                    color: OhtkTheme.palette.teal700.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.event_note_outlined,
                    color: OhtkTheme.palette.teal700,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No monitoring schedule',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: OhtkColor.ink900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "This subject doesn't have monitoring definitions yet.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: OhtkColor.ink500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
