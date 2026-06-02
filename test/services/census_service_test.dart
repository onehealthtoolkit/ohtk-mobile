import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/village.dart';
import 'package:podd_app/models/village_census.dart';
import 'package:podd_app/services/api/census_api.dart';
import 'package:podd_app/services/census_service.dart';
import 'package:podd_app/services/db_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class NoopLink extends Link {
  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    return const Stream.empty();
  }
}

class ThrowingDbService extends IDbService {
  @override
  Database get db => throw UnimplementedError();
}

class FakeCensusApi extends CensusApi {
  final latestV2ByKind = <String, VillageCensusSnapshot?>{};
  Object? latestV2Error;

  FakeCensusApi({
    this.latestV2Error,
  }) : super(
          () => GraphQLClient(
            link: NoopLink(),
            cache: GraphQLCache(),
          ),
        );

  @override
  Future<VillageCensusSnapshot?> getLatestVillageCensusV2(
    int villageId,
    String kind,
  ) async {
    if (latestV2Error != null) {
      throw latestV2Error!;
    }
    return latestV2ByKind[kind];
  }
}

void main() {
  group('CensusService draft and read cache', () {
    setUp(() async {
      await locator.reset();
      locator.registerSingleton<Logger>(Logger());
      SharedPreferences.setMockInitialValues({});
    });

    test('saves and restores draft by village, kind, and definition version',
        () async {
      final service = CensusService(
        censusApi: FakeCensusApi(),
        dbService: ThrowingDbService(),
      );
      final draft = VillageCensusDraft(
        villageId: 11,
        kind: 'HUMAN',
        definitionVersionId: 3,
        measureValues: const {
          'total': {'population': '123'},
        },
        savedAt: DateTime(2026, 5, 28),
      );

      await service.saveDraft(draft);

      expect(
        (await service.getDraft(
          villageId: 11,
          kind: 'HUMAN',
          definitionVersionId: 3,
        ))
            ?.measureValues['total']?['population'],
        '123',
      );
      expect(
        await service.getDraft(
          villageId: 11,
          kind: 'HUMAN',
          definitionVersionId: 4,
        ),
        isNull,
      );

      await service.clearDraft(
        villageId: 11,
        kind: 'HUMAN',
        definitionVersionId: 3,
      );
      expect(
        await service.getDraft(
          villageId: 11,
          kind: 'HUMAN',
          definitionVersionId: 3,
        ),
        isNull,
      );
    });

    test('falls back to cached latest V2 census when refresh fails', () async {
      final latest = VillageCensusSnapshot(
        id: 99,
        village: const Village(id: 11, code: 'V001', name: 'Village One'),
        censusDate: DateTime(2026, 5, 28),
        definitionVersionId: 6,
        definitionVersionNumber: 2,
        formData: const {
          'rows': [
            {
              'row_key': 'species:CATTLE',
              'measures': {'animal_quantity': 5, 'household_quantity': 2},
            },
          ],
        },
        facts: [
          const AnimalCensusFact(
            rowKey: 'species:CATTLE',
            rowLabel: 'Cattle',
            animalQuantity: 5,
            householdQuantity: 2,
          ),
        ],
      );
      final onlineApi = FakeCensusApi()..latestV2ByKind['ANIMAL'] = latest;
      final onlineService = CensusService(
        censusApi: onlineApi,
        dbService: ThrowingDbService(),
      );

      await onlineService.getLatestVillageCensusV2(
        villageId: 11,
        kind: 'ANIMAL',
      );

      final offlineService = CensusService(
        censusApi: FakeCensusApi(latestV2Error: Exception('offline latest')),
        dbService: ThrowingDbService(),
      );
      final cached = await offlineService.getLatestVillageCensusV2(
        villageId: 11,
        kind: 'ANIMAL',
      );

      expect(cached?.id, 99);
      expect(cached?.definitionVersionId, 6);
      expect(cached?.facts.single.animalQuantity, 5);
      expect(
        cached?.formData['rows'][0]['measures']['household_quantity'],
        2,
      );
    });

    test('keeps latest V2 census cache separate by kind', () async {
      final onlineApi = FakeCensusApi()
        ..latestV2ByKind['ANIMAL'] = VillageCensusSnapshot(
          id: 24,
          censusDate: DateTime(2026, 5, 28),
          definitionVersionId: 6,
          definitionVersionNumber: 2,
        )
        ..latestV2ByKind['HUMAN'] = VillageCensusSnapshot(
          id: 23,
          censusDate: DateTime(2026, 5, 28),
          definitionVersionId: 5,
          definitionVersionNumber: 4,
        );
      final onlineService = CensusService(
        censusApi: onlineApi,
        dbService: ThrowingDbService(),
      );
      await onlineService.getLatestVillageCensusV2(
        villageId: 1,
        kind: 'ANIMAL',
      );
      await onlineService.getLatestVillageCensusV2(
        villageId: 1,
        kind: 'HUMAN',
      );

      final offlineService = CensusService(
        censusApi: FakeCensusApi(latestV2Error: Exception('offline latest')),
        dbService: ThrowingDbService(),
      );

      expect(
        (await offlineService.getLatestVillageCensusV2(
          villageId: 1,
          kind: 'ANIMAL',
        ))
            ?.id,
        24,
      );
      expect(
        (await offlineService.getLatestVillageCensusV2(
          villageId: 1,
          kind: 'HUMAN',
        ))
            ?.id,
        23,
      );
    });
  });
}
