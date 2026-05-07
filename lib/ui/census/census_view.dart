import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:podd_app/components/flat_button.dart';
import 'package:podd_app/models/animal_species.dart';
import 'package:podd_app/models/village_census.dart';
import 'package:podd_app/ui/census/census_view_model.dart';
import 'package:stacked/stacked.dart';

class CensusView extends StatelessWidget {
  const CensusView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CensusViewModel>.reactive(
      viewModelBuilder: () => CensusViewModel(),
      builder: (context, viewModel, _) {
        if (viewModel.isBusy) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: viewModel.init,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            children: [
              Text(
                'Village census',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(viewModel.selectedVillage?.displayName ?? 'No village'),
              const SizedBox(height: 20),
              if (!viewModel.hasCensusAccess)
                const Text('Census is not available for this account.'),
              if (viewModel.hasError)
                Text(
                  viewModel.modelError.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              if (viewModel.cacheMessage != null) ...[
                Text(
                  viewModel.cacheMessage!,
                  style: TextStyle(color: Colors.orange.shade800),
                ),
                const SizedBox(height: 12),
              ],
              if (viewModel.hasCensusAccess) ...[
                _LatestCensus(snapshot: viewModel.latestCensus),
                const SizedBox(height: 24),
                if (!viewModel.hasSpecies)
                  const Text('No active animal species are configured.'),
                if (viewModel.hasSpecies) _CensusForm(viewModel: viewModel),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _LatestCensus extends StatelessWidget {
  final VillageCensusSnapshot? snapshot;

  const _LatestCensus({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Latest census', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (snapshot == null)
          const Text('No census has been submitted yet.')
        else ...[
          Text('Date: ${_dateLabel(snapshot!.censusDate)}'),
          const SizedBox(height: 8),
          for (final fact in snapshot!.facts)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '${fact.species.displayName}: '
                '${fact.animalQuantity} animals, '
                '${fact.householdQuantity} households',
              ),
            ),
        ],
      ],
    );
  }

  String _dateLabel(DateTime? date) {
    if (date == null) {
      return '-';
    }
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class _CensusForm extends StatelessWidget {
  final CensusViewModel viewModel;

  const _CensusForm({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Submit census', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        if (viewModel.hasDraft) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Draft saved',
                  style: TextStyle(color: Colors.blueGrey.shade700),
                ),
              ),
              TextButton(
                onPressed: viewModel.discardDraft,
                child: const Text('Discard'),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        for (final item in viewModel.species)
          _SpeciesQuantityRow(item, viewModel),
        if (viewModel.hasErrorForKey('submit')) ...[
          const SizedBox(height: 12),
          Text(
            viewModel.error('submit'),
            style: const TextStyle(color: Colors.red),
          ),
        ],
        if (viewModel.message != null) ...[
          const SizedBox(height: 12),
          Text(
            viewModel.message!,
            style: TextStyle(color: Colors.green.shade700),
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FlatButton.primary(
            onPressed:
                viewModel.busy('submit') ? null : () => viewModel.submit(),
            child: viewModel.busy('submit')
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Text('Submit census', style: TextStyle(fontSize: 15.sp)),
          ),
        ),
      ],
    );
  }
}

class _SpeciesQuantityRow extends StatelessWidget {
  final AnimalSpecies species;
  final CensusViewModel viewModel;

  const _SpeciesQuantityRow(this.species, this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(species.displayName),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: ValueKey(
                    'animal-${species.id}-${viewModel.fieldVersion}',
                  ),
                  initialValue: viewModel.animalQuantities[species.id] ?? '',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) =>
                      viewModel.setAnimalQuantity(species.id, value),
                  decoration: const InputDecoration(
                    labelText: 'Animals',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  key: ValueKey(
                    'household-${species.id}-${viewModel.fieldVersion}',
                  ),
                  initialValue: viewModel.householdQuantities[species.id] ?? '',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) =>
                      viewModel.setHouseholdQuantity(species.id, value),
                  decoration: const InputDecoration(
                    labelText: 'Households',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
