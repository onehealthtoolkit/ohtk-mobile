import 'field_ui_definition.dart';

class LocationFieldUIDefinition extends FieldUIDefinition {
  LocationFieldUIDefinition({
    required id,
    required name,
    label,
    description,
    required,
  }) : super(
            id: id,
            name: name,
            label: label,
            description: description,
            required: required);

  factory LocationFieldUIDefinition.fromJson(Map<String, dynamic> json) {
    return LocationFieldUIDefinition(
      id: json['id'],
      name: json['name'],
      label: json['label'],
      description: json['description'],
      required: json['required'],
    );
  }
}
