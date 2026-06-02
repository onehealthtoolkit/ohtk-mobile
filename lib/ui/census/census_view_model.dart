import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/census_definition.dart';
import 'package:podd_app/models/village.dart';
import 'package:podd_app/models/village_census.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/census_service.dart';
import 'package:podd_app/services/feature_capability_service.dart';
import 'package:stacked/stacked.dart';

class CensusViewModel extends BaseViewModel {
  final IAuthService authService = locator<IAuthService>();
  final ICensusService censusService = locator<ICensusService>();
  final IFeatureCapabilityService featureCapabilityService =
      locator<IFeatureCapabilityService>();
  final AppLocalizations localize = locator<AppLocalizations>();

  List<CensusKindSummary> censusKinds = [];
  List<CensusSchemaRow> rows = [];
  List<CensusSchemaMeasure> measures = [];
  CensusDefinitionVersion? activeDefinition;
  CensusKindSummary? activeKindSummary;
  VillageCensusSnapshot? latestCensus;
  VillageCensusDraft? draft;
  final measureValues = <String, Map<String, String>>{};
  final measureErrors = <String, String>{};
  final _initialMeasureValues = <String, Map<String, String>>{};
  String? message;
  bool usingCachedDefinition = false;
  bool unsupportedSchema = false;
  bool definitionInactive = false;
  bool definitionChanged = false;
  bool latestSnapshotUsesOlderDefinition = false;
  bool latestSnapshotPrefilledAnyValue = false;
  bool latestSnapshotPrefilledAllValues = false;
  final String? requestedKind;
  String? activeKind;
  int formValueRevision = 0;
  final Map<String, FocusNode> _inputFocusNodes = {};
  List<String> _visibleInputKeys = const [];
  Future<void>? _pendingDraftWrite;

  CensusViewModel({String? kind}) : requestedKind = _normalizeKind(kind) {
    init();
  }

  Village? get selectedVillage => authService.selectedVillage;

  String? get authorityName => authService.userProfile?.authorityName;

  bool get hasCensusAccess =>
      featureCapabilityService.villageEnabled &&
      (authService.userProfile?.hasFeatureEnabled('animal_census_enabled') ??
          false) &&
      selectedVillage != null;

  bool get hasSpecies => rows.isNotEmpty;

  bool get hasRows => rows.isNotEmpty;

  bool get canSubmit =>
      hasRows &&
      !unsupportedSchema &&
      !definitionInactive &&
      !definitionChanged;

  bool get isHubMode => activeKind == null;

  String get activeKindName =>
      _kindDisplayName(activeKind ?? activeKindSummary?.kind);

  String? get freshnessLabel {
    if (latestCensus == null) {
      return null;
    }
    return _dateOnly(latestCensus!.censusDate ?? DateTime.now());
  }

  String? get cachedDefinitionNotice {
    if (!usingCachedDefinition || activeDefinition == null) {
      return null;
    }
    return localize.censusCachedDefinitionNotice(activeDefinition!.version);
  }

  String? get oldSnapshotNotice {
    if (!latestSnapshotUsesOlderDefinition ||
        latestSnapshotPrefilledAllValues) {
      return null;
    }
    if (latestSnapshotPrefilledAnyValue) {
      return localize.censusOldSnapshotMatchingNotice;
    }
    return localize.censusOldSnapshotBlankNotice;
  }

  String get formInstruction {
    if (oldSnapshotNotice != null) {
      return oldSnapshotNotice!;
    }
    if (latestCensus == null) {
      return localize.censusNoPreviousSubmissionInstruction;
    }
    return localize.censusUpdatePreviousSubmissionInstruction;
  }

  String get definitionChangedMessage =>
      localize.censusDefinitionChangedMessage;

  bool get hasDraft => draft != null;

  String get draftSavedNotice => localize.censusDraftSavedNotice;

