import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:podd_app/components/motion.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/router.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/observation/observation_subject_list_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ObservationSubjectListView extends StatelessWidget {
  final ObservationDefinition definition;

  const ObservationSubjectListView({
    Key? key,
    required this.definition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.nonReactive(
      viewModelBuilder: () => ObservationSubjectListViewModel(definition),
      builder: (context, model, child) => _SubjectListing(),
    );
  }
}

class _SubjectListing extends StackedHookView<ObservationSubjectListViewModel> {
  @override
  Widget builder(
      BuildContext context, ObservationSubjectListViewModel viewModel) {
    if (viewModel.observationSubjects.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => viewModel.refetchSubjects(),
        child: _EmptyState(),
      );
    }

    final localize = AppLocalizations.of(context)!;
    final showLoadMore = viewModel.hasMoreSubjectRecords;

    return RefreshIndicator(
      onRefresh: () async => viewModel.refetchSubjects(),
      child: ListView.separated(
        key: const PageStorageKey('subject-list-storage-key'),
        addAutomaticKeepAlives: true,
        padding: const EdgeInsets.fromLTRB(
          OhtkLayout.pagePad,
          OhtkSpace.lg,
          OhtkLayout.pagePad,
          120,
        ),
        separatorBuilder: (_, __) => const SizedBox(height: OhtkLayout.rowGap),
        itemCount:
            viewModel.observationSubjects.length + (showLoadMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= viewModel.observationSubjects.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: OhtkSpace.md),
              child: OhtkSecondaryButton(
                label: localize.loadMore,
                onPressed: viewModel.continueFetchSubjects,
              ),
            );
          }

          final subject = viewModel.observationSubjects[index];
          return SubjectRecordItem(
            subject: subject,
            onTap: () {
              GoRouter.of(context).goNamed(
                OhtkRouter.observationSubjectDetail,
                pathParameters: {
                  'definitionId': viewModel.definition.id.toString(),
                  'subjectId': subject.id,
                },
              );
            },
          );
        },
      ),
    );
  }
}

class SubjectRecordItem extends StatelessWidget {
  final ObservationSubjectRecord subject;
  final VoidCallback onTap;

  const SubjectRecordItem({
    Key? key,
    required this.subject,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OhtkCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Thumbnail(imageUrl: subject.imageUrl),
          const SizedBox(width: OhtkSpace.md),
          Expanded(child: _Content(subject: subject)),
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
      return const _FallbackTile();
    }
    return ClipRRect(
      borderRadius: OhtkRadius.tile,
      child: SizedBox(
        width: 64,
        height: 64,
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: OhtkTheme.palette.teal100),
          errorWidget: (_, __, ___) => const _FallbackTile(),
        ),
      ),
    );
  }
}

class _FallbackTile extends StatelessWidget {
  const _FallbackTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: OhtkTheme.palette.teal100,
        borderRadius: OhtkRadius.tile,
      ),
      child: Icon(
        Icons.visibility_outlined,
        color: OhtkTheme.palette.teal700,
        size: 28,
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final ObservationSubjectRecord subject;

  const _Content({required this.subject});

  @override
  Widget build(BuildContext context) {
    final title = subject.title.isNotEmpty ? subject.title : '—';
    final description = subject.description;
    final identity = subject.identity;

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
                  fontSize: 16,
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
        if (identity.isNotEmpty) ...[
          const SizedBox(height: 6),
          OhtkChip(label: identity, small: true),
        ],
        if (description.isNotEmpty) ...[
          const SizedBox(height: 6),
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
                    Icons.visibility_outlined,
                    color: OhtkTheme.palette.teal700,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No subjects yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: OhtkColor.ink900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tap the + button to add your first subject.',
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
