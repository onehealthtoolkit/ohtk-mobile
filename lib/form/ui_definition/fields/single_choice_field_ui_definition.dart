import 'option_field_ui_definition.dart';

class SingleChoicesFieldUIDefinition extends OptionFieldUIDefinition {
  SingleChoicesFieldUIDefinition(
      {required id, required name, label, description, required, options})
      : super(
            id: id,
            name: name,
            label: label,
            description: description,
            suffixLabel: null,
            required: required,
            options: options);

  factory SingleChoicesFieldUIDefinition.fromJson(Map<String, dynamic> json) =>
      SingleChoicesFieldUIDefinition(
          id: json['id'],
          name: json['name'],
          label: json['label'],
          description: json['description'],
          required: json['required'],
          options: (json['options'] as List)
              .map((item) => Option.fromJson(item))
              .toList());
}
