import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/census_definition.dart';
import 'package:podd_app/models/login_result.dart';
import 'package:podd_app/models/user_profile.dart';
import 'package:podd_app/models/village.dart';
import 'package:podd_app/models/village_census.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/census_service.dart';
import 'package:podd_app/services/feature_capability_service.dart';
import 'package:podd_app/ui/census/census_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthServiceMock authService;
  late CensusServiceMock censusService;
  late FeatureCapabilityServiceMock featureCapabilityService;

  setUp(() async {
    await locator.reset();
    locator.allowReassignment = true;
    authService = AuthServiceMock();
    censusService = CensusServiceMock();
    featureCapabilityService = FeatureCapabilityServiceMock();
    locator.registerSingleton<IAuthService>(authService);
    locator.registerSingleton<ICensusService>(censusService);
    locator.registerSingleton<IFeatureCapabilityService>(
      featureCapabilityService,
    );
    locator.registerSingleton<AppLocalizations>(
      await AppLocalizations.delegate.load(const Locale('en')),
    );
  });

  test('shows old snapshot notice and does not prefill incompatible rows',
      () async {
    censusService.activeDefinition = humanDefinition(
      id: 3,
      version: 2,
      rows: const [
        CensusSchemaRow(rowKey: 'total', label: 'Total'),
      ],
    );
    censusService.latestV2 = VillageCensusSnapshot(
      id: 8,
      censusDate: DateTime.parse('2026-05-21'),
      definitionVersionId: 2,
      definitionVersionNumber: 1,
      formData: const {
        'rows': [
          {
            'row_key': 'male',
            'measures': {'population': 1910},
          },
          {
            'row_key': 'female',
            'measures': {'population': 2000},
          },
        ],
      },
    );

    final viewModel = CensusViewModel(kind: 'HUMAN');
    await flushAsync();

    expect(viewModel.activeDefinition?.id, 3);
    expect(viewModel.latestSnapshotUsesOlderDefinition, isTrue);
    expect(viewModel.latestSnapshotPrefilledAnyValue, isFalse);
    expect(viewModel.measureValue('total', 'population'), '');
    expect(
      viewModel.formInstruction,
      'Previous submission used an older form. Enter current values for this version.',
    );
  });

  test('hides old snapshot warning when all values fit current form', () async {
    censusService.activeDefinition = humanDefinition(
      id: 5,
      version: 4,
      rows: const [
        CensusSchemaRow(rowKey: 'total', label: 'Total'),
      ],
    );
    censusService.latestV2 = VillageCensusSnapshot(
      id: 20,
      censusDate: DateTime.parse('2026-05-26'),
      definitionVersionId: 3,
      definitionVersionNumber: 2,
      formData: const {
        'rows': [
          {
            'row_key': 'total',
            'measures': {'population': 225},
          },
        ],
      },
    );

    final viewModel = CensusViewModel(kind: 'HUMAN');
    await flushAsync();

    expect(viewModel.latestSnapshotUsesOlderDefinition, isTrue);
    expect(viewModel.latestSnapshotPrefilledAnyValue, isTrue);
    expect(viewModel.latestSnapshotPrefilledAllValues, isTrue);
    expect(viewModel.measureValue('total', 'population'), '225');
    expect(viewModel.oldSnapshotNotice, isNull);
    expect(
      viewModel.formInstruction,
      'Update anything that has changed. Numbers from the last submission are pre-filled.',
    );
  });

  test('uses localized census row and measure labels for current app locale',
      () async {
    locator.registerSingleton<AppLocalizations>(
      await AppLocalizations.delegate.load(const Locale('lo')),
    );
    censusService.activeDefinition = CensusDefinitionVersion(
      id: 7,
      version: 1,
      status: 'PUBLISHED',
      runtimeSchema: CensusRuntimeSchema(
        rows: [
          CensusSchemaRow(
            rowKey: 'species:1',
            label: 'Cattle',
            labelI18n: const {'la': 'ງົວ'},
          ),
        ],
        measures: [
          CensusSchemaMeasure(
            key: 'animal_quantity',
            label: 'Animal quantity',
            labelI18n: const {'la': 'ຈຳນວນສັດ'},
            type: 'integer',
            required: true,
          ),
        ],
      ),
    );

    final viewModel = CensusViewModel(kind: 'ANIMAL');
    await flushAsync();

    expect(viewModel.rows.single.label, 'ງົວ');
    expect(viewModel.measures.single.label, 'ຈຳນວນສັດ');
  });

  test('uses localized census kind title instead of API summary name',
      () async {
    locator.registerSingleton<AppLocalizations>(
      await AppLocalizations.delegate.load(const Locale('lo')),
    );

    final viewModel = CensusViewModel(kind: 'ANIMAL');
    viewModel.activeKindSummary = const CensusKindSummary(
      kind: 'ANIMAL',
      name: 'Animal census',
      enabled: true,
    );
    viewModel.activeKind = 'ANIMAL';
    await flushAsync();

    expect(viewModel.activeKindName, 'ສຳມະໂນສັດ');
  });

  test('stale definition submit shows reload state and reload preserves values',
      () async {
    censusService.activeDefinition = humanDefinition(
      id: 2,
      version: 1,
      rows: const [
        CensusSchemaRow(rowKey: 'total', label: 'Total'),
      ],
    );
    censusService.submitResult = CensusDefinitionChanged(
      const ['census definition version must be published'],
    );

    final viewModel = CensusViewModel(kind: 'HUMAN');
    await flushAsync();
    viewModel.setMeasureValue('total', 'population', '123');

    final result = await viewModel.submit();

    expect(result, isA<CensusDefinitionChanged>());
    expect(viewModel.definitionChanged, isTrue);
    expect(viewModel.canSubmit, isFalse);
    expect(viewModel.definitionChangedMessage, contains('Reload'));

    censusService.activeDefinition = humanDefinition(
      id: 3,
      version: 2,
      rows: const [
        CensusSchemaRow(rowKey: 'total', label: 'Total'),
      ],
    );

    await viewModel.reloadDefinition();

    expect(viewModel.definitionChanged, isFalse);
    expect(viewModel.activeDefinition?.id, 3);
    expect(viewModel.measureValue('total', 'population'), '123');
    expect(viewModel.message, 'Census form reloaded.');
    expect(
      censusService
          .draftFor(
            villageId: 1,
            kind: 'HUMAN',
            definitionVersionId: 3,
          )
          ?.measureValues['total']?['population'],
      '123',
    );
  });

  test('animal species change submit shows reload state without raw code',
      () async {
    censusService.activeDefinition = animalDefinition();
    censusService.submitResult = CensusDefinitionChanged(
      const ['ACTIVE_ANIMAL_SPECIES_CHANGED'],
    );

    final viewModel = CensusViewModel(kind: 'ANIMAL');
    await flushAsync();
    fillAnimalSummary(viewModel);
    viewModel.setMeasureValue('species:1', 'animal_quantity', '10');
    viewModel.setMeasureValue('species:1', 'household_quantity', '5');

    final result = await viewModel.submit();

    expect(result, isA<CensusDefinitionChanged>());
    expect(viewModel.definitionChanged, isTrue);
    expect(viewModel.canSubmit, isFalse);
    expect(viewModel.hasErrorForKey('submit'), isFalse);
    expect(viewModel.definitionChangedMessage, isNot(contains('ACTIVE_')));
    expect(viewModel.definitionChangedMessage, contains('Reload'));
  });

  test('blank census measures are marked on the matching fields', () async {
    censusService.activeDefinition = animalDefinition();

    final viewModel = CensusViewModel(kind: 'ANIMAL');
    await flushAsync();
    fillAnimalSummary(viewModel);
    viewModel.setMeasureValue('species:1', 'animal_quantity', '10');

    final result = await viewModel.submit();

    expect(result, isNull);
    expect(viewModel.hasErrorForKey('submit'), isFalse);
    expect(
      viewModel.hasMeasureError(
        viewModel.rows.single,
        viewModel.measures.first,
      ),
      isFalse,
    );
    expect(
      viewModel.hasMeasureError(
        viewModel.rows.single,
        viewModel.measures.last,
      ),
      isTrue,
    );
    expect(
      viewModel.measureError(viewModel.rows.single, viewModel.measures.last),
      'This field is required',
    );
  });

  test('direct inactive human census route does not show unsupported schema',
      () async {
    censusService.activeDefinition = null;

    final viewModel = CensusViewModel(kind: 'HUMAN');
    await flushAsync();

    expect(viewModel.definitionInactive, isTrue);
    expect(viewModel.unsupportedSchema, isFalse);
    expect(viewModel.hasRows, isFalse);
    expect(viewModel.canSubmit, isFalse);
  });

  test('census tab stays on hub when only one census is active', () async {
    censusService.activeKinds = [
      CensusKindSummary(
        kind: 'ANIMAL',
        name: 'Animal census',
        enabled: true,
        activeVersion: humanDefinition(
          id: 1,
          version: 1,
          rows: const [
            CensusSchemaRow(
              rowKey: 'species:1',
              label: 'Cattle',
            ),
          ],
        ),
      ),
    ];

    final viewModel = CensusViewModel();
    await flushAsync();

    expect(viewModel.isHubMode, isTrue);
    expect(viewModel.censusKinds, hasLength(1));
    expect(viewModel.censusKinds.single.kind, 'ANIMAL');
    expect(viewModel.hasRows, isFalse);
    expect(viewModel.activeDefinition, isNull);
  });

  test('training toggle updates immediately before async reload completes',
      () async {
    censusService.activeKinds = [
      CensusKindSummary(
        kind: 'ANIMAL',
        name: 'Animal census',
        enabled: true,
        activeVersion: animalDefinition(),
      ),
    ];
    censusService.openOccurrences = [
      const CensusRoundOccurrence(
        id: 17,
        occurrenceKey: 'ANIMAL_TRAINING_2026',
        kind: 'ANIMAL',
        mode: 'TRAINING',
        status: 'OPEN',
      ),
    ];

    final viewModel = CensusViewModel();
    await flushAsync();

    final pendingToggle = viewModel.setTrainingMode(true);

    expect(viewModel.trainingMode, isTrue);
    await pendingToggle;
  });

  test('reload clears incompatible values after definition shape changes',
      () async {
    censusService.activeDefinition = humanDefinition(
      id: 2,
      version: 1,
      rows: const [
        CensusSchemaRow(rowKey: 'male', label: 'Male'),
        CensusSchemaRow(rowKey: 'female', label: 'Female'),
      ],
    );

    final viewModel = CensusViewModel(kind: 'HUMAN');
    await flushAsync();
    viewModel.setMeasureValue('male', 'population', '1910');
    viewModel.setMeasureValue('female', 'population', '2000');

    censusService.activeDefinition = humanDefinition(
      id: 3,
      version: 2,
      rows: const [
        CensusSchemaRow(rowKey: 'total', label: 'Total'),
      ],
    );

    await viewModel.reloadDefinition();

    expect(viewModel.activeDefinition?.id, 3);
    expect(viewModel.measureValue('total', 'population'), '');
    expect(viewModel.message, contains('Some values need'));
    expect(viewModel.hasDraft, isFalse);
  });

  test('successful submit clears older snapshot notice', () async {
    censusService.activeDefinition = humanDefinition(
      id: 2,
      version: 1,
      rows: const [
        CensusSchemaRow(rowKey: 'male', label: 'Male'),
        CensusSchemaRow(rowKey: 'female', label: 'Female'),
      ],
    );
    censusService.latestV2 = VillageCensusSnapshot(
      id: 8,
      censusDate: DateTime.parse('2026-05-21'),
      definitionVersionId: 3,
      definitionVersionNumber: 2,
      formData: const {
        'rows': [
          {
            'row_key': 'total',
            'measures': {'population': 1010},
          },
        ],
      },
    );
    censusService.submitResult = VillageCensusSubmitSuccess(
      VillageCensusSnapshot(id: 100),
    );

    final viewModel = CensusViewModel(kind: 'HUMAN');
    await flushAsync();
    expect(viewModel.latestSnapshotUsesOlderDefinition, isTrue);
    viewModel.setMeasureValue('male', 'population', '100');
    viewModel.setMeasureValue('female', 'population', '200');

    await viewModel.submit();

    expect(viewModel.latestSnapshotUsesOlderDefinition, isFalse);
    expect(viewModel.oldSnapshotNotice, isNull);
    expect(viewModel.formInstruction, contains('Numbers from the last'));
    expect(viewModel.latestCensus?.definitionVersionId, 2);
  });

  test('failed reload keeps stale definition state', () async {
    censusService.activeDefinition = humanDefinition(
      id: 2,
      version: 1,
      rows: const [
        CensusSchemaRow(rowKey: 'total', label: 'Total'),
      ],
    );
    censusService.submitResult = CensusDefinitionChanged(
      const ['census definition version must be published'],
    );

    final viewModel = CensusViewModel(kind: 'HUMAN');
    await flushAsync();
    viewModel.setMeasureValue('total', 'population', '123');
    await viewModel.submit();

    censusService.throwActiveDefinitionError = true;
    await viewModel.reloadDefinition();

    expect(viewModel.definitionChanged, isTrue);
    expect(viewModel.canSubmit, isFalse);
  });

  test('saves draft after measure value changes', () async {
    censusService.activeDefinition = humanDefinition(
      id: 2,
      version: 1,
      rows: const [
        CensusSchemaRow(rowKey: 'total', label: 'Total'),
      ],
    );

    final viewModel = CensusViewModel(kind: 'HUMAN');
    await flushAsync();
    viewModel.setMeasureValue('total', 'population', '123');
    await flushAsync();

    final saved = censusService.draftFor(
      villageId: 1,
      kind: 'HUMAN',
      definitionVersionId: 2,
    );
    expect(saved?.measureValues['total']?['population'], '123');
    expect(viewModel.hasDraft, isTrue);
  });

  test('animal census requires village household summary', () async {
    censusService.activeDefinition = animalDefinition();

    final viewModel = CensusViewModel(kind: 'ANIMAL');
    await flushAsync();
    viewModel.setMeasureValue('species:1', 'animal_quantity', '10');
    viewModel.setMeasureValue('species:1', 'household_quantity', '5');

    final result = await viewModel.submit();

    expect(result, isNull);
    expect(
      viewModel.summaryError(CensusViewModel.villageHouseholdQuantityKey),
      'This field is required',
    );
    expect(
      viewModel.summaryError(CensusViewModel.animalHouseholdQuantityKey),
      'This field is required',
    );
  });

  test('animal household count cannot exceed village households', () async {
    censusService.activeDefinition = animalDefinition();

    final viewModel = CensusViewModel(kind: 'ANIMAL');
    await flushAsync();
    viewModel.setSummaryValue(
      CensusViewModel.villageHouseholdQuantityKey,
      '20',
    );
    viewModel.setSummaryValue(
      CensusViewModel.animalHouseholdQuantityKey,
      '21',
    );
    viewModel.setMeasureValue('species:1', 'animal_quantity', '10');
    viewModel.setMeasureValue('species:1', 'household_quantity', '5');

    final result = await viewModel.submit();

    expect(result, isNull);
    expect(
      viewModel.summaryError(CensusViewModel.animalHouseholdQuantityKey),
      'Households with animals cannot exceed village households.',
    );
  });

  test('animal census submits household summary with row measures', () async {
    censusService.activeDefinition = animalDefinition();

    final viewModel = CensusViewModel(kind: 'ANIMAL');
    await flushAsync();
    fillAnimalSummary(viewModel);
    viewModel.setMeasureValue('species:1', 'animal_quantity', '10');
    viewModel.setMeasureValue('species:1', 'household_quantity', '5');

    await viewModel.submit();

    expect(censusService.lastSubmittedFormData?['summary'], {
      'village_household_quantity': 30,
      'animal_household_quantity': 20,
    });
    expect(censusService.lastSubmittedFormData?['rows'], [
      {
        'measures': {
          'animal_quantity': 10,
          'household_quantity': 5,
        },
        'row_key': 'species:1',
      },
    ]);
  });

  test('restores animal summary from matching draft', () async {
    censusService.activeDefinition = animalDefinition();
    censusService.seedDraft(
      VillageCensusDraft(
        villageId: 1,
        kind: 'ANIMAL',
        definitionVersionId: 7,
        summaryValues: const {
          'village_household_quantity': '30',
          'animal_household_quantity': '20',
        },
        measureValues: const {
          'species:1': {
            'animal_quantity': '10',
            'household_quantity': '5',
          },
        },
        savedAt: DateTime.parse('2026-05-22T00:00:00Z'),
      ),
    );

    final viewModel = CensusViewModel(kind: 'ANIMAL');
    await flushAsync();

    expect(
      viewModel.summaryValue(CensusViewModel.villageHouseholdQuantityKey),
      '30',
    );
    expect(
      viewModel.summaryValue(CensusViewModel.animalHouseholdQuantityKey),
      '20',
    );
    expect(viewModel.hasDraft, isTrue);
    expect(viewModel.isSummaryDirty, isTrue);
  });

  test('restores matching draft over latest census values', () async {
    censusService.activeDefinition = humanDefinition(
      id: 2,
      version: 1,
      rows: const [
        CensusSchemaRow(rowKey: 'total', label: 'Total'),
      ],
    );
    censusService.latestV2 = VillageCensusSnapshot(
      id: 8,
      censusDate: DateTime.parse('2026-05-21'),
      definitionVersionId: 2,
      definitionVersionNumber: 1,
      formData: const {
        'rows': [
          {
            'row_key': 'total',
            'measures': {'population': 100},
          },
        ],
      },
    );
    censusService.seedDraft(
      VillageCensusDraft(
        villageId: 1,
        kind: 'HUMAN',
        definitionVersionId: 2,
        measureValues: const {
          'total': {'population': '123'},
        },
        savedAt: DateTime.parse('2026-05-22T00:00:00Z'),
      ),
    );

    final viewModel = CensusViewModel(kind: 'HUMAN');
    await flushAsync();

    expect(viewModel.measureValue('total', 'population'), '123');
    expect(viewModel.hasDraft, isTrue);
    expect(viewModel.isRowDirty(viewModel.rows.single), isTrue);
  });

  test('does not restore draft from a different definition version', () async {
    censusService.activeDefinition = humanDefinition(
      id: 3,
      version: 2,
      rows: const [
        CensusSchemaRow(rowKey: 'total', label: 'Total'),
      ],
    );
    censusService.seedDraft(
      VillageCensusDraft(
        villageId: 1,
        kind: 'HUMAN',
        definitionVersionId: 2,
        measureValues: const {
          'total': {'population': '123'},
        },
        savedAt: DateTime.parse('2026-05-22T00:00:00Z'),
      ),
    );

    final viewModel = CensusViewModel(kind: 'HUMAN');
    await flushAsync();

    expect(viewModel.measureValue('total', 'population'), '');
    expect(viewModel.hasDraft, isFalse);
  });

  test('successful submit clears matching draft', () async {
    censusService.activeDefinition = humanDefinition(
      id: 2,
      version: 1,
      rows: const [
        CensusSchemaRow(rowKey: 'total', label: 'Total'),
      ],
    );

    final viewModel = CensusViewModel(kind: 'HUMAN');
    await flushAsync();
    viewModel.setMeasureValue('total', 'population', '123');
    await flushAsync();

    await viewModel.submit();

    expect(
      censusService.draftFor(
        villageId: 1,
        kind: 'HUMAN',
        definitionVersionId: 2,
      ),
      isNull,
    );
    expect(viewModel.hasDraft, isFalse);
  });

  test('training mode uses training occurrence and training success message',
      () async {
    censusService.activeDefinition = animalDefinition();
    censusService.openOccurrences = [
      const CensusRoundOccurrence(
        id: 7,
        occurrenceKey: 'ANIMAL_H1_2026',
        kind: 'ANIMAL',
        mode: 'PRODUCTION',
        status: 'OPEN',
      ),
      const CensusRoundOccurrence(
        id: 17,
        occurrenceKey: 'ANIMAL_TRAINING_2026',
        kind: 'ANIMAL',
        mode: 'TRAINING',
        status: 'OPEN',
      ),
    ];

    final viewModel = CensusViewModel(
      kind: 'ANIMAL',
      initialTrainingMode: true,
    );
    await flushAsync();
    fillAnimalSummary(viewModel);
    viewModel.setMeasureValue('species:1', 'animal_quantity', '10');
    viewModel.setMeasureValue('species:1', 'household_quantity', '5');

    await viewModel.submit();

    expect(viewModel.isTrainingSubmission, isTrue);
    expect(viewModel.activeOccurrence?.id, 17);
    expect(censusService.lastSubmittedOccurrenceId, 17);
    expect(
      viewModel.message,
      contains('Training census submitted'),
    );
  });

  test('switches from closed production round to open training round',
      () async {
    censusService.activeDefinition = animalDefinition();
    censusService.openOccurrences = [
      const CensusRoundOccurrence(
        id: 17,
        occurrenceKey: 'ANIMAL_TRAINING_2026',
        kind: 'ANIMAL',
        mode: 'TRAINING',
        status: 'OPEN',
      ),
    ];

    final viewModel = CensusViewModel(kind: 'ANIMAL');
    await flushAsync();

    expect(viewModel.trainingMode, isFalse);
    expect(viewModel.noActiveRound, isTrue);
    expect(viewModel.activeOccurrence, isNull);
    expect(viewModel.hasTrainingOccurrence, isTrue);

    await viewModel.setTrainingMode(true);

    expect(viewModel.trainingMode, isTrue);
    expect(viewModel.noActiveRound, isFalse);
    expect(viewModel.activeOccurrence?.id, 17);
  });

  test('production and training drafts are isolated by occurrence', () async {
    censusService.activeDefinition = animalDefinition();
    censusService.openOccurrences = [
      const CensusRoundOccurrence(
        id: 7,
        occurrenceKey: 'ANIMAL_H1_2026',
        kind: 'ANIMAL',
        mode: 'PRODUCTION',
        status: 'OPEN',
      ),
      const CensusRoundOccurrence(
        id: 17,
        occurrenceKey: 'ANIMAL_TRAINING_2026',
        kind: 'ANIMAL',
        mode: 'TRAINING',
        status: 'OPEN',
      ),
    ];

    final viewModel = CensusViewModel(kind: 'ANIMAL');
    await flushAsync();
    fillAnimalSummary(viewModel);
    viewModel.setMeasureValue('species:1', 'animal_quantity', '10');
    viewModel.setMeasureValue('species:1', 'household_quantity', '5');
    await flushAsync();

    await viewModel.setTrainingMode(true);
    expect(viewModel.activeOccurrence?.id, 17);
    expect(viewModel.measureValue('species:1', 'animal_quantity'), '');
    fillAnimalSummary(viewModel);
    viewModel.setMeasureValue('species:1', 'animal_quantity', '99');
    viewModel.setMeasureValue('species:1', 'household_quantity', '9');
    await flushAsync();

    await viewModel.setTrainingMode(false);

    expect(viewModel.activeOccurrence?.id, 7);
    expect(viewModel.measureValue('species:1', 'animal_quantity'), '10');
    expect(
      censusService
          .draftFor(
            villageId: 1,
            kind: 'ANIMAL',
            definitionVersionId: 7,
            occurrenceId: 7,
          )
          ?.measureValues['species:1']?['animal_quantity'],
      '10',
    );
    expect(
      censusService
          .draftFor(
            villageId: 1,
            kind: 'ANIMAL',
            definitionVersionId: 7,
            occurrenceId: 17,
          )
          ?.measureValues['species:1']?['animal_quantity'],
      '99',
    );
  });

  test('discard draft restores latest submitted values', () async {
    censusService.activeDefinition = humanDefinition(
      id: 2,
      version: 1,
      rows: const [
        CensusSchemaRow(rowKey: 'total', label: 'Total'),
      ],
    );
    censusService.latestV2 = VillageCensusSnapshot(
      id: 8,
      censusDate: DateTime.parse('2026-05-21'),
      definitionVersionId: 2,
      definitionVersionNumber: 1,
      formData: const {
        'rows': [
          {
            'row_key': 'total',
            'measures': {'population': 100},
          },
        ],
      },
    );
    censusService.seedDraft(
      VillageCensusDraft(
        villageId: 1,
        kind: 'HUMAN',
        definitionVersionId: 2,
        measureValues: const {
          'total': {'population': '123'},
        },
        savedAt: DateTime.parse('2026-05-22T00:00:00Z'),
      ),
    );

    final viewModel = CensusViewModel(kind: 'HUMAN');
    await flushAsync();
    expect(viewModel.measureValue('total', 'population'), '123');

    await viewModel.discardDraft();

    expect(viewModel.measureValue('total', 'population'), '100');
    expect(viewModel.formValueRevision, 1);
    expect(viewModel.hasDraft, isFalse);
    expect(viewModel.message, 'Draft discarded.');
  });

  test('invalid submit keeps draft', () async {
    censusService.activeDefinition = humanDefinition(
      id: 2,
      version: 1,
      rows: const [
        CensusSchemaRow(rowKey: 'total', label: 'Total'),
      ],
    );

    final viewModel = CensusViewModel(kind: 'HUMAN');
    await flushAsync();
    viewModel.setMeasureValue('total', 'population', '-1');
    await flushAsync();

    final result = await viewModel.submit();

    expect(result, isNull);
    expect(viewModel.hasDraft, isTrue);
    expect(
      censusService.draftFor(
        villageId: 1,
        kind: 'HUMAN',
        definitionVersionId: 2,
      ),
      isNotNull,
    );
  });
}

