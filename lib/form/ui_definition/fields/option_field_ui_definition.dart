import 'field_ui_definition.dart';

class Option {
  String label;
  String value;
  bool textInput;

  Option({required this.label, required this.value, this.textInput = false});

  factory Option.fromJson(Map<String, dynamic> json) => Option(
      label: json['label'],
      value: json['value'],
      textInput: json['textInput'] ?? false);
}

abstract class OptionFieldUIDefinition extends FieldUIDefinition {
  List<Option> options;

  OptionFieldUIDefinition({
    required id,
    required name,
    label,
    description,
    suffixLabel,
    required,
    required this.options,
    enableCondition,
  }) : super(
          id: id,
          name: name,
          label: label,
          description: description,
          suffixLabel: suffixLabel,
          required: required,
          enableCondition: enableCondition,
        );
}
