import 'dart:convert';

import 'package:podd_app/locator.dart';
import 'package:podd_app/models/animal_species.dart';
import 'package:podd_app/models/village_census.dart';
import 'package:podd_app/services/api/census_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ICensusService {
  Future<List<AnimalSpecies>> fetchActiveSpecies();

  Future<VillageCensusSnapshot?> getLatestVillageCensus(int villageId);

  Future<VillageCensusReadData> loadVillageCensus(int villageId);

  Future<VillageCensusDraft?> getDraft(int villageId);

  Future<void> saveDraft(VillageCensusDraft draft);

  Future<void> clearDraft(int villageId);

  Future<VillageCensusSubmitResult> submitVillageCensusSnapshot({
    required int villageId,
    required DateTime censusDate,
    required List<AnimalCensusFactInput> facts,
  });
}

class CensusService implements ICensusService {
  static const _speciesCacheKey = 'fao.census.activeSpecies.cache';

  final CensusApi _censusApi;
  SharedPreferences? _prefs;

  CensusService({
    CensusApi? censusApi,
    SharedPreferences? prefs,
  })  : _censusApi = censusApi ?? locator<CensusApi>(),
        _prefs = prefs;

  @override
  Future<List<AnimalSpecies>> fetchActiveSpecies() {
    return _censusApi.fetchActiveSpecies();
  }

  @override
  Future<VillageCensusSnapshot?> getLatestVillageCensus(int villageId) {
    return _censusApi.getLatestVillageCensus(villageId);
  }

  @override
  Future<VillageCensusReadData> loadVillageCensus(int villageId) async {
    String? errorMessage;
    var usedCachedSpecies = false;
    var usedCachedLatestCensus = false;
    List<AnimalSpecies> species = const [];
    VillageCensusSnapshot? latestCensus;

    try {
      species = await fetchActiveSpecies();
      await _cacheSpecies(species);
    } catch (e) {
      errorMessage = e.toString();
      species = await _getCachedSpecies();
      usedCachedSpecies = species.isNotEmpty;
    }

    try {
      latestCensus = await getLatestVillageCensus(villageId);
      await _cacheLatestCensus(villageId, latestCensus);
    } catch (e) {
      errorMessage ??= e.toString();
      latestCensus = await _getCachedLatestCensus(villageId);
      usedCachedLatestCensus = latestCensus != null;
    }

    return VillageCensusReadData(
      species: species,
      latestCensus: latestCensus,
      usedCachedSpecies: usedCachedSpecies,
      usedCachedLatestCensus: usedCachedLatestCensus,
      errorMessage: errorMessage,
    );
  }

  @override
  Future<VillageCensusDraft?> getDraft(int villageId) async {
    final raw = (await _preferences()).getString(_draftKey(villageId));
    if (raw == null) {
      return null;
    }
    try {
      return VillageCensusDraft.fromJson(jsonDecode(raw));
    } catch (_) {
      await clearDraft(villageId);
      return null;
    }
  }

  @override
  Future<void> saveDraft(VillageCensusDraft draft) async {
    if (!draft.hasValues) {
      await clearDraft(draft.villageId);
      return;
    }
    await (await _preferences()).setString(
      _draftKey(draft.villageId),
      jsonEncode(draft.toJson()),
    );
  }

  @override
  Future<void> clearDraft(int villageId) async {
    await (await _preferences()).remove(_draftKey(villageId));
  }

  @override
  Future<VillageCensusSubmitResult> submitVillageCensusSnapshot({
    required int villageId,
    required DateTime censusDate,
    required List<AnimalCensusFactInput> facts,
  }) {
    return _censusApi.submitVillageCensusSnapshot(
      villageId: villageId,
      censusDate: _dateOnly(censusDate),
      facts: facts,
    );
  }

  String _dateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<SharedPreferences> _preferences() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _cacheSpecies(List<AnimalSpecies> species) async {
    await (await _preferences()).setString(
      _speciesCacheKey,
      jsonEncode(species.map((item) => item.toJson()).toList()),
    );
  }

  Future<List<AnimalSpecies>> _getCachedSpecies() async {
    final raw = (await _preferences()).getString(_speciesCacheKey);
    if (raw == null) {
      return const [];
    }
    try {
      return (jsonDecode(raw) as List)
          .map((item) => AnimalSpecies.fromJson(item))
          .toList();
    } catch (_) {
      await (await _preferences()).remove(_speciesCacheKey);
      return const [];
    }
  }

  Future<void> _cacheLatestCensus(
    int villageId,
    VillageCensusSnapshot? latestCensus,
  ) async {
    final prefs = await _preferences();
    final key = _latestCensusKey(villageId);
    if (latestCensus == null) {
      await prefs.remove(key);
      return;
    }
    await prefs.setString(key, jsonEncode(latestCensus.toJson()));
  }

  Future<VillageCensusSnapshot?> _getCachedLatestCensus(int villageId) async {
    final raw = (await _preferences()).getString(_latestCensusKey(villageId));
    if (raw == null) {
      return null;
    }
    try {
      return VillageCensusSnapshot.fromJson(jsonDecode(raw));
    } catch (_) {
      await (await _preferences()).remove(_latestCensusKey(villageId));
      return null;
    }
  }

  String _latestCensusKey(int villageId) =>
      'fao.census.latest.$villageId.cache';

  String _draftKey(int villageId) => 'fao.census.draft.$villageId';
}
