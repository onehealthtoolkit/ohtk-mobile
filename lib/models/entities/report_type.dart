import 'dart:convert';

import 'package:podd_app/models/entities/utils.dart';

class ReportType {
  String id;
  String name;
  int categoryId;
  String definition;
  String? followupDefinition;
  int ordering;
  String updatedAt;

  ReportType({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.definition,
    required this.ordering,
    required this.updatedAt,
    this.followupDefinition,
  });

  ReportType.fromJson(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'],
        name = jsonMap['name'],
        categoryId = cvInt(jsonMap, (m) => m['category']['id']),
        definition = json.encode(jsonMap['definition']),
        followupDefinition = json.encode(jsonMap['followupDefinition']),
        ordering = cvInt(jsonMap, (m) => m['ordering']),
        updatedAt = jsonMap['updatedAt'];

  ReportType.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        categoryId = map['category_id'],
        definition = map['definition'],
        followupDefinition = map['followup_definition'],
        ordering = map['ordering'],
        updatedAt = map['updated_at'];

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      "id": id,
      "name": name,
      "category_id": categoryId,
      "definition": definition,
      "followup_definition": followupDefinition,
      "ordering": ordering,
      "updated_at": updatedAt
    };
    return map;
  }
}
