abstract class ValidationDataDefinition {}

var emptyValidations = List<ValidationDataDefinition>.empty();

class RequiredValidationDefinition extends ValidationDataDefinition {
  String? invalidMessage;

  RequiredValidationDefinition({this.invalidMessage});
}

class MinMaxValidationDefinition extends ValidationDataDefinition {
  int? min;
  int? max;

  MinMaxValidationDefinition({this.min, this.max});
}

class MinMaxLengthValidationDefinition extends ValidationDataDefinition {
  int? minLength;
  int? maxLength;

  MinMaxLengthValidationDefinition({this.minLength, this.maxLength});
}