  Future<void> init() async {
    setBusy(true);
    message = null;
    clearErrors();
    if (requestedKind == null) {
      _clearLoadedForm();
    }

    if (!hasCensusAccess) {
      setBusy(false);
      return;
    }

    try {
      if (requestedKind != null) {
        await _loadFormForKind(requestedKind!);
      } else {
        await _loadHubOrSingleForm();
      }
    } catch (e) {
      setError(e.toString());
    }

    setBusy(false);
  }

  void setMeasureValue(String rowKey, String measureKey, String value) {
    measureValues.putIfAbsent(rowKey, () => {});
    measureValues[rowKey]![measureKey] = value.trim();
    measureErrors.remove(_inputKeyFor(rowKey, measureKey));
    _clearSubmitError();
    _pendingDraftWrite = _saveDraft();
    unawaited(_pendingDraftWrite!);
    notifyListeners();
  }

  String measureValue(String rowKey, String measureKey) {
    return measureValues[rowKey]?[measureKey] ?? '';
  }

  bool isRowDirty(CensusSchemaRow row) {
    final current = measureValues[row.rowKey] ?? const {};
    final initial = _initialMeasureValues[row.rowKey] ?? const {};
    return measures.any(
      (measure) => (current[measure.key] ?? '') != (initial[measure.key] ?? ''),
    );
  }

  bool hasMeasureError(CensusSchemaRow row, CensusSchemaMeasure measure) {
    return measureErrors.containsKey(_inputKey(row, measure));
  }

  bool hasRowErrors(CensusSchemaRow row) {
    return measures.any((measure) => hasMeasureError(row, measure));
  }

  String? measureError(CensusSchemaRow row, CensusSchemaMeasure measure) {
    return measureErrors[_inputKey(row, measure)];
  }

  FocusNode focusNodeFor(CensusSchemaRow row, CensusSchemaMeasure measure) {
    final key = _inputKey(row, measure);
    return _inputFocusNodes.putIfAbsent(key, () {
      final node = FocusNode(debugLabel: 'census_$key');
      node.addListener(() {
        if (node.hasFocus) {
          _ensureFocusedInputVisible(node);
        }
      });
      return node;
    });
  }

  TextInputAction textInputActionFor(
    CensusSchemaRow row,
    CensusSchemaMeasure measure,
  ) {
    return _nextInputKeyAfter(_inputKey(row, measure)) == null
        ? TextInputAction.done
        : TextInputAction.next;
  }

  void completeEditing(
    BuildContext context,
    CensusSchemaRow row,
    CensusSchemaMeasure measure,
  ) {
    final key = _inputKey(row, measure);
    final nextKey = _nextInputKeyAfter(key);
    if (nextKey == null) {
      _inputFocusNodes[key]?.unfocus();
      return;
    }

    final nextNode = _inputFocusNodes[nextKey];
    if (nextNode == null) {
      FocusScope.of(context).nextFocus();
      return;
    }
    FocusScope.of(context).requestFocus(nextNode);
    _ensureFocusedInputVisible(nextNode);
  }

  Future<VillageCensusSubmitResult?> submit() async {
    _clearSubmitError();
    message = null;
    definitionChanged = false;

    if (!hasCensusAccess) {
      setErrorForObject('submit', localize.censusVillageUnavailableError);
      return null;
    }
    if (unsupportedSchema) {
      setErrorForObject(
        'submit',
        localize.censusUnsupportedError,
      );
      return null;
    }
    if (definitionInactive) {
      setErrorForObject(
        'submit',
        localize.censusInactiveMessage,
      );
      return null;
    }

    final formData = _buildFormData();
    if (formData == null) {
      notifyListeners();
      return null;
    }

    setBusyForObject('submit', true);
    VillageCensusSubmitResult? result;
    try {
      if (activeDefinition != null) {
        result = await censusService.submitVillageCensusSnapshotV2(
          villageId: selectedVillage!.id,
          definitionVersionId: activeDefinition!.id,
          censusDate: DateTime.now(),
          formData: formData,
        );
      } else {
        result = VillageCensusSubmitUnsupported();
      }
    } catch (e) {
      setErrorForObject('submit', e.toString());
    } finally {
      setBusyForObject('submit', false);
    }

    if (result is VillageCensusSubmitSuccess) {
      latestCensus = _submittedSnapshot(result.snapshot, formData);
      latestSnapshotUsesOlderDefinition = false;
      latestSnapshotPrefilledAnyValue = false;
      latestSnapshotPrefilledAllValues = false;
      _captureInitialValues();
      await _pendingDraftWrite;
      await _clearDraft();
      message = localize.censusSubmittedMessage;
    } else if (result is VillageCensusSubmitValidationFailure) {
      setErrorForObject('submit', result.messages.join(', '));
    } else if (result is VillageCensusSubmitFailure) {
      setErrorForObject('submit', result.messages.join(', '));
    } else if (result is VillageCensusSubmitUnsupported) {
      setErrorForObject(
        'submit',
        localize.censusUnsupportedError,
      );
    } else if (result is CensusDefinitionChanged) {
      definitionChanged = true;
    }

    notifyListeners();
    return result;
  }

