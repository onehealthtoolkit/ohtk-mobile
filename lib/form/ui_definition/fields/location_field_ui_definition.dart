import '../condition_definition.dart';
import 'field_ui_definition.dart';

class LocationFieldUIDefinition extends FieldUIDefinition {
  LocationFieldUIDefinition({
    required id,
    required name,
    label,
    description,
    required,
    enableCondition,
  }) : super(
          id: id,
          name: name,
          label: label,
          description: description,
          required: required,
          enableCondition: enableCondition,
        );

  factory LocationFieldUIDefinition.fromJson(Map<String, dynamic> json) {
    return LocationFieldUIDefinition(
      id: json['id'],
      name: json['name'],
      label: json['label'],
      description: json['description'],
      required: json['required'],
      enableCondition: parseCondition(json, 'enableCondition'),
    );
  }
}
