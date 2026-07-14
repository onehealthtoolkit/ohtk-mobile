import 'dart:convert';

import 'package:podd_app/locator.dart';
import 'package:podd_app/models/census_definition.dart';
import 'package:podd_app/models/village_census.dart';
import 'package:podd_app/services/api/census_api.dart';
import 'package:podd_app/services/db_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

abstract class ICensusService {
  Future<CensusDefinitionVersion?> getActiveCensusDefinitionVersion({
    required String kind,
  });

  Future<CensusDefinitionVersion?> getCachedCensusDefinitionVersion({
    required String kind,
  });

  Future<List<CensusKindSummary>> getActiveVillageCensusDefinitions(
    int villageId,
  );

  Future<VillageCensusSnapshot?> getLatestVillageCensusV2({
    required int villageId,
    required String kind,
  });

  Future<List<CensusRoundOccurrence>> getOpenVillageCensusRoundOccurrences({
    required int villageId,
    required String kind,
    String mode,
  });

  Future<VillageCensusDraft?> getDraft({
    required int villageId,
    required String kind,
    int? definitionVersionId,
    int? occurrenceId,
  });

  Future<void> saveDraft(VillageCensusDraft draft);

  Future<void> clearDraft({
    required int villageId,
    required String kind,
    int? definitionVersionId,
    int? occurrenceId,
  });

  Future<VillageCensusSubmitResult> submitVillageCensusSnapshotV2({
    required int villageId,
    required int definitionVersionId,
    int? occurrenceId,
    required DateTime censusDate,
    required Map<String, dynamic> formData,
  });
}

class CensusService implements ICensusService {
  final CensusApi _censusApi;
  final IDbService _dbService;
  SharedPreferences? _prefs;

  CensusService({
    CensusApi? censusApi,
    IDbService? dbService,
    SharedPreferences? prefs,
  })  : _censusApi = censusApi ?? locator<CensusApi>(),
        _dbService = dbService ?? locator<IDbService>(),
        _prefs = prefs;

  @override
  Future<CensusDefinitionVersion?> getActiveCensusDefinitionVersion({
    required String kind,
  }) async {
    final definition = await _censusApi.getActiveCensusDefinitionVersion(kind);
    if (definition != null) {
      await _cacheDefinition(kind, definition);
    }
    return definition;
  }

  @override
  Future<CensusDefinitionVersion?> getCachedCensusDefinitionVersion({
    required String kind,
  }) async {
    await _ensureDefinitionCacheTable();
    final results = await _dbService.db.query(
      'census_definition_cache',
      where: 'kind = ?',
      whereArgs: [kind],
      limit: 1,
    );
    if (results.isEmpty) {
      return null;
    }
    return CensusDefinitionVersion.fromCacheMap(results.first);
  }

  @override
  Future<List<CensusKindSummary>> getActiveVillageCensusDefinitions(
    int villageId,
  ) async {
    final summaries =
        await _censusApi.getActiveVillageCensusDefinitions(villageId);
    for (final summary in summaries) {
      final version = summary.activeVersion;
      if (version != null) {
        await _cacheDefinition(summary.kind, version);
      }
    }
    return summaries;
  }

  @override
  Future<VillageCensusSnapshot?> getLatestVillageCensusV2({
    required int villageId,
    required String kind,
  }) {
    return _getLatestWithCache(
      villageId: villageId,
      kind: kind,
      fetch: () => _censusApi.getLatestVillageCensusV2(villageId, kind),
    );
  }

  @override
  Future<List<CensusRoundOccurrence>> getOpenVillageCensusRoundOccurrences({
    required int villageId,
    required String kind,
    String mode = 'PRODUCTION',
  }) {
    return _censusApi.getOpenVillageCensusRoundOccurrences(
      villageId: villageId,
      kind: kind,
      mode: mode,
    );
  }

  @override
  Future<VillageCensusDraft?> getDraft({
    required int villageId,
    required String kind,
    int? definitionVersionId,
    int? occurrenceId,
  }) async {
    final key = _draftKey(
      villageId: villageId,
      kind: kind,
      definitionVersionId: definitionVersionId,
      occurrenceId: occurrenceId,
    );
    final preferences = await _preferences();
    var raw = preferences.getString(key);
    if (raw == null && occurrenceId != null) {
      raw = preferences.getString(
        _draftKey(
          villageId: villageId,
          kind: kind,
          definitionVersionId: definitionVersionId,
        ),
      );
    }
    if (raw == null) {
      return null;
    }
    try {
      return VillageCensusDraft.fromJson(jsonDecode(raw));
    } catch (_) {
      await clearDraft(
        villageId: villageId,
        kind: kind,
        definitionVersionId: definitionVersionId,
        occurrenceId: occurrenceId,
      );
      return null;
    }
  }

