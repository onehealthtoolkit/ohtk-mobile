import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/animal_species.dart';
import 'package:podd_app/models/village.dart';
import 'package:podd_app/models/village_census.dart';
import 'package:podd_app/services/api/census_api.dart';
import 'package:podd_app/services/census_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoopLink extends Link {
  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    return const Stream.empty();
  }
}

class FakeCensusApi extends CensusApi {
  List<AnimalSpecies> species;
  VillageCensusSnapshot? latestCensus;
  Object? speciesError;
  Object? latestError;

  FakeCensusApi({
    this.species = const [],
    this.latestCensus,
    this.speciesError,
    this.latestError,
  }) : super(
          () => GraphQLClient(
            link: NoopLink(),
            cache: GraphQLCache(),
          ),
        );

  @override
  Future<List<AnimalSpecies>> fetchActiveSpecies() async {
    if (speciesError != null) {
      throw speciesError!;
    }
    return species;
  }

  @override
  Future<VillageCensusSnapshot?> getLatestVillageCensus(int villageId) async {
    if (latestError != null) {
      throw latestError!;
    }
    return latestCensus;
  }
}

void main() {
  group('CensusService draft and cache', () {
    setUp(() async {
      await locator.reset();
      locator.registerSingleton<Logger>(Logger());
      SharedPreferences.setMockInitialValues({});
    });

    test('saves and restores a per-village draft', () async {
      final service = CensusService(censusApi: FakeCensusApi());
      final draft = VillageCensusDraft(
        villageId: 11,
        animalQuantities: const {1: '12'},
        householdQuantities: const {1: '3'},
        savedAt: DateTime(2026, 5, 7),
      );

      await service.saveDraft(draft);
      final restored = await service.getDraft(11);

      expect(restored, isNotNull);
      expect(restored!.animalQuantities[1], '12');
      expect(restored.householdQuantities[1], '3');

      await service.clearDraft(11);
      expect(await service.getDraft(11), isNull);
    });

    test('falls back to cached read data when refresh fails', () async {
      final cattle = AnimalSpecies(
        id: 1,
        code: 'CATTLE',
        name: 'Cattle',
      );
      final latest = VillageCensusSnapshot(
        id: 99,
        village: const Village(id: 11, code: 'V001', name: 'Village One'),
        censusDate: DateTime(2026, 5, 5),
        facts: [
          AnimalCensusFact(
            species: cattle,
            animalQuantity: 5,
            householdQuantity: 2,
          ),
        ],
      );

      final onlineService = CensusService(
        censusApi: FakeCensusApi(species: [cattle], latestCensus: latest),
      );
      await onlineService.loadVillageCensus(11);

      final offlineService = CensusService(
        censusApi: FakeCensusApi(
          speciesError: Exception('offline species'),
          latestError: Exception('offline latest'),
        ),
      );
      final readData = await offlineService.loadVillageCensus(11);

      expect(readData.usedCache, isTrue);
      expect(readData.species.single.displayName, 'CATTLE - Cattle');
      expect(readData.latestCensus?.facts.single.animalQuantity, 5);
    });
  });
}
