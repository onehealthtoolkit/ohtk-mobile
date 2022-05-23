import 'field_ui_definition.dart';

class TextFieldUIDefinition extends FieldUIDefinition {
  int? minLength;
  int? maxLength;

  TextFieldUIDefinition(
      {required id,
      required name,
      label,
      description,
      suffixLabel,
      required,
      this.minLength,
      this.maxLength})
      : super(
          id: id,
          name: name,
          label: label,
          description: description,
          suffixLabel: suffixLabel,
          required: required,
        );

  factory TextFieldUIDefinition.fromJson(Map<String, dynamic> json) {
    return TextFieldUIDefinition(
        id: json['id'],
        name: json['name'],
        label: json['label'],
        description: json['description'],
        suffixLabel: json['suffixLabel'],
        required: json['required'],
        minLength: json['minLength'],
        maxLength: json['maxLength']);
  }
}
