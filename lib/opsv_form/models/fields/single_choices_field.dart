part of opensurveillance_form;

class SingleChoicesField extends PrimitiveField<String> {
  List<ChoiceOption> options;

  // viewmodel for custom text input
  // enable by setting option.textInput = true
  final _text = Observable<String?>(null);

  // error message for custom text input
  final _invalidTextInputMessage = Observable<String?>(null);

  SingleChoicesField(
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
        );

  factory SingleChoicesField.fromJson(Map<String, dynamic> json) {
    var condition = parseConditionFromJson(json);
    var options = parseOptionFromJson(json);
    return SingleChoicesField(
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

  set text(String? newValue) {
    runInAction(() {
      _text.value = newValue;
      clearTextInputError();
    });
  }

  String? get text => _text.value;

  String? get invalidTextInputMessage => _invalidTextInputMessage.value;

  set invalidTextInputMessage(value) {
    runInAction(() {
      _invalidTextInputMessage.value = value;
    });
  }

  void clearTextInputError() {
    runInAction(() {
      _invalidTextInputMessage.value = null;
    });
  }

  @override
  set value(String? newValue) {
    if (ilist(options).any((option) => option.value == newValue)) {
      runInAction(() {
        super.value = newValue;
        _text.value = null;
      });
    }
  }

  @override
  bool _validate() {
    return runInAction(() {
      clearError();
      var validateFns = ilist([_validateRequired, _validateInputText]);
      return validateFns.all((fn) => fn());
    });
  }

  Option<ChoiceOption> _findSelectedOption() {
    return ilist(options).find((option) => option.value == value);
  }

  _validateInputText() {
    var result = _findSelectedOption().filter((option) => option.textInput);
    if (result.isSome()) {
      if (text == null || (text != null && text!.isEmpty)) {
        invalidTextInputMessage = "This field is required";
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

  @override
  void toJsonValue(Map<String, dynamic> aggregateResult) {
    super.toJsonValue(aggregateResult);
    aggregateResult["${name}_text"] = text;
    aggregateResult["${name}__value"] = renderedValue;
  }

  @override
  void loadJsonValue(Map<String, dynamic> json) {
    super.loadJsonValue(json);
    var key = "${name}_text";
    if (json[key] != null) {
      text = json[key];
    }
  }

  @override
  String get renderedValue {
    return (value ?? "") + (text != null ? " - $text" : '');
  }
}
