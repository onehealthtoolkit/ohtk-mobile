part of opensurveillance_form;

enum ConditionOperator { equal, contain, none, notEqual, isOneOf, isNotOneOf }

ConditionOperator _parse(String operator) {
  switch (operator) {
    case '=':
      return ConditionOperator.equal;
    case '!=':
      return ConditionOperator.notEqual;
    case 'contain':
      return ConditionOperator.contain;
    case 'has_one_of':
    case 'hasOneOf':
    case 'isOneOf':
      return ConditionOperator.isOneOf;
    case 'isNotOneOf':
      return ConditionOperator.isNotOneOf;
    default:
      return ConditionOperator.none;
  }
}

abstract class ConiditionSource {}

abstract class Condition {
  ConiditionSource? source;

  Condition by(ConiditionSource source) {
    this.source = source;
    return this;
  }

  String get name;

  bool evaluate(Values values);
}

Condition? parseConditionFromJson(Map<String, dynamic> json) {
  if (json['condition'] != null) {
    return SimpleCondition.fromJson(json["condition"]);
  }
  return null;
}

class SimpleCondition extends Condition {
  @override
  final String name;
  final ConditionOperator operator;
  final String value;

  SimpleCondition(this.name, this.operator, this.value);

  factory SimpleCondition.fromJson(Map<String, dynamic> json) {
    return SimpleCondition(
        json["name"], _parse(json["operator"]), json["value"]);
  }

  @override
  bool evaluate(Values values) {
    Field? field = values.getDelegate(name)?.getField();
    if (field != null) {
      return field.evaluate(operator, value);
    }
    return false;
  }
}
