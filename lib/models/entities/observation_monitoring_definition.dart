class ObservationMonitoringDefinition {
  String id;
  String definitionId;
  String name;
  String formDefinition;
  String? titleTemplate;
  String? descriptionTemplate;

  ObservationMonitoringDefinition({
    required this.id,
    required this.definitionId,
    required this.name,
    required this.formDefinition,
    this.titleTemplate,
    this.descriptionTemplate,
  });

  // TODO Use in sync result from api
  // ObservationMonitoringDefinition.fromJson(Map<String, dynamic> jsonMap):

  ObservationMonitoringDefinition.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        definitionId = map['definition_id'],
        name = map['name'],
        formDefinition = map['form_definition'],
        titleTemplate = map['title_template'];

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      "id": id,
      "name": name,
      "definitionId": definitionId,
      "form_definition": formDefinition,
      "title_template": titleTemplate,
      "description_template": descriptionTemplate,
    };
    return map;
  }
}