  VillageCensusSnapshot _submittedSnapshot(
    VillageCensusSnapshot snapshot,
    Map<String, dynamic> formData,
  ) {
    return VillageCensusSnapshot(
      id: snapshot.id,
      village: snapshot.village,
      censusDate: snapshot.censusDate,
      submittedAt: snapshot.submittedAt,
      definitionVersionId: snapshot.definitionVersionId ?? activeDefinition?.id,
      definitionVersionNumber:
          snapshot.definitionVersionNumber ?? activeDefinition?.version,
      facts: snapshot.facts,
      formData: snapshot.formData.isNotEmpty ? snapshot.formData : formData,
    );
  }

  Future<void> reloadDefinition() async {
    final kind = activeKind ?? requestedKind;
    if (kind == null) {
      await init();
      return;
    }

    final previousValues = {
      for (final entry in measureValues.entries)
        entry.key: Map<String, String>.from(entry.value),
    };

    setBusy(true);
    message = null;
    clearErrors();
    final wasDefinitionChanged = definitionChanged;
    try {
      await _loadFormForKind(kind, allowCachedDefinitionFallback: false);
      definitionChanged = false;
      final restoredAll = _restoreCompatibleValues(previousValues);
      await _saveDraft(force: _hasAnyEnteredValue(measureValues));
      message = restoredAll
          ? localize.censusFormReloadedMessage
          : localize.censusFormReloadedPartialMessage;
    } catch (e) {
      definitionChanged = wasDefinitionChanged;
      setError(e.toString());
    }
    setBusy(false);
    notifyListeners();
  }

  Map<String, dynamic>? _buildFormData() {
    final formRows = <Map<String, dynamic>>[];
    measureErrors.clear();
    for (final row in rows) {
      final measureMap = <String, int>{};
      for (final measure in measures) {
        final value = measureValue(row.rowKey, measure.key);
        final quantity = _parseQuantity(value);
        if (quantity == null) {
          final label = measure.label.isNotEmpty ? measure.label : measure.key;
          measureErrors[_inputKey(row, measure)] = value.isEmpty
              ? localize.validateRequiredMsg
              : localize.censusInvalidNumberError(label);
          continue;
        }
        measureMap[measure.key] = quantity;
      }
      if (measureMap.length != measures.length) {
        continue;
      }

      final payload = <String, dynamic>{
        'measures': measureMap,
      };
      if (activeKind == 'ANIMAL' || activeKind == 'HUMAN') {
        payload['row_key'] = row.rowKey;
      } else {
        setErrorForObject(
          'submit',
          localize.censusUnsupportedError,
        );
        return null;
      }

      formRows.add(payload);
    }
    if (measureErrors.isNotEmpty) {
      setErrorForObject('submit', null);
      _focusFirstInvalidMeasure();
      return null;
    }
    return {'rows': formRows};
  }

  Future<void> _loadHubOrSingleForm() async {
    censusKinds = await censusService
        .getActiveVillageCensusDefinitions(selectedVillage!.id);
    _clearLoadedForm();
  }

  Future<void> loadKind(String kind) async {
    setBusy(true);
    message = null;
    clearErrors();
    try {
      await _loadFormForKind(kind);
    } catch (e) {
      setError(e.toString());
    }
    setBusy(false);
  }

