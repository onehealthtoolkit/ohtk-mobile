import 'dart:convert';

import 'package:podd_app/models/village_census.dart';

class CensusKindSummary {
  final String kind;
  final String name;
  final bool enabled;
  final CensusDefinitionVersion? activeVersion;
  final VillageCensusSnapshot? latestSnapshot;

  const CensusKindSummary({
    required this.kind,
    required this.name,
    required this.enabled,
    this.activeVersion,
    this.latestSnapshot,
  });

  factory CensusKindSummary.fromJson(Map<String, dynamic> json) =>
      CensusKindSummary(
        kind: json['kind']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        enabled: json['enabled'] as bool? ?? false,
        activeVersion: json['activeVersion'] != null
            ? CensusDefinitionVersion.fromJson(
                Map<String, dynamic>.from(json['activeVersion'] as Map),
              )
            : null,
        latestSnapshot: json['latestSnapshot'] != null
            ? VillageCensusSnapshot.fromJson(
                Map<String, dynamic>.from(json['latestSnapshot'] as Map),
              )
            : null,
      );

  String get displayName {
    if (name.isNotEmpty) {
      return name;
    }
    if (kind == 'ANIMAL') {
      return 'Animal census';
    }
    if (kind == 'HUMAN') {
      return 'Human census';
    }
    return '${kind.toLowerCase()} census';
  }
}

class CensusDefinitionVersion {
  final int id;
  final int version;
  final String status;
  final CensusRuntimeSchema runtimeSchema;

  const CensusDefinitionVersion({
    required this.id,
    required this.version,
    required this.status,
    required this.runtimeSchema,
  });

  factory CensusDefinitionVersion.fromJson(Map<String, dynamic> json) =>
      CensusDefinitionVersion(
        id: _parseInt(json['id']) ?? 0,
        version: _parseInt(json['version']) ?? 0,
        status: json['status']?.toString() ?? '',
        runtimeSchema: CensusRuntimeSchema.fromJson(
          Map<String, dynamic>.from(json['runtimeSchema'] as Map? ?? const {}),
        ),
      );

  factory CensusDefinitionVersion.fromCacheMap(Map<String, dynamic> map) =>
      CensusDefinitionVersion(
        id: _parseInt(map['definition_version_id']) ?? 0,
        version: _parseInt(map['version']) ?? 0,
        status: map['status']?.toString() ?? '',
        runtimeSchema: CensusRuntimeSchema.fromJson(
          Map<String, dynamic>.from(
            jsonDecode(map['runtime_schema_json']?.toString() ?? '{}') as Map,
          ),
        ),
      );

  Map<String, dynamic> toCacheMap({
    required String kind,
    required DateTime fetchedAt,
  }) {
    return {
      'kind': kind,
      'definition_version_id': id,
      'version': version,
      'status': status,
      'runtime_schema_json': jsonEncode(runtimeSchema.toJson()),
      'fetched_at': fetchedAt.toIso8601String(),
    };
  }
}

class CensusRuntimeSchema {
  final List<CensusSchemaRow> rows;
  final List<CensusSchemaMeasure> measures;
  final List<Map<String, dynamic>> extraDimensions;

  const CensusRuntimeSchema({
    required this.rows,
    required this.measures,
    this.extraDimensions = const [],
  });

  factory CensusRuntimeSchema.fromJson(Map<String, dynamic> json) =>
      CensusRuntimeSchema(
        rows: (json['rows'] as List? ?? const [])
            .whereType<Map>()
            .map((row) => CensusSchemaRow.fromJson(
                  Map<String, dynamic>.from(row),
                ))
            .toList(),
        measures: (json['measures'] as List? ?? const [])
            .whereType<Map>()
            .map((measure) => CensusSchemaMeasure.fromJson(
                  Map<String, dynamic>.from(measure),
                ))
            .toList(),
        extraDimensions: (json['extra_dimensions'] as List? ?? const [])
            .whereType<Map>()
            .map((dimension) => Map<String, dynamic>.from(dimension))
            .toList(),
      );

  Map<String, dynamic> toJson() {
    return {
      'rows': rows.map((row) => row.toJson()).toList(),
      'measures': measures.map((measure) => measure.toJson()).toList(),
      'extra_dimensions': extraDimensions,
    };
  }

  CensusRuntimeSchema localized(String localeName) {
    return CensusRuntimeSchema(
      rows: rows.map((row) => row.localized(localeName)).toList(),
      measures:
          measures.map((measure) => measure.localized(localeName)).toList(),
      extraDimensions: extraDimensions,
    );
  }