CensusDefinitionVersion humanDefinition({
  required int id,
  required int version,
  required List<CensusSchemaRow> rows,
}) {
  return CensusDefinitionVersion(
    id: id,
    version: version,
    status: 'PUBLISHED',
    runtimeSchema: CensusRuntimeSchema(
      rows: rows,
      measures: const [
        CensusSchemaMeasure(
          key: 'population',
          label: 'Population',
          type: 'integer',
          required: true,
        ),
      ],
    ),
  );
}

CensusDefinitionVersion animalDefinition() {
  return const CensusDefinitionVersion(
    id: 7,
    version: 1,
    status: 'PUBLISHED',
    runtimeSchema: CensusRuntimeSchema(
      rows: [
        CensusSchemaRow(
          rowKey: 'species:1',
          label: 'Cattle',
        ),
      ],
      measures: [
        CensusSchemaMeasure(
          key: 'animal_quantity',
          label: 'Animal quantity',
          type: 'integer',
          required: true,
        ),
        CensusSchemaMeasure(
          key: 'household_quantity',
          label: 'Households',
          type: 'integer',
          required: true,
        ),
      ],
    ),
  );
}

Future<void> flushAsync() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void fillAnimalSummary(CensusViewModel viewModel) {
  viewModel.setSummaryValue(
    CensusViewModel.villageHouseholdQuantityKey,
    '30',
  );
  viewModel.setSummaryValue(
    CensusViewModel.animalHouseholdQuantityKey,
    '20',
  );
}