  Future<void> _loadFormForKind(
    String kind, {
    CensusKindSummary? summary,
    bool allowCachedDefinitionFallback = true,
  }) async {
    final normalizedKind = _normalizeKind(kind);
    if (normalizedKind == null) {
      throw Exception(localize.censusUnknownKindError);
    }

    activeKind = normalizedKind;
    activeKindSummary = summary;
    await _loadCensusRows(
      normalizedKind,
      summary: summary,
      allowCachedDefinitionFallback: allowCachedDefinitionFallback,
    );
    if (activeDefinition != null) {
      latestCensus = await censusService.getLatestVillageCensusV2(
        villageId: selectedVillage!.id,
        kind: normalizedKind,
      );
    }
    _prefillFromLatestCensus();
    await _loadDraft();
  }

  Future<void> _loadCensusRows(
    String kind, {
    CensusKindSummary? summary,
    bool allowCachedDefinitionFallback = true,
  }) async {
    usingCachedDefinition = false;
    unsupportedSchema = false;
    definitionInactive = false;
    latestSnapshotUsesOlderDefinition = false;
    latestSnapshotPrefilledAnyValue = false;
    latestSnapshotPrefilledAllValues = false;
    _clearFormData();
    CensusDefinitionVersion? definition;

    if (summary?.activeVersion != null) {
      definition = summary!.activeVersion;
    } else {
      try {
        definition = await censusService.getActiveCensusDefinitionVersion(
          kind: kind,
        );
      } catch (_) {
        if (!allowCachedDefinitionFallback) {
          rethrow;
        }
        definition = await censusService.getCachedCensusDefinitionVersion(
          kind: kind,
        );
        usingCachedDefinition = definition != null;
        if (definition == null) {
          rethrow;
        }
      }
    }

    if (definition == null) {
      definitionInactive = true;
    } else {
      activeDefinition = definition;
      final runtimeSchema = definition.runtimeSchema.localized(
        localize.localeName,
      );
      rows = runtimeSchema.rows;
      measures = runtimeSchema.measures;
      if (kind == 'ANIMAL') {
        unsupportedSchema = !runtimeSchema.supportsMobileAnimalSubmit;
      } else if (kind == 'HUMAN') {
        unsupportedSchema = !runtimeSchema.supportsMobileHumanSubmit;
      } else {
        unsupportedSchema = true;
      }
    }

    _ensureValueSlots();
  }

  void _ensureValueSlots() {
    for (final row in rows) {
      measureValues.putIfAbsent(row.rowKey, () => {});
      for (final measure in measures) {
        measureValues[row.rowKey]!.putIfAbsent(measure.key, () => '');
      }
    }
    _syncInputFocusNodes();
    _captureInitialValues();
  }

  void _prefillFromLatestCensus() {
    latestSnapshotUsesOlderDefinition = activeDefinition != null &&
        latestCensus?.definitionVersionId != null &&
        latestCensus!.definitionVersionId != activeDefinition!.id;
    if (latestCensus == null) {
      latestSnapshotPrefilledAllValues = false;
      _captureInitialValues();
      return;
    }

    var prefilledAny = false;
    var prefilledCount = 0;
    final expectedCount = rows.length * measures.length;
    final submittedRows = latestCensus!.formData['rows'];
    if (submittedRows is List && submittedRows.isNotEmpty) {
      for (final submittedRow in submittedRows.whereType<Map>()) {
        final rowKey = submittedRow['row_key']?.toString();
        final row = rows.where((candidate) {
          if (rowKey != null && rowKey.isNotEmpty) {
            return candidate.rowKey == rowKey;
          }
          return false;
        }).firstOrNull;
        if (row == null) {
          continue;
        }

        final submittedMeasures = submittedRow['measures'];
        if (submittedMeasures is! Map) {
          continue;
        }
        measureValues.putIfAbsent(row.rowKey, () => {});
        for (final measure in measures) {
          final value = submittedMeasures[measure.key];
          if (value != null) {
            measureValues[row.rowKey]![measure.key] = value.toString();
            prefilledAny = true;
            prefilledCount++;
          }
        }
      }
      latestSnapshotPrefilledAnyValue = prefilledAny;
      latestSnapshotPrefilledAllValues =
          expectedCount > 0 && prefilledCount == expectedCount;
      _captureInitialValues();
      return;
    }

    final factsByRowKey = {
      for (final fact in latestCensus!.facts) fact.rowKey: fact,
    };
    for (final row in rows) {
      final fact = factsByRowKey[row.rowKey];
      if (fact == null) {
        continue;
      }
      measureValues.putIfAbsent(row.rowKey, () => {});
      measureValues[row.rowKey]!['animal_quantity'] =
          fact.animalQuantity.toString();
      measureValues[row.rowKey]!['household_quantity'] =
          fact.householdQuantity.toString();
      prefilledAny = true;
      prefilledCount += 2;
    }
    latestSnapshotPrefilledAnyValue = prefilledAny;
    latestSnapshotPrefilledAllValues =
        expectedCount > 0 && prefilledCount == expectedCount;
    _captureInitialValues();
  }

