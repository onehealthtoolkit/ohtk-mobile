part of opensurveillance_form;

class ImagesField extends Field {
  final _value = ObservableList<String>.of([]);
  int? min;
  int? max;
  String? minMessage;
  String? maxMessage;

  ImagesField(
    String id,
    String name, {
    String? label,
    String? description,
    String? suffixLabel,
    bool? required,
    String? requiredMessage,
    this.min,
    this.max,
    this.minMessage,
    this.maxMessage,
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

  factory ImagesField.fromJson(Map<String, dynamic> json) {
    var condition = parseConditionFromJson(json);

    return ImagesField(
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

  add(String imageId) {
    runInAction(() {
      clearError();
      _value.add(imageId);
    });
  }

  remove(String id) {
    runInAction(() {
      clearError();
      _value.remove(id);
    });
  }

  @override
  List<String> get value => _value;
  set value(List<String> ary) {
    runInAction(() {
      _value.clear();
      _value.addAll(ary);
    });
  }

  int get length => _value.length;

  @override
  bool _validate() {
    return runInAction(() {
      clearError();
      var validateFns = ilist(
          [_validateRequired, _validateNotEmpty, _validateMin, _validateMax]);
      return validateFns.all((fn) => fn());
    });
  }

  _validateNotEmpty() {
    if (required == true && _value.isEmpty) {
      _invalidMessage.value = requiredMessage ?? "This field is required";
      return false;
    }
    _invalidMessage.value = null;
    return true;
  }

  bool _validateMin() {
    if (min != null) {
      var valid = value.length >= min!;
      if (!valid) {
        markError(
          formatWithMap(
            minMessage ?? "Number of {name} must be equal or more than {min}",
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
    if (max != null) {
      var valid = value.length <= max!;
      if (!valid) {
        markError(
          formatWithMap(
            maxMessage ?? "Number of {name} must be equal or lesser than {max}",
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

  @override
  void loadJsonValue(Map<String, dynamic> json) {
    ilist(json[name] as List<String>).forEach((element) {
      add(element);
    });
  }

  @override
  void toJsonValue(Map<String, dynamic> aggregateResult) {
    aggregateResult[name] = value.toList();
    aggregateResult["${name}__value"] = renderedValue;
  }

  @override
  String get renderedValue => value.join(", ");
}