class AuthServiceMock extends ChangeNotifier implements IAuthService {
  final _village = const Village(id: 1, code: 'V001', name: 'FAO Mock Village');
  late final _profile = UserProfile(
    id: 1,
    username: 'samor1',
    firstName: 'Samor',
    lastName: 'Reporter',
    authorityName: 'FAO',
    authorityId: 1,
    features: const ['features.animal_census_enabled'],
    assignedVillages: [_village],
  );

  @override
  bool? get isLogin => true;

  @override
  UserProfile? get userProfile => _profile;

  @override
  Village? get selectedVillage => _village;

  @override
  Future<AuthResult> authenticate(String username, String password) {
    throw UnimplementedError();
  }

  @override
  Future<void> fetchProfile() {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    throw UnimplementedError();
  }

  @override
  Future<bool> requestAccessTokenIfExpired() {
    throw UnimplementedError();
  }

  @override
  Future<void> saveTokenAndFetchProfile(AuthSuccess loginSuccess) {
    throw UnimplementedError();
  }

  @override
  Future<void> selectVillage(int villageId) {
    throw UnimplementedError();
  }

  @override
  updateAvatarUrl(String avatarUrl) {
    throw UnimplementedError();
  }

  @override
  updateConfirmedConsent() {
    throw UnimplementedError();
  }

