import 'option_field_ui_definition.dart';

class SingleChoicesFieldUIDefinition extends OptionFieldUIDefinition {
  SingleChoicesFieldUIDefinition(
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
