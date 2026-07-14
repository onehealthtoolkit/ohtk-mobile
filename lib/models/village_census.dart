import 'package:podd_app/models/operation_exception_failure.dart';
import 'package:podd_app/models/village.dart';

class AnimalCensusFact {
  final String rowKey;
  final String rowLabel;
  final int animalQuantity;
  final int householdQuantity;

  const AnimalCensusFact({
    required this.rowKey,
    required this.rowLabel,
    required this.animalQuantity,
    required this.householdQuantity,
  });

  factory AnimalCensusFact.fromJson(Map<String, dynamic> json) =>
      AnimalCensusFact(
        rowKey: json['rowKey']?.toString() ?? json['row_key']?.toString() ?? '',
        rowLabel:
            json['rowLabel']?.toString() ?? json['row_label']?.toString() ?? '',
        animalQuantity: json['animalQuantity'] as int? ?? 0,
        householdQuantity: json['householdQuantity'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() {
    return {
      'rowKey': rowKey,
      'rowLabel': rowLabel,
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
  final int? definitionVersionId;
  final int? definitionVersionNumber;
  final int? villageHouseholdQuantity;
  final int? animalHouseholdQuantity;
  final List<AnimalCensusFact> facts;
  final Map<String, dynamic> formData;

  const VillageCensusSnapshot({
    required this.id,
    this.village,
    this.censusDate,
    this.submittedAt,
    this.definitionVersionId,
    this.definitionVersionNumber,
    this.villageHouseholdQuantity,
    this.animalHouseholdQuantity,
    this.facts = const [],
    this.formData = const {},
  });

  factory VillageCensusSnapshot.fromJson(Map<String, dynamic> json) {
    final definitionVersion = json['definitionVersion'] is Map
        ? Map<String, dynamic>.from(json['definitionVersion'] as Map)
        : const <String, dynamic>{};
    return VillageCensusSnapshot(
      id: json['id'] is int ? json['id'] as int : int.parse('${json['id']}'),
      village:
          json['village'] != null ? Village.fromJson(json['village']) : null,
      censusDate: json['censusDate'] != null
          ? DateTime.tryParse(json['censusDate'].toString())
          : null,
      submittedAt: json['submittedAt']?.toString(),
      definitionVersionId: _parseInt(definitionVersion['id']),
      definitionVersionNumber: _parseInt(definitionVersion['version']),
      villageHouseholdQuantity: _parseInt(json['villageHouseholdQuantity']) ??
          _parseSummaryInt(json, 'village_household_quantity'),
      animalHouseholdQuantity: _parseInt(json['animalHouseholdQuantity']) ??
          _parseSummaryInt(json, 'animal_household_quantity'),
      facts: (json['facts'] as List? ?? const [])
          .map((fact) => AnimalCensusFact.fromJson(fact))
          .toList(),
      formData: Map<String, dynamic>.from(json['formData'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (village != null) 'village': village!.toJson(),
      if (censusDate != null) 'censusDate': _dateOnly(censusDate!),
      if (submittedAt != null) 'submittedAt': submittedAt,
      if (villageHouseholdQuantity != null)
        'villageHouseholdQuantity': villageHouseholdQuantity,
      if (animalHouseholdQuantity != null)
        'animalHouseholdQuantity': animalHouseholdQuantity,
      if (definitionVersionId != null || definitionVersionNumber != null)
        'definitionVersion': {
          if (definitionVersionId != null) 'id': definitionVersionId,
          if (definitionVersionNumber != null)
            'version': definitionVersionNumber,
        },
      'facts': facts.map((fact) => fact.toJson()).toList(),
      'formData': formData,
    };
  }
}

class CensusRoundOccurrence {
  final int id;
  final String occurrenceKey;
  final String kind;
  final String mode;
  final DateTime? censusPeriodStart;
  final DateTime? censusPeriodEnd;
  final DateTime? startDate;
  final DateTime? softFinishDate;
  final DateTime? hardFinishDate;
  final String status;

  const CensusRoundOccurrence({
    required this.id,
    required this.occurrenceKey,
    required this.kind,
    required this.mode,
    this.censusPeriodStart,
    this.censusPeriodEnd,
    this.startDate,
    this.softFinishDate,
    this.hardFinishDate,
    required this.status,
  });

  factory CensusRoundOccurrence.fromJson(Map<String, dynamic> json) {
    return CensusRoundOccurrence(
      id: _parseInt(json['id']) ?? 0,
      occurrenceKey: json['occurrenceKey']?.toString() ??
          json['occurrence_key']?.toString() ??
          '',
      kind: json['kind']?.toString() ?? '',
      mode: json['mode']?.toString() ?? '',
      censusPeriodStart: _parseDate(json['censusPeriodStart']),
      censusPeriodEnd: _parseDate(json['censusPeriodEnd']),
      startDate: _parseDate(json['startDate']),
      softFinishDate: _parseDate(json['softFinishDate']),
      hardFinishDate: _parseDate(json['hardFinishDate']),
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'occurrenceKey': occurrenceKey,
      'kind': kind,
      'mode': mode,
      if (censusPeriodStart != null)
        'censusPeriodStart': _dateOnly(censusPeriodStart!),
      if (censusPeriodEnd != null)
        'censusPeriodEnd': _dateOnly(censusPeriodEnd!),
      if (startDate != null) 'startDate': _dateOnly(startDate!),
      if (softFinishDate != null) 'softFinishDate': _dateOnly(softFinishDate!),
      if (hardFinishDate != null) 'hardFinishDate': _dateOnly(hardFinishDate!),
      'status': status,
    };
  }
}

class VillageCensusDraft {
  final int villageId;
  final String kind;
  final int? definitionVersionId;
  final int? occurrenceId;
  final Map<String, Map<String, String>> measureValues;
  final Map<String, String> summaryValues;
  final DateTime savedAt;

  const VillageCensusDraft({
    required this.villageId,
    required this.kind,
    required this.measureValues,
    required this.savedAt,
    this.summaryValues = const {},
    this.definitionVersionId,
    this.occurrenceId,
  });

  factory VillageCensusDraft.fromJson(Map<String, dynamic> json) {
    Map<String, Map<String, String>> parseMeasureValues(dynamic value) {
      final rows = value as Map? ?? const {};
      return rows.map(
        (rowKey, measures) => MapEntry(
          rowKey.toString(),
          (measures as Map? ?? const {}).map(
            (measureKey, measureValue) => MapEntry(
              measureKey.toString(),
              measureValue?.toString() ?? '',
            ),
          ),
        ),
      );
    }

    return VillageCensusDraft(
      villageId: json['villageId'] is int
          ? json['villageId'] as int
          : int.parse('${json['villageId']}'),
      kind: json['kind']?.toString() ?? '',
      definitionVersionId: _parseInt(json['definitionVersionId']),
      occurrenceId: _parseInt(json['occurrenceId']),
      measureValues: parseMeasureValues(json['measureValues']),
      summaryValues: (json['summaryValues'] as Map? ?? const {}).map(
        (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
      ),
      savedAt: DateTime.tryParse(json['savedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'villageId': villageId,
      'kind': kind,
      'definitionVersionId': definitionVersionId,
      'occurrenceId': occurrenceId,
      'measureValues': measureValues,
      'summaryValues': summaryValues,
      'savedAt': savedAt.toIso8601String(),
    };
  }
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

class VillageCensusSubmitUnsupported extends VillageCensusSubmitResult {}

class CensusDefinitionChanged extends VillageCensusSubmitResult {
  final List<String> messages;

  CensusDefinitionChanged(this.messages);
}

int? _parseInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  return int.tryParse(value.toString());
}

int? _parseSummaryInt(Map<String, dynamic> json, String key) {
  final formData = json['formData'];
  if (formData is! Map) {
    return null;
  }
  final summary = formData['summary'];
  if (summary is! Map) {
    return null;
  }
  return _parseInt(summary[key]);
}

DateTime? _parseDate(dynamic value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value.toString());
}

String _dateOnly(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
