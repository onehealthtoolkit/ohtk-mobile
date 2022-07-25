part of opensurveillance_form;

class DateField extends PrimitiveField<DateTime> {
  DateField(
    String id,
    String name, {
    String? label,
    String? description,
    String? suffixLabel,
    bool? required,
    String? requiredMessage,
    Condition? condition,
  }) : super(id, name,
            label: label,
            description: description,
            suffixLabel: suffixLabel,
            required: required,
            requiredMessage: requiredMessage,
            condition: condition);

  factory DateField.fromJson(Map<String, dynamic> json) {
    var condition = parseConditionFromJson(json);

    return DateField(
      json["id"],
      json["name"],
      label: json["label"],
      description: json["description"],
      suffixLabel: json["suffixLabel"],
      required: json["required"],
      requiredMessage: json["requiredMessage"],
      condition: condition,
    );
  }

  @override
  bool _validate() {
    return runInAction(() {
      clearError();
      var validateFns = ilist([_validateRequired]);
      return validateFns.all((fn) => fn());
    });
  }

  @override
  bool evaluate(ConditionOperator operator, String targetValue) {
    switch (operator) {
      case ConditionOperator.equal:
        return value?.toIso8601String() == targetValue;
      case ConditionOperator.contain:
        return value?.toIso8601String().contains(targetValue) ?? false;
      default:
        return false;
    }
  }

  @override
  void loadJsonValue(Map<String, dynamic> json) {
    if (json[name] != null) {
      value = DateTime.parse(json[name]);
    }
  }

  @override
  void toJsonValue(Map<String, dynamic> aggregateResult) {
    aggregateResult[name] = value?.toIso8601String();
  }
}