  @override
  Future<AuthResult> verifyQrToken(String token) {
    throw UnimplementedError();
  }
}

class FeatureCapabilityServiceMock extends IFeatureCapabilityService {
  @override
  bool get villageCapabilityKnown => true;

  @override
  bool get villageEnabled => true;

  @override
  Future<void> refresh() async {}

  @override
  void reset() {}
}

class CensusServiceMock implements ICensusService {
  CensusDefinitionVersion? activeDefinition;
  VillageCensusSnapshot? latestV2;
  List<CensusKindSummary> activeKinds = const [];
  List<CensusRoundOccurrence> openOccurrences = [
    const CensusRoundOccurrence(
      id: 7,
      occurrenceKey: 'ANIMAL_H1_2026',
      kind: 'ANIMAL',
      mode: 'PRODUCTION',
      status: 'OPEN',
    ),
    const CensusRoundOccurrence(
      id: 8,
      occurrenceKey: 'HUMAN_H1_2026',
      kind: 'HUMAN',
      mode: 'PRODUCTION',
      status: 'OPEN',
    ),
  ];
  bool throwActiveDefinitionError = false;
  final drafts = <String, VillageCensusDraft>{};
  Map<String, dynamic>? lastSubmittedFormData;
  int? lastSubmittedOccurrenceId;
  VillageCensusSubmitResult submitResult = VillageCensusSubmitSuccess(
    VillageCensusSnapshot(id: 99),
  );

