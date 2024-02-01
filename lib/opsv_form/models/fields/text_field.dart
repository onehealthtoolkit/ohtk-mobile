part of opensurveillance_form;

class TextField extends PrimitiveField<String> {
  int? minLength;
  int? maxLength;
  String? minLengthMessage;
  String? maxLengthMessage;

  TextField(
    String id,
    String name, {
    String? label,
    String? description,
    String? suffixLabel,
    bool? required,
    String? requiredMessage,
    this.minLength,
    this.minLengthMessage,
    this.maxLength,
    this.maxLengthMessage,
    Condition? condition,
    String? tags,
  }) : super(id, name,
            label: label,
            description: description,
            suffixLabel: suffixLabel,
            required: required,
            requiredMessage: requiredMessage,
            condition: condition,
            tags: tags);

  factory TextField.fromJson(Map<String, dynamic> json) {
    Condition? condition;
    if (json['condition'] != null) {
      condition = SimpleCondition.fromJson(json["condition"]);
    }
    return TextField(
      json["id"],
      json["name"],
      label: json["label"],
      description: json["description"],
      suffixLabel: json["suffixLabel"],
      required: json["required"],
      requiredMessage: json["requiredMessage"],
      minLength: json["minLength"],
      maxLength: json["maxLength"],
      minLengthMessage: json["minLengthMessage"],
      maxLengthMessage: json["maxLengthMessage"],
      condition: condition,
      tags: json['tags'],
    );
  }

  @override
  bool _validate() {
    return runInAction(() {
      clearError();
      var validateFns = ilist(
          [_validateRequired, _validateIsNotEmpty, _validateMin, _validateMax]);
      return validateFns.all((fn) => fn());
    });
  }

  bool _validateMin() {
    if (minLength != null) {
      var valid = value != null && value!.isNotEmpty
          ? value!.length >= minLength!
          : true;
      if (!valid) {
        final localize = locator<AppLocalizations>();
        markError(minLengthMessage ??
            localize.textFieldMinErrorMsg(minLength!.toString()));
        return false;
      }
    }
    return true;
  }

  bool _validateIsNotEmpty() {
    if (required == true && value != null) {
      var valid = value!.isNotEmpty;
      if (!valid) {
        final localize = locator<AppLocalizations>();
        markError(requiredMessage ?? localize.validateRequiredMsg);
        return false;
      }
    }
    return true;
  }

  bool _validateMax() {
    if (maxLength != null) {
      var valid = value != null && value!.isNotEmpty
          ? value!.length <= maxLength!
          : true;
      if (!valid) {
        final localize = locator<AppLocalizations>();
        markError(maxLengthMessage ??
            localize.textFieldMaxErrorMsg(maxLength!.toString()));
        return false;
      }
    }
    return true;
  }

  @override
  bool evaluate(ConditionOperator operator, String targetValue) {
    switch (operator) {
      case ConditionOperator.equal:
        return value == targetValue;
      case ConditionOperator.contain:
        return value?.contains(targetValue) ?? false;
      case ConditionOperator.notEqual:
        return value != targetValue;
      case ConditionOperator.isOneOf:
        return targetValue.split(",").map((e) => e.trim()).contains(value);
      case ConditionOperator.isNotOneOf:
        return !targetValue.split(",").map((e) => e.trim()).contains(value);
      default:
        return false;
    }
  }

  @override
  String get renderedValue => value ?? "";
}
