import 'package:podd_app/form/ui_definition/condition_definition.dart';
import 'package:podd_app/form/ui_definition/fields/option_field_ui_definition.dart';
import 'package:podd_app/form/ui_definition/form_ui_definition.dart';

import 'form_data_definition_builder.dart';
import 'form_data_validation.dart';

abstract class BaseDataDefinition {
  final String name;
  final List<ValidationDataDefinition> validations;
  final ConditionDefinition? enableCondition;

  BaseDataDefinition(this.name, this.validations, {this.enableCondition});
}

class StringDataDefinition extends BaseDataDefinition {
  StringDataDefinition(name, validations, {enableCondition})
      : super(name, validations, enableCondition: enableCondition);
}

class IntegerDataDefinition extends BaseDataDefinition {
  IntegerDataDefinition(name, validations, {enableCondition})
      : super(
          name,
          validations,
          enableCondition: enableCondition,
        );
}

class DateDataDefinition extends BaseDataDefinition {
  DateDataDefinition(name, validations, {enableCondition})
      : super(
          name,
          validations,
          enableCondition: enableCondition,
        );
}

class BooleanDataDefinition extends BaseDataDefinition {
  BooleanDataDefinition(name, validations, {enableCondition})
      : super(
          name,
          validations,
          enableCondition: enableCondition,
        );
}

class DecimalDataDefinition extends BaseDataDefinition {
  DecimalDataDefinition(name, validations, {enableCondition})
      : super(
          name,
          validations,
          enableCondition: enableCondition,
        );
}

class ImagesDataDefinition extends BaseDataDefinition {
  ImagesDataDefinition(name, validations, {enableCondition})
      : super(name, validations);
}

class LocationDataDefinition extends BaseDataDefinition {
  LocationDataDefinition(name, validations, {enableCondition})
      : super(name, validations);
}

class SingleChoiceDataDefinition extends BaseDataDefinition {
  final List<Option> _options;

  bool get hasInput => _options.any((option) => option.textInput);

  List<Option> get options => _options;

  SingleChoiceDataDefinition(String name, this._options, validations,
      {enableCondition})
      : super(
          name,
          validations,
          enableCondition: enableCondition,
        );
}

class MultipleChoiceDataDefinition extends BaseDataDefinition {
  final List<Option> _options;

  bool get hasInput => _options.any((option) => option.textInput);

  List<Option> get options => _options;

  MultipleChoiceDataDefinition(String name, this._options, validations,
      {enableCondition})
      : super(
          name,
          validations,
          enableCondition: enableCondition,
        );
}

class FormDataDefinition extends BaseDataDefinition {
  final Map<String, BaseDataDefinition> properties;

  FormDataDefinition(name, this.properties) : super(name, emptyValidations);

  FormDataDefinition.fromUIDefinition(FormUIDefinition definition)
      : properties = parseFormUIDefinition(definition),
        super("root", emptyValidations);
}

class ArrayDataDefinition extends BaseDataDefinition {
  final FormDataDefinition cols;
  ArrayDataDefinition(name, this.cols, {enableCondition})
      : super(
          name,
          [],
          enableCondition: enableCondition,
        );
}
