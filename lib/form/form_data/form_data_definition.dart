import '../ui_definition/form_ui_definition.dart';
import 'form_data_definition_builder.dart';

abstract class ValidationDataDefinition {}

var emptyValidations = List<ValidationDataDefinition>.empty();

class RequiredValidationDefinition extends ValidationDataDefinition {
  String? invalidMessage;

  RequiredValidationDefinition({this.invalidMessage});
}

abstract class BaseDataDefinition {
  final String name;
  final List<ValidationDataDefinition> validations;

  BaseDataDefinition(this.name, this.validations);
}

class StringDataDefinition extends BaseDataDefinition {
  StringDataDefinition(name, validations) : super(name, validations);
}

class IntegerDataDefinition extends BaseDataDefinition {
  IntegerDataDefinition(name, validations) : super(name, validations);
}

class DateDataDefinition extends BaseDataDefinition {
  DateDataDefinition(name, validations) : super(name, validations);
}

class BooleanDataDefinition extends BaseDataDefinition {
  BooleanDataDefinition(name, validations) : super(name, validations);
}

class DecimalDataDefinition extends BaseDataDefinition {
  DecimalDataDefinition(name, validations) : super(name, validations);
}

class ImagesDataDefinition extends BaseDataDefinition {
  ImagesDataDefinition(name, validations) : super(name, validations);
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
  ArrayDataDefinition(name, this.cols) : super(name, []);
}
