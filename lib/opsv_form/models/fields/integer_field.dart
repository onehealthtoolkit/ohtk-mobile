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
      var valid = value! >= min!;
      if (!valid) {
        markError(
          formatWithMap(
            minMessage ?? "{name} must be equal or more than {min}",
            {
              "name": name,
              "min": min!.toString(),
            },
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
        markError(
          formatWithMap(
            maxMessage ?? "{name} must be equal or lesser than {max}",
            {
              "name": name,
              "max": max!.toString(),
            },
          ),
        );
        return false;
      }
    }
    return true;
  }

  @override
  bool evaluate(ConditionOperator operator, String targetValue) {
    throw UnimplementedError();
  }
}
