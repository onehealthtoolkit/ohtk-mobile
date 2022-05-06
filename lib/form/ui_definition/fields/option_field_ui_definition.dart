import 'field_ui_definition.dart';

class Option {
  String label;
  String value;
  bool input;

  Option({required this.label, required this.value, this.input = false});
}

abstract class OptionFieldUIDefinition extends FieldUIDefinition {
  var options = <Option>[];

  OptionFieldUIDefinition(
      {required id, required name, label, description, suffixLabel, required})
      : super(
          id: id,
          name: name,
          label: label,
          description: description,
          suffixLabel: suffixLabel,
          required: required,
        );
}
