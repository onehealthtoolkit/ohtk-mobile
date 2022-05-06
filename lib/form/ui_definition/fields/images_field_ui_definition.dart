import 'field_ui_definition.dart';

class ImagesFieldUIDefinition extends FieldUIDefinition {
  int? min;
  int? max;

  ImagesFieldUIDefinition(
      {required id,
      required name,
      label,
      description,
      this.min,
      this.max,
      required})
      : super(
          id: id,
          name: name,
          label: label,
          description: description,
          required: required,
        );

  factory ImagesFieldUIDefinition.fromJson(Map<String, dynamic> json) =>
      ImagesFieldUIDefinition(
        id: json['id'],
        name: json['name'],
        label: json['label'],
        description: json['description'],
        min: json['min'],
        max: json['max'],
        required: json['required'],
      );
}
