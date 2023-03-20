part of opensurveillance_form;

class IntegerField extends PrimitiveField<int> {
  int? min;
  int? max;
  String? minMessage;
  String? maxMessage;

  IntegerField(
    String id,
    String name, {
    String? label,
    String? description,
    String? suffixLabel,
    bool? required,
    String? requiredMessage,
    this.min,
    this.minMessage,
    this.maxMessage,
    this.max,
    Condition? condition,
    String? tags,
  }) : super(
          id,
          name,
          label: label,
          description: description,
          suffixLabel: suffixLabel,
          required: required,
          requiredMessage: requiredMessage,
          condition: condition,
          tags: tags,
        );

  factory IntegerField.fromJson(Map<String, dynamic> json) {
    Condition? condition;
    if (json['condition'] != null) {
      condition = SimpleCondition.fromJson(json["condition"]);
    }
    return IntegerField(
      json["id"],
      json["name"],
      label: json["label"],
      description: json["description"],
      suffixLabel: json["suffixLabel"],
      required: json["required"],
      requiredMessage: json["requiredMessage"],
      min: json["min"],
      max: json["max"],
      minMessage: json["minMessage"],
      maxMessage: json["maxMessage"],
      condition: condition,
      tags: json["tags"],
    );
  }

  @override
  bool _validate() {
    return runInAction(() {
      clearError();
      var validateFns = ilist([
        _validateRequired,
        _validateMin,
        _validateMax,
      ]);
      return validateFns.all((fn) => fn());
    });
  }

  bool _validateMin() {
    if (value == null && required == true) {
      return false;
    }
    if (min != null) {
      var valid = value != null && value! >= min!;
      if (!valid) {
        final localize = locator<AppLocalizations>();
        markError(
          localize.integerFieldMinErrorMsg(
            displayName,
            min!.toString(),
          ),
        );
        return false;
      }
    }
    return true;
  }

  bool _validateMax() {
    if (value == null && required == true) {
      return false;
    }
    if (max != null) {
      var valid = value! <= max!;
      if (!valid) {
        final localize = locator<AppLocalizations>();
        markError(
          localize.integerFieldMaxErrorMsg(
            displayName,
            max!.toString(),
          ),
        );
        return false;
      }
    }
    return true;
  }

  @override
  bool evaluate(ConditionOperator operator, String targetValue) {
    switch (operator) {
      case ConditionOperator.equal:
        return value == int.parse(targetValue);
      case ConditionOperator.notEqual:
        return value != int.parse(targetValue);
      case ConditionOperator.contain:
        return value?.toString().contains(targetValue) ?? false;
      case ConditionOperator.isOneOf:
        return targetValue
            .split(",")
            .map((e) => e.trim())
            .contains(value?.toString());
      case ConditionOperator.isNotOneOf:
        return !targetValue
            .split(",")
            .map((e) => e.trim())
            .contains(value?.toString());
      default:
        return false;
    }
  }

  @override
  String get renderedValue => value != null ? value.toString() : "";
}
