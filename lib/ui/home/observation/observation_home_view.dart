import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:podd_app/components/motion.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/router.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/home/observation/observation_home_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ObservationHomeView extends StatelessWidget {
  const ObservationHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ObservationHomeViewModel>.nonReactive(
      viewModelBuilder: () => ObservationHomeViewModel(),
      builder: (context, viewModel, child) => RefreshIndicator(
        onRefresh: () => viewModel.syncDefinitions(),
        child: _Listing(),
      ),
    );
  }
}

class _Listing extends StackedHookView<ObservationHomeViewModel> {
  @override
  Widget builder(BuildContext context, ObservationHomeViewModel viewModel) {
    if (viewModel.isBusy) {
      return const Center(child: OhtkProgressIndicator(size: 100));
    }

    final definitions = viewModel.observationDefinitions;
    if (definitions.isEmpty) {
      return _EmptyState();
    }

    return ListView.separated(
      key: const PageStorageKey('observation-definitions'),
      padding: const EdgeInsets.fromLTRB(
        OhtkLayout.pagePad,
        OhtkSpace.lg,
        OhtkLayout.pagePad,
        120,
      ),
      itemCount: definitions.length,
      separatorBuilder: (_, __) => const SizedBox(height: OhtkLayout.rowGap),
      itemBuilder: (context, index) {
        final definition = definitions[index];
        return OhtkCard(
          onTap: () {
            GoRouter.of(context).goNamed(
              OhtkRouter.observationSubjects,
              pathParameters: {
                'definitionId': definition.id.toString(),
              },
            );
          },
          child: Row(
            children: [
              const OhtkIconTile(icon: Icons.visibility_outlined),
              const SizedBox(width: OhtkSpace.md),
              Expanded(
                child: Text(
                  definition.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: OhtkColor.ink900,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: OhtkSpace.sm),
              const Icon(
                Icons.chevron_right_rounded,
                color: OhtkColor.ink400,
                size: 22,
              ),
            ],
          ),
        );
      },
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
              Text(
                localize.observationsTabTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: OhtkColor.ink900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
