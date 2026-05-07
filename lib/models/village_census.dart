import 'package:podd_app/models/animal_species.dart';
import 'package:podd_app/models/operation_exception_failure.dart';
import 'package:podd_app/models/village.dart';

class AnimalCensusFactInput {
  final int speciesId;
  final int animalQuantity;
  final int householdQuantity;

  const AnimalCensusFactInput({
    required this.speciesId,
    required this.animalQuantity,
    required this.householdQuantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'speciesId': speciesId,
      'animalQuantity': animalQuantity,
      'householdQuantity': householdQuantity,
    };
  }
}

class AnimalCensusFact {
  final AnimalSpecies species;
  final int animalQuantity;
  final int householdQuantity;

  const AnimalCensusFact({
    required this.species,
    required this.animalQuantity,
    required this.householdQuantity,
  });

  factory AnimalCensusFact.fromJson(Map<String, dynamic> json) =>
      AnimalCensusFact(
        species: AnimalSpecies.fromJson(json['species']),
        animalQuantity: json['animalQuantity'] as int? ?? 0,
        householdQuantity: json['householdQuantity'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() {
    return {
      'species': species.toJson(),
      'animalQuantity': animalQuantity,
      'householdQuantity': householdQuantity,
    };
  }
}

class VillageCensusSnapshot {
  final int id;
  final Village? village;
  final DateTime? censusDate;
  final String? submittedAt;
  final List<AnimalCensusFact> facts;

  const VillageCensusSnapshot({
    required this.id,
    this.village,
    this.censusDate,
    this.submittedAt,
    this.facts = const [],
  });

  factory VillageCensusSnapshot.fromJson(Map<String, dynamic> json) =>
      VillageCensusSnapshot(
        id: json['id'] is int ? json['id'] as int : int.parse('${json['id']}'),
        village:
            json['village'] != null ? Village.fromJson(json['village']) : null,
        censusDate: json['censusDate'] != null
            ? DateTime.tryParse(json['censusDate'].toString())
            : null,
        submittedAt: json['submittedAt']?.toString(),
        facts: (json['facts'] as List? ?? const [])
            .map((fact) => AnimalCensusFact.fromJson(fact))
            .toList(),
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'village': village?.toJson(),
      'censusDate': censusDate?.toIso8601String(),
      'submittedAt': submittedAt,
      'facts': facts.map((fact) => fact.toJson()).toList(),
    };
  }
}

class VillageCensusDraft {
  final int villageId;
  final Map<int, String> animalQuantities;
  final Map<int, String> householdQuantities;
  final DateTime savedAt;

  const VillageCensusDraft({
    required this.villageId,
    required this.animalQuantities,
    required this.householdQuantities,
    required this.savedAt,
  });

  bool get hasValues {
    return animalQuantities.values.any((value) => value.isNotEmpty) ||
        householdQuantities.values.any((value) => value.isNotEmpty);
  }

  factory VillageCensusDraft.fromJson(Map<String, dynamic> json) {
    Map<int, String> parseQuantities(dynamic value) {
      final map = value as Map? ?? const {};
      return map.map(
        (key, quantity) => MapEntry(
          int.parse(key.toString()),
          quantity?.toString() ?? '',
        ),
      );
    }

    return VillageCensusDraft(
      villageId: json['villageId'] is int
          ? json['villageId'] as int
          : int.parse('${json['villageId']}'),
      animalQuantities: parseQuantities(json['animalQuantities']),
      householdQuantities: parseQuantities(json['householdQuantities']),
      savedAt: DateTime.tryParse(json['savedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, String> encodeQuantities(Map<int, String> values) {
      return values.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    return {
      'villageId': villageId,
      'animalQuantities': encodeQuantities(animalQuantities),
      'householdQuantities': encodeQuantities(householdQuantities),
      'savedAt': savedAt.toIso8601String(),
    };
  }
}

class VillageCensusReadData {
  final List<AnimalSpecies> species;
  final VillageCensusSnapshot? latestCensus;
  final bool usedCachedSpecies;
  final bool usedCachedLatestCensus;
  final String? errorMessage;

  const VillageCensusReadData({
    required this.species,
    this.latestCensus,
    this.usedCachedSpecies = false,
    this.usedCachedLatestCensus = false,
    this.errorMessage,
  });

  bool get usedCache => usedCachedSpecies || usedCachedLatestCensus;
}

abstract class VillageCensusSubmitResult {}

class VillageCensusSubmitSuccess extends VillageCensusSubmitResult {
  final VillageCensusSnapshot snapshot;

  VillageCensusSubmitSuccess(this.snapshot);
}

class VillageCensusSubmitFailure extends OperationExceptionFailure
    implements VillageCensusSubmitResult {
  VillageCensusSubmitFailure(super.e);
}

class VillageCensusSubmitValidationFailure extends VillageCensusSubmitResult {
  final List<String> messages;

  VillageCensusSubmitValidationFailure(this.messages);
}
