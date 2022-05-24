import 'option_field_ui_definition.dart';

class MultipleChoicesFieldUIDefinition extends OptionFieldUIDefinition {
  MultipleChoicesFieldUIDefinition({
    required id,
    required name,
    label,
    description,
    suffixLabel,
    required,
    options,
  }) : super(
            id: id,
            name: name,
            label: label,
            description: description,
            suffixLabel: suffixLabel,
            required: required,
            options: options);

  factory MultipleChoicesFieldUIDefinition.fromJson(
          Map<String, dynamic> json) =>
      MultipleChoicesFieldUIDefinition(
          id: json['id'],
          name: json['name'],
          label: json['label'],
          description: json['description'],
          required: json['required'],
          options: (json['options'] as List)
              .map((item) => Option.fromJson(item))
              .toList());
}