  bool get supportsMobileAnimalSubmit {
    final rowKeys =
        rows.map((row) => row.rowKey).where((key) => key.isNotEmpty);
    return rows.isNotEmpty &&
        measures.isNotEmpty &&
        extraDimensions.isEmpty &&
        rows.every((row) => row.rowKey.isNotEmpty) &&
        rowKeys.length == rowKeys.toSet().length &&
        measures.every((measure) => measure.isInteger);
  }

  bool get supportsMobileHumanSubmit {
    final rowKeys =
        rows.map((row) => row.rowKey).where((key) => key.isNotEmpty);
    return rows.isNotEmpty &&
        measures.isNotEmpty &&
        extraDimensions.isEmpty &&
        rows.every((row) => row.rowKey.isNotEmpty) &&
        rowKeys.length == rowKeys.toSet().length &&
        measures.every((measure) => measure.isInteger);
  }
}

class CensusSchemaRow {
  final String rowKey;
  final String label;
  final Map<String, String> labelI18n;

  const CensusSchemaRow({
    required this.rowKey,
    required this.label,
    this.labelI18n = const {},
  });

  factory CensusSchemaRow.fromJson(Map<String, dynamic> json) {
    final labelValue = json['label'];
    return CensusSchemaRow(
      rowKey: json['row_key']?.toString() ?? json['key']?.toString() ?? '',
      label: _labelText(labelValue, ''),
      labelI18n: _localizedLabelMap(json['label_i18n'] ?? labelValue),
    );
  }

  CensusSchemaRow localized(String localeName) {
    final localizedLabel = _localizedLabelText(labelI18n, localeName, label);
    if (localizedLabel == label) {
      return this;
    }
    return CensusSchemaRow(
      rowKey: rowKey,
      label: localizedLabel,
      labelI18n: labelI18n,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'row_key': rowKey,
      'label': label,
      if (labelI18n.isNotEmpty) 'label_i18n': labelI18n,
    };
  }
}

class CensusSchemaMeasure {
  final String key;
  final String label;
  final Map<String, String> labelI18n;
  final String type;
  final bool required;

  const CensusSchemaMeasure({
    required this.key,
    required this.label,
    this.labelI18n = const {},
    required this.type,
    required this.required,
  });

  factory CensusSchemaMeasure.fromJson(Map<String, dynamic> json) =>
      CensusSchemaMeasure(
        key: json['key']?.toString() ?? '',
        label: _labelText(json['label'], ''),
        labelI18n: _localizedLabelMap(json['label_i18n'] ?? json['label']),
        type: json['type']?.toString() ?? '',
        required: json['required'] as bool? ?? false,
      );

  bool get isInteger => type.isEmpty || type == 'integer';

  CensusSchemaMeasure localized(String localeName) {
    final localizedLabel = _localizedLabelText(labelI18n, localeName, label);
    if (localizedLabel == label) {
      return this;
    }
    return CensusSchemaMeasure(
      key: key,
      label: localizedLabel,
      labelI18n: labelI18n,
      type: type,
      required: required,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      if (labelI18n.isNotEmpty) 'label_i18n': labelI18n,
      'type': type,
      'required': required,
    };
  }
}

String _labelText(dynamic value, String fallback) {
  if (value is Map) {
    final localized = _localizedLabelMap(value);
    return localized['default'] ??
        localized['en'] ??
        localized.values.firstOrNull ??
        fallback;
  }
  if (value == null) {
    return fallback;
  }
  return value.toString();
}

Map<String, String> _localizedLabelMap(dynamic value) {
  if (value is! Map) {
    if (value is String && value.isNotEmpty) {
      return {'default': value};
    }
    return const {};
  }
  final labels = <String, String>{};
  for (final entry in value.entries) {
    final key = entry.key?.toString().trim();
    final label = entry.value?.toString().trim();
    if (key == null || key.isEmpty || label == null || label.isEmpty) {
      continue;
    }
    labels[key] = label;
  }
  return labels;
}

String _localizedLabelText(
  Map<String, String> labels,
  String localeName,
  String fallback,
) {
  for (final key in _localeCandidates(localeName)) {
    final label = labels[key];
    if (label != null && label.isNotEmpty) {
      return label;
    }
  }
  return fallback;
}

List<String> _localeCandidates(String localeName) {
  final normalized = localeName.replaceAll('_', '-').toLowerCase();
  final language = normalized.split('-').first;
  final candidates = <String>[
    normalized,
    language,
    if (language == 'lo') 'la',
    if (language == 'la') 'lo',
    'default',
    'en',
  ];
  return candidates.toSet().toList();
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