  void seedDraft(VillageCensusDraft draft) {
    drafts[_draftKey(
      villageId: draft.villageId,
      kind: draft.kind,
      definitionVersionId: draft.definitionVersionId,
      occurrenceId: draft.occurrenceId,
    )] = draft;
  }

  VillageCensusDraft? draftFor({
    required int villageId,
    required String kind,
    int? definitionVersionId,
    int? occurrenceId,
  }) {
    final exact = drafts[_draftKey(
      villageId: villageId,
      kind: kind,
      definitionVersionId: definitionVersionId,
      occurrenceId: occurrenceId,
    )];
    if (exact != null) {
      return exact;
    }
    if (occurrenceId == null) {
      final prefix =
          '$villageId:${kind.toUpperCase()}:${definitionVersionId ?? 'legacy'}:';
      for (final entry in drafts.entries) {
        if (entry.key.startsWith(prefix)) {
          return entry.value;
        }
      }
      return null;
    }
    return drafts[_draftKey(
      villageId: villageId,
      kind: kind,
      definitionVersionId: definitionVersionId,
    )];
  }

  @override
  Future<CensusDefinitionVersion?> getActiveCensusDefinitionVersion({
    required String kind,
  }) async {
    if (throwActiveDefinitionError) {
      throw Exception('unable to refresh definition');
    }
    return activeDefinition;
  }

