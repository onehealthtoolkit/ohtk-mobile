import 'field_ui_definition.dart';

class TableFieldUIDefinition extends FieldUIDefinition {
  List<FieldUIDefinition> cols;

  TableFieldUIDefinition({
    required id,
    required name,
    required this.cols,
    label,
    description,
    suffixLabel,
    enableCondition,
  }) : super(
          id: id,
          name: name,
          label: label,
          description: description,
          suffixLabel: suffixLabel,
          enableCondition: enableCondition,
        );
}