  @override
  Future<void> saveDraft(VillageCensusDraft draft) async {
    await (await _preferences()).setString(
      _draftKey(
        villageId: draft.villageId,
        kind: draft.kind,
        definitionVersionId: draft.definitionVersionId,
        occurrenceId: draft.occurrenceId,
      ),
      jsonEncode(draft.toJson()),
    );
  }

  @override
  Future<void> clearDraft({
    required int villageId,
    required String kind,
    int? definitionVersionId,
    int? occurrenceId,
  }) async {
    final preferences = await _preferences();
    await preferences.remove(
      _draftKey(
        villageId: villageId,
        kind: kind,
        definitionVersionId: definitionVersionId,
        occurrenceId: occurrenceId,
      ),
    );
    if (occurrenceId != null) {
      await preferences.remove(
        _draftKey(
          villageId: villageId,
          kind: kind,
          definitionVersionId: definitionVersionId,
        ),
      );
    }
  }

  @override
  Future<VillageCensusSubmitResult> submitVillageCensusSnapshotV2({
    required int villageId,
    required int definitionVersionId,
    int? occurrenceId,
    required DateTime censusDate,
    required Map<String, dynamic> formData,
  }) {
    return _censusApi.submitVillageCensusSnapshotV2(
      villageId: villageId,
      definitionVersionId: definitionVersionId,
      occurrenceId: occurrenceId,
      censusDate: _dateOnly(censusDate),
      formData: formData,
    );
  }

  Future<void> _cacheDefinition(
    String kind,
    CensusDefinitionVersion definition,
  ) async {
    await _ensureDefinitionCacheTable();
    await _dbService.db.insert(
      'census_definition_cache',
      definition.toCacheMap(kind: kind, fetchedAt: DateTime.now()),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _ensureDefinitionCacheTable() async {
    await _dbService.db
        .execute('''CREATE TABLE IF NOT EXISTS census_definition_cache (
      kind TEXT PRIMARY KEY,
      definition_version_id INT,
      version INT,
      status TEXT,
      runtime_schema_json TEXT,
      fetched_at TEXT
    )''');
  }

  Future<SharedPreferences> _preferences() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<VillageCensusSnapshot?> _getLatestWithCache({
    required int villageId,
    required String kind,
    required Future<VillageCensusSnapshot?> Function() fetch,
  }) async {
    try {
      final latest = await fetch();
      await _cacheLatestCensus(
        villageId: villageId,
        kind: kind,
        latestCensus: latest,
      );
      return latest;
    } catch (_) {
      return _getCachedLatestCensus(villageId: villageId, kind: kind);
    }
  }

  Future<void> _cacheLatestCensus({
    required int villageId,
    required String kind,
    required VillageCensusSnapshot? latestCensus,
  }) async {
    final prefs = await _preferences();
    final key = _latestCensusKey(villageId: villageId, kind: kind);
    if (latestCensus == null) {
      await prefs.remove(key);
      return;
    }
    await prefs.setString(key, jsonEncode(latestCensus.toJson()));
  }

  Future<VillageCensusSnapshot?> _getCachedLatestCensus({
    required int villageId,
    required String kind,
  }) async {
    final prefs = await _preferences();
    final key = _latestCensusKey(villageId: villageId, kind: kind);
    final raw = prefs.getString(key);
    if (raw == null) {
      return null;
    }
    try {
      return VillageCensusSnapshot.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      await prefs.remove(key);
      return null;
    }
  }

  String _latestCensusKey({
    required int villageId,
    required String kind,
  }) {
    return 'fao.census.latest.$villageId.${kind.toUpperCase()}.cache';
  }

  String _draftKey({
    required int villageId,
    required String kind,
    int? definitionVersionId,
    int? occurrenceId,
  }) {
    final versionKey = definitionVersionId?.toString() ?? 'legacy';
    final occurrenceKey = occurrenceId?.toString() ?? 'unscoped';
    return 'fao.census.draft.$villageId.${kind.toUpperCase()}.$versionKey.$occurrenceKey';
  }

  String _dateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