  @override
  Future<List<CensusKindSummary>> getActiveVillageCensusDefinitions(
    int villageId,
  ) async =>
      activeKinds;

  @override
  Future<CensusDefinitionVersion?> getCachedCensusDefinitionVersion({
    required String kind,
  }) async =>
      null;

  @override
  Future<VillageCensusSnapshot?> getLatestVillageCensusV2({
    required int villageId,
    required String kind,
  }) async =>
      latestV2;

  @override
  Future<List<CensusRoundOccurrence>> getOpenVillageCensusRoundOccurrences({
    required int villageId,
    required String kind,
    String mode = 'PRODUCTION',
  }) async =>
      openOccurrences
          .where((occurrence) =>
              occurrence.kind == kind && occurrence.mode == mode)
          .toList();

  @override
  Future<VillageCensusDraft?> getDraft({
    required int villageId,
    required String kind,
    int? definitionVersionId,
    int? occurrenceId,
  }) async =>
      draftFor(
        villageId: villageId,
        kind: kind,
        definitionVersionId: definitionVersionId,
        occurrenceId: occurrenceId,
      );

  @override
  Future<void> saveDraft(VillageCensusDraft draft) async {
    seedDraft(draft);
  }

  @override
  Future<void> clearDraft({
    required int villageId,
    required String kind,
    int? definitionVersionId,
    int? occurrenceId,
  }) async {
    drafts.remove(_draftKey(
      villageId: villageId,
      kind: kind,
      definitionVersionId: definitionVersionId,
      occurrenceId: occurrenceId,
    ));
    if (occurrenceId != null) {
      drafts.remove(_draftKey(
        villageId: villageId,
        kind: kind,
        definitionVersionId: definitionVersionId,
      ));
    }
  }

  @override
  Future<VillageCensusSubmitResult> submitVillageCensusSnapshotV2({
    required int villageId,
    required int definitionVersionId,
    int? occurrenceId,
    required DateTime censusDate,
    required Map<String, dynamic> formData,
  }) async {
    lastSubmittedFormData = formData;
    lastSubmittedOccurrenceId = occurrenceId;
    return submitResult;
  }

  String _draftKey({
    required int villageId,
    required String kind,
    int? definitionVersionId,
    int? occurrenceId,
  }) {
    return '$villageId:${kind.toUpperCase()}:${definitionVersionId ?? 'legacy'}:${occurrenceId ?? 'unscoped'}';
  }
}
