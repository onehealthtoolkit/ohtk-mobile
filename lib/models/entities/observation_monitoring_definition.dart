import 'dart:convert';

import 'package:podd_app/models/entities/utils.dart';

class ObservationMonitoringDefinition {
  int id;
  String name;
  String formDefinition;
  bool isActive;
  String? description;
  int definitionId;
  String updatedAt;

  ObservationMonitoringDefinition({
    required this.id,
    required this.name,
    required this.formDefinition,
    required this.isActive,
    required this.definitionId,
    required this.updatedAt,
    this.description,
  });

  ObservationMonitoringDefinition.fromJson(Map<String, dynamic> jsonMap)
      : id = cvInt(jsonMap, (m) => m['id']),
        name = jsonMap['name'],
        isActive = jsonMap['isActive'],
        description = jsonMap['description'],
        formDefinition = json.encode(jsonMap['formDefinition']),
        definitionId = jsonMap['definitionId'],
        updatedAt = jsonMap['updatedAt'];

  ObservationMonitoringDefinition.fromMap(Map<String, dynamic> map)
      : id = cvInt(map, (m) => m['id']),
        name = map['name'],
        description = map['description'],
        formDefinition = map['form_definition'],
        definitionId = cvInt(map, (m) => m['definition_id']),
        isActive = (map['is_active'] as int) == 1,
        updatedAt = map['updated_at'];

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      "id": id,
      "name": name,
      "description": description,
      "definition_id": definitionId,
      "form_definition": formDefinition,
      "is_active": isActive ? 1 : 0,
      "updated_at": updatedAt
    };
    return map;
  }
}
