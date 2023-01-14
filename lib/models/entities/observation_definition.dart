import 'dart:convert';

import 'package:podd_app/models/entities/observation_monitoring_definition.dart';
import 'package:podd_app/models/entities/utils.dart';

class ObservationDefinition {
  int id;
  String name;
  String? description;
  String registerFormDefinition;
  bool isActive;
  String updatedAt;

  List<ObservationMonitoringDefinition> monitoringDefinitions;

  ObservationDefinition({
    required this.id,
    required this.name,
    required this.registerFormDefinition,
    required this.isActive,
    required this.updatedAt,
    this.monitoringDefinitions = const [],
  });

  ObservationDefinition.fromJson(Map<String, dynamic> jsonMap)
      : id = cvInt(jsonMap, (m) => m['id']),
        name = jsonMap['name'],
        registerFormDefinition = json.encode(jsonMap['registerFormDefinition']),
        isActive = jsonMap['isActive'],
        updatedAt = jsonMap['updatedAt'],
        description = jsonMap['description'],
        monitoringDefinitions = jsonMap['monitoringDefinitions'] != null
            ? (jsonMap['monitoringDefinitions'] as List)
                .map((item) => ObservationMonitoringDefinition.fromJson(item))
                .toList()
            : [];

  ObservationDefinition.fromMap(
    Map<String, dynamic> map,
    List<Map<String, dynamic>>? monitoringDefinitions,
  )   : id = cvInt(map, (m) => m['id']),
        name = map['name'],
        description = map['description'],
        registerFormDefinition = map['form_definition'],
        isActive = (map['is_active'] as int) == 1,
        updatedAt = map['updated_at'],
        monitoringDefinitions = monitoringDefinitions != null
            ? monitoringDefinitions
                .map((item) => ObservationMonitoringDefinition.fromMap(item))
                .toList()
            : [];

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      "id": id,
      "name": name,
      "description": description,
      "form_definition": registerFormDefinition,
      "is_active": isActive ? 1 : 0,
      "updated_at": updatedAt
    };
    return map;
  }
}