  Future<void> _loadDraft() async {
    final village = selectedVillage;
    final kind = activeKind;
    if (village == null || kind == null) {
      draft = null;
      return;
    }

    final loaded = await censusService.getDraft(
      villageId: village.id,
      kind: kind,
      definitionVersionId: activeDefinition?.id,
    );
    if (loaded == null) {
      draft = null;
      return;
    }

    final appliedAny = _applyCompatibleValues(loaded.measureValues);
    if (!appliedAny) {
      draft = null;
      await _clearDraft();
      return;
    }
    draft = loaded;
  }

  Future<void> _saveDraft({bool force = false}) async {
    final village = selectedVillage;
    final kind = activeKind;
    if (village == null || kind == null || !hasRows) {
      draft = null;
      return;
    }

    if (!force && !_hasDraftChanges()) {
      await _clearDraft();
      return;
    }

    final currentDraft = VillageCensusDraft(
      villageId: village.id,
      kind: kind,
      definitionVersionId: activeDefinition?.id,
      measureValues: _cloneMeasureValues(measureValues),
      savedAt: DateTime.now(),
    );
    draft = currentDraft;
    await censusService.saveDraft(currentDraft);
  }

  Future<void> _clearDraft() async {
    final village = selectedVillage;
    final kind = activeKind;
    if (village == null || kind == null) {
      draft = null;
      return;
    }
    await censusService.clearDraft(
      villageId: village.id,
      kind: kind,
      definitionVersionId: activeDefinition?.id,
    );
    draft = null;
  }

  Future<void> discardDraft() async {
    await _pendingDraftWrite;
    await _clearDraft();
    measureValues
      ..clear()
      ..addEntries(
        _initialMeasureValues.entries.map(
          (entry) => MapEntry(entry.key, Map<String, String>.from(entry.value)),
        ),
      );
    formValueRevision++;
    message = localize.censusDraftDiscardedMessage;
    notifyListeners();
  }

  bool _restoreCompatibleValues(
    Map<String, Map<String, String>> previousValues,
  ) {
    var totalPrevious = 0;
    var restored = 0;
    for (final entry in previousValues.entries) {
      for (final measureEntry in entry.value.entries) {
        if (measureEntry.value.isEmpty) {
          continue;
        }
        totalPrevious++;
        final rowValues = measureValues[entry.key];
        if (rowValues == null || !rowValues.containsKey(measureEntry.key)) {
          continue;
        }
        rowValues[measureEntry.key] = measureEntry.value;
        restored++;
      }
    }
    _captureInitialValues();
    return totalPrevious == restored;
  }

  bool _applyCompatibleValues(
    Map<String, Map<String, String>> previousValues,
  ) {
    var appliedAny = false;
    for (final entry in previousValues.entries) {
      final rowValues = measureValues[entry.key];
      if (rowValues == null) {
        continue;
      }
      for (final measureEntry in entry.value.entries) {
        if (!rowValues.containsKey(measureEntry.key)) {
          continue;
        }
        rowValues[measureEntry.key] = measureEntry.value;
        appliedAny = true;
      }
    }
    return appliedAny;
  }

