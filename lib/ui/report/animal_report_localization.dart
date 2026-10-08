import 'package:podd_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

const _animalReportNames = {
  'animal sick/death',
  'ສັດປ່ວຍ/ຕາຍ',
  'ລາຍງານສັດປ່ວຍ/ຕາຍ',
  'ລາຍງານ ສັດປ່ວຍຕາຍ',
};

bool isAnimalSickDeathReport(String name) =>
    _animalReportNames.contains(name.trim().toLowerCase());

String localizeAnimalReportName(String name, AppLocalizations localize) =>
    isAnimalSickDeathReport(name) ? localize.animalSickDeathReportName : name;

String localizeAnimalMetricLabel(
  String reportTypeName,
  String metricId,
  String fallback,
  AppLocalizations localize,
) {
  if (!isAnimalSickDeathReport(reportTypeName)) return fallback;
  return switch (metricId) {
    'num_household' => localize.animalMetricAffectedHouseholds,
    'num_total_animal' => localize.animalMetricTotalAnimals,
    'num_sick' => localize.animalMetricSick,
    'num_dead' => localize.animalMetricDead,
    'num_recover' => localize.animalMetricRecovered,
    _ => fallback,
  };
}

/// Build the Animal Sick/Death display summary from saved fields. The API's
/// rendererData contains fixed English prose, including on older reports.
String? localizeAnimalReportSummary(
  String reportTypeName,
  Map<String, dynamic>? data,
  DateTime? incidentDate,
  AppLocalizations localize,
) {
  if (!isAnimalSickDeathReport(reportTypeName) ||
      localize.localeName != 'lo' ||
      data == null) {
    return null;
  }

  String value(String key) {
    final raw = data[key];
    final stored = raw is Map ? raw['value'] : raw;
    return stored?.toString().trim() ?? '';
  }

  final species = value('animal_species');
  if (species.isEmpty) return null;

  final parts = <String>[species];
  final fields = <String, String>{
    'num_sick': localize.animalMetricSick,
    'num_dead': localize.animalMetricDead,
    'num_total_animal': localize.animalMetricTotalAnimals,
    'suspected_disease': localize.animalSummaryDisease,
    'animal_age_groups': localize.animalSummaryAgeGroups,
    'animal_sex': localize.animalSummarySex,
    'num_household': localize.animalMetricAffectedHouseholds,
  };
  for (final entry in fields.entries) {
    final stored = value(entry.key);
    if (stored.isNotEmpty) parts.add('${entry.value}: $stored');
  }
  for (final key in const [
    'digestive_symptoms',
    'respiratory_symptoms',
    'skin_external_symptoms',
    'general_symptoms',
    'nervous_symptoms',
    'reproductive_symptoms',
    'abnormalities_carcass',
    'unknown_symptoms',
  ]) {
    final stored = value(key);
    if (stored.isNotEmpty) parts.add(stored);
  }
  if (incidentDate != null) {
    parts.add(DateFormat('dd/MM/yyyy').format(incidentDate));
  }
  return parts.join(' · ');
}

Map<String, dynamic> localizeAnimalReportDefinition(
  String reportTypeName,
  Map<String, dynamic> definition,
  AppLocalizations localize,
) {
  if (!isAnimalSickDeathReport(reportTypeName)) return definition;

  final labels = {
    'num_household': localize.animalReportAffectedHouseholds,
    'num_total_animal': localize.animalReportTotalAnimals,
    'num_sick': localize.animalReportSick,
    'num_dead': localize.animalReportDead,
    'num_recover': localize.animalReportRecovered,
    'animal_photos': localize.animalReportPhotos,
  };
  final localized = Map<String, dynamic>.from(definition);
  localized['sections'] = [
    for (final section in definition['sections'] as List? ?? [])
      if (section is Map)
        <String, dynamic>{
          ...section,
          'questions': [
            for (final question in section['questions'] as List? ?? [])
              if (question is Map)
                <String, dynamic>{
                  ...question,
                  'label': labels[
                          (question['fields'] as List?)?.firstOrNull?['id']] ??
                      question['label'],
                }
              else
                question,
          ],
        }
      else
        section,
  ];
  return localized;
}
