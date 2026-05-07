import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/animal_species.dart';
import 'package:podd_app/models/login_result.dart';
import 'package:podd_app/models/user_profile.dart';
import 'package:podd_app/models/village.dart';
import 'package:podd_app/models/village_census.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/census_service.dart';
import 'package:podd_app/ui/census/census_view_model.dart';

class AuthServiceMock extends ChangeNotifier implements IAuthService {
  @override
  UserProfile? userProfile;

  @override
  Village? selectedVillage;

  AuthServiceMock({
    this.userProfile,
    this.selectedVillage,
  });

  @override
  Future<AuthResult> authenticate(String username, String password) {
    throw UnimplementedError();
  }

  @override
  Future<void> fetchProfile() {
    throw UnimplementedError();
  }

  @override
  bool? get isLogin => true;

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

class CensusServiceMock implements ICensusService {
  final cattle = const AnimalSpecies(
    id: 1,
    code: 'CATTLE',
    name: 'Cattle',
  );
  VillageCensusDraft? draft;
  bool draftCleared = false;

  @override
  Future<void> clearDraft(int villageId) async {
    draft = null;
    draftCleared = true;
  }

  @override
  Future<List<AnimalSpecies>> fetchActiveSpecies() async => [cattle];

  @override
  Future<VillageCensusDraft?> getDraft(int villageId) async => draft;

  @override
  Future<VillageCensusSnapshot?> getLatestVillageCensus(int villageId) async {
    return null;
  }

  @override
  Future<VillageCensusReadData> loadVillageCensus(int villageId) async {
    return VillageCensusReadData(species: [cattle]);
  }

  @override
  Future<void> saveDraft(VillageCensusDraft draft) async {
    this.draft = draft;
  }

  @override
  Future<VillageCensusSubmitResult> submitVillageCensusSnapshot({
    required int villageId,
    required DateTime censusDate,
    required List<AnimalCensusFactInput> facts,
  }) async {
    return VillageCensusSubmitSuccess(
      VillageCensusSnapshot(
        id: 100,
        censusDate: censusDate,
        facts: facts
            .map(
              (fact) => AnimalCensusFact(
                species: cattle,
                animalQuantity: fact.animalQuantity,
                householdQuantity: fact.householdQuantity,
              ),
            )
            .toList(),
      ),
    );
  }
}

void main() {
  group('CensusViewModel draft behavior', () {
    late CensusServiceMock censusService;

    setUp(() async {
      await locator.reset();
      const village = Village(id: 11, code: 'V001', name: 'Village One');
      locator.registerSingleton<IAuthService>(
        AuthServiceMock(
          selectedVillage: village,
          userProfile: UserProfile(
            id: 1,
            username: 'reporter',
            firstName: 'Reporter',
            lastName: 'One',
            authorityName: 'Authority',
            authorityId: 6,
            features: const ['features.animal_census_enabled'],
            assignedVillages: const [village],
          ),
        ),
      );
      censusService = CensusServiceMock();
      locator.registerSingleton<ICensusService>(censusService);
    });

    test('restores saved draft quantities', () async {
      censusService.draft = VillageCensusDraft(
        villageId: 11,
        animalQuantities: const {1: '7'},
        householdQuantities: const {1: '2'},
        savedAt: DateTime(2026, 5, 7),
      );

      final model = CensusViewModel();
      await model.init();

      expect(model.hasDraft, isTrue);
      expect(model.animalQuantities[1], '7');
      expect(model.householdQuantities[1], '2');
    });

    test('saves draft on quantity change and clears after submit', () async {
      final model = CensusViewModel();
      await model.init();

      await model.setAnimalQuantity(1, '8');
      await model.setHouseholdQuantity(1, '3');

      expect(censusService.draft?.animalQuantities[1], '8');
      expect(censusService.draft?.householdQuantities[1], '3');

      await model.submit();

      expect(censusService.draftCleared, isTrue);
      expect(model.hasDraft, isFalse);
      expect(model.latestCensus?.facts.single.animalQuantity, 8);
    });

    test('discardDraft clears local quantities', () async {
      censusService.draft = VillageCensusDraft(
        villageId: 11,
        animalQuantities: const {1: '4'},
        householdQuantities: const {1: '1'},
        savedAt: DateTime(2026, 5, 7),
      );
      final model = CensusViewModel();
      await model.init();

      await model.discardDraft();

      expect(censusService.draftCleared, isTrue);
      expect(model.hasDraft, isFalse);
      expect(model.animalQuantities[1], '');
      expect(model.householdQuantities[1], '');
    });
  });
}
