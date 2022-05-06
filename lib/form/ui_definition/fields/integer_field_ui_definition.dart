import 'field_ui_definition.dart';

class IntegerFieldUIDefinition extends FieldUIDefinition {
  IntegerFieldUIDefinition({
    required id,
    required name,
    label,
    description,
    suffixLabel,
    required,
  }) : super(
          id: id,
          name: name,
          label: label,
          description: description,
          suffixLabel: suffixLabel,
          required: required,
        );

  factory IntegerFieldUIDefinition.fromJson(Map<String, dynamic> json) {
    return IntegerFieldUIDefinition(
      id: json['id'],
      name: json['name'],
      label: json['label'],
      description: json['description'],
      suffixLabel: json['suffixLabel'],
      required: json['required'],
    );
  }
}
