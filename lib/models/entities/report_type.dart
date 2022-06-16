import 'dart:convert';

import 'package:podd_app/form/ui_definition/form_ui_definition.dart';
import 'package:podd_app/models/entities/utils.dart';

class ReportType {
  String id;
  String name;
  int categoryId;
  String definition;
  int ordering;
  String updatedAt;

  ReportType({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.definition,
    required this.ordering,
    required this.updatedAt,
  });

  ReportType.fromJson(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'],
        name = jsonMap['name'],
        categoryId = cvInt(jsonMap, (m) => m['category']['id']),
        definition = json.encode(jsonMap['definition']),
        ordering = cvInt(jsonMap, (m) => m['ordering']),
        updatedAt = jsonMap['updatedAt'];

  ReportType.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        categoryId = map['categoryId'],
        definition = map['definition'],
        ordering = map['ordering'],
        updatedAt = map['updatedAt'];

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      "id": id,
      "name": name,
      "categoryid": categoryId,
      "definition": definition,
      "ordering": ordering,
      "updatedAt": updatedAt
    };
    return map;
  }

  FormUIDefinition get formUIDefinition {
    return FormUIDefinition.fromJson(json.decode(definition));
  }
}
