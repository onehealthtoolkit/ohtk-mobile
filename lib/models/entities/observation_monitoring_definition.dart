import 'package:podd_app/models/entities/utils.dart';

class ObservationMonitoringDefinition {
  int id;
  String name;
  String formDefinition;
  bool isActive;
  String? description;
  String? titleTemplate;
  String? descriptionTemplate;

  ObservationMonitoringDefinition({
    required this.id,
    required this.name,
    required this.formDefinition,
    required this.isActive,
    this.description,
    this.titleTemplate,
    this.descriptionTemplate,
  });

  ObservationMonitoringDefinition.fromJson(Map<String, dynamic> jsonMap)
      : id = cvInt(jsonMap, (m) => m['id']),
        name = jsonMap['name'],
        isActive = jsonMap['isActive'],
        description = jsonMap['description'],
        formDefinition = jsonMap['formDefinition'],
        titleTemplate = jsonMap['titleTemplate'],
        descriptionTemplate = jsonMap['descriptionTemplate'];
}
