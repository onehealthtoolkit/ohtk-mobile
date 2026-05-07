import 'package:podd_app/locator.dart';
import 'package:podd_app/models/animal_species.dart';
import 'package:podd_app/models/village.dart';
import 'package:podd_app/models/village_census.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/census_service.dart';
import 'package:stacked/stacked.dart';

class CensusViewModel extends BaseViewModel {
  final IAuthService authService = locator<IAuthService>();
  final ICensusService censusService = locator<ICensusService>();

  List<AnimalSpecies> species = [];
  VillageCensusSnapshot? latestCensus;
  final animalQuantities = <int, String>{};
  final householdQuantities = <int, String>{};
  String? message;
  String? cacheMessage;
  VillageCensusDraft? draft;
  int fieldVersion = 0;

  CensusViewModel() {
    init();
  }

  Village? get selectedVillage => authService.selectedVillage;

  bool get hasCensusAccess =>
      (authService.userProfile?.hasFeatureEnabled('animal_census_enabled') ??
          false) &&
      selectedVillage != null;

  bool get hasSpecies => species.isNotEmpty;

  Future<void> init() async {
    setBusy(true);
    message = null;
    cacheMessage = null;
    clearErrors();

    if (!hasCensusAccess) {
      setBusy(false);
      return;
    }

    final readData = await censusService.loadVillageCensus(selectedVillage!.id);
    species = readData.species;
    latestCensus = readData.latestCensus;
    _syncQuantityRows();
    await _loadDraft();

    if (readData.usedCache) {
      cacheMessage = 'Showing saved census data. Pull to refresh.';
    } else if (readData.errorMessage != null) {
      setError(readData.errorMessage);
    }

    setBusy(false);
  }

  Future<void> setAnimalQuantity(int speciesId, String value) async {
    animalQuantities[speciesId] = value.trim();
    _clearSubmitError();
    await _saveDraft();
    notifyListeners();
  }

  Future<void> setHouseholdQuantity(int speciesId, String value) async {
    householdQuantities[speciesId] = value.trim();
    _clearSubmitError();
    await _saveDraft();
    notifyListeners();
  }

  bool get hasDraft => draft?.hasValues ?? false;

  Future<void> discardDraft() async {
    if (selectedVillage == null) {
      return;
    }
    await censusService.clearDraft(selectedVillage!.id);
    draft = null;
    for (final item in species) {
      animalQuantities[item.id] = '';
      householdQuantities[item.id] = '';
    }
    fieldVersion++;
    message = 'Draft discarded.';
    notifyListeners();
  }

  Future<VillageCensusSubmitResult?> submit() async {
    _clearSubmitError();
    message = null;

    if (!hasCensusAccess) {
      setErrorForObject('submit', 'Village census is not available.');
      return null;
    }

    final facts = _buildFacts();
    if (facts == null) {
      notifyListeners();
      return null;
    }

    setBusyForObject('submit', true);
    VillageCensusSubmitResult? result;
    try {
      result = await censusService.submitVillageCensusSnapshot(
        villageId: selectedVillage!.id,
        censusDate: DateTime.now(),
        facts: facts,
      );
    } catch (e) {
      setErrorForObject('submit', e.toString());
    } finally {
      setBusyForObject('submit', false);
    }

    if (result is VillageCensusSubmitSuccess) {
      latestCensus = result.snapshot;
      await censusService.clearDraft(selectedVillage!.id);
      draft = null;
      message = 'Census submitted.';
    } else if (result is VillageCensusSubmitValidationFailure) {
      setErrorForObject('submit', result.messages.join(', '));
    } else if (result is VillageCensusSubmitFailure) {
      setErrorForObject('submit', result.messages.join(', '));
    }

    notifyListeners();
    return result;
  }

  void _syncQuantityRows() {
    final speciesIds = species.map((item) => item.id).toSet();
    animalQuantities
        .removeWhere((speciesId, _) => !speciesIds.contains(speciesId));
    householdQuantities
        .removeWhere((speciesId, _) => !speciesIds.contains(speciesId));
    for (final item in species) {
      animalQuantities.putIfAbsent(item.id, () => '');
      householdQuantities.putIfAbsent(item.id, () => '');
    }
  }

  Future<void> _loadDraft() async {
    if (selectedVillage == null) {
      draft = null;
      return;
    }
    draft = await censusService.getDraft(selectedVillage!.id);
    if (draft == null) {
      return;
    }
    for (final item in species) {
      animalQuantities[item.id] = draft!.animalQuantities[item.id] ?? '';
      householdQuantities[item.id] = draft!.householdQuantities[item.id] ?? '';
    }
    fieldVersion++;
  }

  Future<void> _saveDraft() async {
    if (selectedVillage == null) {
      return;
    }
    final currentDraft = VillageCensusDraft(
      villageId: selectedVillage!.id,
      animalQuantities: Map<int, String>.from(animalQuantities),
      householdQuantities: Map<int, String>.from(householdQuantities),
      savedAt: DateTime.now(),
    );
    if (currentDraft.hasValues) {
      draft = currentDraft;
      await censusService.saveDraft(currentDraft);
    } else {
      draft = null;
      await censusService.clearDraft(selectedVillage!.id);
    }
  }

  List<AnimalCensusFactInput>? _buildFacts() {
    final facts = <AnimalCensusFactInput>[];
    for (final item in species) {
      final animalQuantity = _parseQuantity(animalQuantities[item.id]);
      final householdQuantity = _parseQuantity(householdQuantities[item.id]);

      if (animalQuantity == null || householdQuantity == null) {
        setErrorForObject(
          'submit',
          'Enter non-negative animal and household quantities for every species.',
        );
        return null;
      }

      facts.add(
        AnimalCensusFactInput(
          speciesId: item.id,
          animalQuantity: animalQuantity,
          householdQuantity: householdQuantity,
        ),
      );
    }
    return facts;
  }

  int? _parseQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 0) {
      return null;
    }
    return parsed;
  }

  void _clearSubmitError() {
    if (hasErrorForKey('submit')) {
      setErrorForObject('submit', null);
    }
    message = null;
  }
}
