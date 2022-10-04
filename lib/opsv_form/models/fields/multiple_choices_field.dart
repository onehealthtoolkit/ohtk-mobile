part of opensurveillance_form;

class ChoiceOption {
  String label;
  String value;
  bool textInput;

  ChoiceOption(
      {required this.label, required this.value, this.textInput = false});

  factory ChoiceOption.fromJson(Map<String, dynamic> json) => ChoiceOption(
      label: json['label'],
      value: json['value'],
      textInput: json['textInput'] ?? false);
}

List<ChoiceOption> parseOptionFromJson(Map<String, dynamic> json) =>
    ilist(json["options"] as List)
        .map<ChoiceOption>((optionJson) => ChoiceOption.fromJson(optionJson))
        .toList();

class MultipleChoicesField extends Field {
  List<ChoiceOption> options;

  final Map<String, Observable<bool>> _selected = {};
  final Map<String, Observable<String?>> _text = {};
  final Map<String, Observable<String?>> _invalidTextMessage = {};

  MultipleChoicesField(
    String id,
    String name,
    this.options, {
    String? label,
    String? description,
    bool? required,
    String? requiredMessage,
    Condition? condition,
    String? tags,
  }) : super(
          id,
          name,
          label: label,
          description: description,
          required: required,
          requiredMessage: requiredMessage,
          condition: condition,
          tags: tags,
        ) {
    for (var option in options) {
      _selected[option.value] = Observable(false);
      if (option.textInput) {
        _text[option.value] = Observable(null);
        _invalidTextMessage[option.value] = Observable(null);
      }
    }
  }

  factory MultipleChoicesField.fromJson(Map<String, dynamic> json) {
    var condition = parseConditionFromJson(json);

    var options = parseOptionFromJson(json);

    return MultipleChoicesField(
      json["id"],
      json["name"],
      options,
      label: json["label"],
      description: json["description"],
      required: json["required"],
      requiredMessage: json["requiredMessage"],
      condition: condition,
      tags: json["tags"],
    );
  }

  void setSelectedFor(String key, bool value) {
    runInAction(() {
      _selected[key]?.value = value;
      if (_text[key] != null && !value) {
        _text[key]!.value = null;
      }
      clearError();
    });
  }

  bool valueFor(String key) => _selected[key]?.value ?? false;

  Observable<String?>? textValueFor(String key) => _text[key];

  setTextValueFor(String key, String value) {
    runInAction(() {
      _text[key]?.value = value;
      _invalidTextMessage[key]?.value = null;
    });
  }

  Observable<String?>? invalidTextMessageFor(String key) =>
      _invalidTextMessage[key];

  @override
  bool _validate() {
    if (required == true) {
      bool hasTick = options.any((option) {
        return valueFor(option.value);
      });
      if (!hasTick) {
        markError("This field is required");
        return false;
      } else {
        bool found = false;
        for (var option in options) {
          if (option.textInput) {
            if (valueFor(option.value) &&
                (textValueFor(option.value)!.value == null ||
                    textValueFor(option.value)!.value == '')) {
              runInAction(() {
                _invalidTextMessage[option.value]!.value =
                    "This field is required";
              });
              found = true;
            }
          }
        }
        return !found;
      }
    }
    return true;
  }

  @override
  get value {
    var selected = [];
    for (var option in options) {
      if (_selected[option.value]!.value) {
        selected.add(option.value);
      }
    }
    return selected.join(",");
  }

  @override
  void loadJsonValue(Map<String, dynamic> json) {
    if (json[name] != null) {
      for (var option in options) {
        var v = json[name][option.value];
        if (v != null) {
          _selected[option.value]!.value = v;
        }
      }
    }
  }

  @override
  void toJsonValue(Map<String, dynamic> aggregateResult) {
    Map<String, dynamic> json = {};
    _selected.forEach((key, value) {
      json[key] = value.value;
    });
    _text.forEach((key, value) {
      json["${key}_text"] = value.value;
    });
    json["value"] = IList.flattenOption(ilist(options)
            .map((o) => valueFor(o.value) ? some(o.value) : none()))
        .toList()
        .join(',');
    aggregateResult[name] = json;
  }

  @override
  bool evaluate(ConditionOperator operator, String targetValue) {
    switch (operator) {
      case ConditionOperator.equal:
      case ConditionOperator.contain:
        var targets = targetValue.split(",");
        return ilist(targets)
            .all((v) => _selected[v] != null ? _selected[v]!.value : false);
      default:
        return false;
    }
  }
}
