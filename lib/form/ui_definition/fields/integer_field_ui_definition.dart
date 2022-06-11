import 'package:podd_app/form/ui_definition/condition_definition.dart';

import 'field_ui_definition.dart';

class IntegerFieldUIDefinition extends FieldUIDefinition {
  int? min;
  int? max;

  IntegerFieldUIDefinition({
    required id,
    required name,
    label,
    description,
    suffixLabel,
    required,
    this.min,
    this.max,
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

  factory IntegerFieldUIDefinition.fromJson(Map<String, dynamic> json) {
    return IntegerFieldUIDefinition(
      id: json['id'],
      name: json['name'],
      label: json['label'],
      description: json['description'],
      suffixLabel: json['suffixLabel'],
      required: json['required'],
      min: json['min'],
      max: json['max'],
      enableCondition: parseCondition(json, 'enableCondition'),
    );
  }
}
