import 'field_ui_definition.dart';

class Option {
  String label;
  String value;
  bool input;

  Option({required this.label, required this.value, this.input = false});

  factory Option.fromJson(Map<String, dynamic> json) => Option(
      label: json['label'],
      value: json['value'],
      input: json['input'] ?? false);
}

abstract class OptionFieldUIDefinition extends FieldUIDefinition {
  List<Option> options;

  OptionFieldUIDefinition(
      {required id,
      required name,
      label,
      description,
      suffixLabel,
      required,
      required this.options})
      : super(
          id: id,
          name: name,
          label: label,
          description: description,
          suffixLabel: suffixLabel,
          required: required,
        );
}
