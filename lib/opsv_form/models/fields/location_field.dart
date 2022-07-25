part of opensurveillance_form;

/*
 *  value is kept in Longitude, latitude comma separated string
 */
class LocationField extends PrimitiveField<String> {
  LocationField(
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

  factory LocationField.fromJson(Map<String, dynamic> json) {
    var condition = parseConditionFromJson(json);

    return LocationField(
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

  double? get latitude {
    if (value != null) {
      var longlatAry = value!.split(',');
      var latValue = double.parse(longlatAry[1]);
      return latValue;
    } else {
      return null;
    }
  }

  double? get longitude {
    if (value != null) {
      var longlatAry = value!.split(',');
      var longValue = double.parse(longlatAry[0]);
      return longValue;
    } else {
      return null;
    }
  }

  @override
  bool _validate() {
    return runInAction(() {
      clearError();
      var validateFns = ilist([_validateRequired, _validateIsNotEmpty]);
      return validateFns.all((fn) => fn());
    });
  }

  bool _validateIsNotEmpty() {
    if (required == true && value != null) {
      var valid = value!.isNotEmpty;
      if (!valid) {
        markError(formatWithMap(
            requiredMessage ?? "This field is required", {"name": name}));
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
      default:
        return false;
    }
  }
}