  void _captureInitialValues() {
    _initialMeasureValues
      ..clear()
      ..addEntries(
        _cloneMeasureValues(measureValues).entries,
      );
  }

  Map<String, Map<String, String>> _cloneMeasureValues(
    Map<String, Map<String, String>> values,
  ) {
    return values.map(
      (rowKey, rowValues) => MapEntry(
        rowKey,
        Map<String, String>.from(rowValues),
      ),
    );
  }

  bool _hasDraftChanges() {
    for (final row in rows) {
      final current = measureValues[row.rowKey] ?? const {};
      final initial = _initialMeasureValues[row.rowKey] ?? const {};
      for (final measure in measures) {
        if ((current[measure.key] ?? '') != (initial[measure.key] ?? '')) {
          return true;
        }
      }
    }
    return false;
  }

  bool _hasAnyEnteredValue(Map<String, Map<String, String>> values) {
    return values.values.any(
      (rowValues) => rowValues.values.any((value) => value.isNotEmpty),
    );
  }

  String _dateOnly(DateTime date) {
    final year = (date.year % 100).toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$day/$month/$year';
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

  void _clearLoadedForm() {
    activeKind = null;
    activeKindSummary = null;
    _clearFormData();
  }

  void _clearFormData() {
    activeDefinition = null;
    latestCensus = null;
    draft = null;
    definitionInactive = false;
    rows = [];
    measures = [];
    latestSnapshotUsesOlderDefinition = false;
    latestSnapshotPrefilledAnyValue = false;
    latestSnapshotPrefilledAllValues = false;
    measureValues.clear();
    measureErrors.clear();
    _initialMeasureValues.clear();
    _syncInputFocusNodes();
  }

  void _syncInputFocusNodes() {
    final nextKeys = [
      for (final row in rows)
        for (final measure in measures) _inputKey(row, measure),
    ];
    final nextKeySet = nextKeys.toSet();
    final removedKeys = _inputFocusNodes.keys
        .where((key) => !nextKeySet.contains(key))
        .toList();
    for (final key in removedKeys) {
      final node = _inputFocusNodes.remove(key);
      if (node == null) {
        continue;
      }
      if (node.hasFocus) {
        node.unfocus();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        node.dispose();
      });
    }
    _visibleInputKeys = nextKeys;
  }

  String _inputKey(CensusSchemaRow row, CensusSchemaMeasure measure) {
    return _inputKeyFor(row.rowKey, measure.key);
  }

  String _inputKeyFor(String rowKey, String measureKey) {
    return '$rowKey:$measureKey';
  }

  void _focusFirstInvalidMeasure() {
    for (final row in rows) {
      for (final measure in measures) {
        final key = _inputKey(row, measure);
        if (!measureErrors.containsKey(key)) {
          continue;
        }
        _inputFocusNodes[key]?.requestFocus();
        return;
      }
    }
  }

  String? _nextInputKeyAfter(String key) {
    final index = _visibleInputKeys.indexOf(key);
    if (index == -1 || index + 1 >= _visibleInputKeys.length) {
      return null;
    }
    return _visibleInputKeys[index + 1];
  }

  void _ensureFocusedInputVisible(FocusNode node) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = node.context;
      if (context == null || !node.hasFocus) {
        return;
      }
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 180),
        alignment: 0.12,
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    for (final node in _inputFocusNodes.values) {
      node.dispose();
    }
    _inputFocusNodes.clear();
    super.dispose();
  }

  static String? _normalizeKind(String? kind) {
    if (kind == null || kind.trim().isEmpty) {
      return null;
    }
    return kind.trim().toUpperCase();
  }

  String _kindDisplayName(String? kind) {
    if (kind == 'ANIMAL') {
      return localize.censusAnimalTitle;
    }
    if (kind == 'HUMAN') {
      return localize.censusHumanTitle;
    }
    return localize.censusGenericTitle;
  }
}
