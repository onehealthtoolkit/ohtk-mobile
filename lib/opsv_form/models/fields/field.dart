part of opensurveillance_form;

abstract class Field implements ConiditionSource {
  late Form form;
  String id;
  String name;
  String? label;
  String? description;
  String? suffixLabel;
  bool? required;
  String? requiredMessage;
  Condition? condition;
  String? tags;
  Question? parent;

  final _invalidMessage = Observable<String?>(null);

  Field(
    this.id,
    this.name, {
    this.label,
    this.description,
    this.suffixLabel,
    this.required = false,
    this.requiredMessage,
    this.condition,
    this.tags,
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    switch (json["type"]) {
      case "integer":
        return IntegerField.fromJson(json);
      case "date":
        return DateField.fromJson(json);
      case "decimal":
        return DecimalField.fromJson(json);
      case "images":
        return ImagesField.fromJson(json);
      case "files":
        return FilesField.fromJson(json);
      case "location":
        return LocationField.fromJson(json);
      case "multiplechoices":
        return MultipleChoicesField.fromJson(json);
      case "singlechoices":
        return SingleChoicesField.fromJson(json);
      case "text":
      default:
        return TextField.fromJson(json);
    }
  }

  get value;

  String get renderedValue;

  void _registerValues(Values values, Form form) {
    this.form = form;
    var delegate = ValueDelegate(() => this);
    values.setValueDelegate(id, delegate);
  }

  Computed<bool>? _displayComputed;
  bool get display => (_displayComputed ??= Computed<bool>(() {
        if (condition != null) {
          return condition!.evaluate(form.values);
        } else {
          return true;
        }
      }, name: 'field_${id}_display'))
          .value;

  bool get isValid => _invalidMessage.value == null;

  String? get invalidMessage => _invalidMessage.value;

  void markError(String message) {
    runInAction(() {
      _invalidMessage.value = message;
    });
  }

  void clearError() {
    if (_invalidMessage.value != null) {
      runInAction(() {
        _invalidMessage.value = null;
      });
    }
  }

  bool validate() {
    if (!display) {
      return true;
    }
    return _validate();
  }

  bool _validate();

  void loadJsonValue(Map<String, dynamic> json);

  void toJsonValue(Map<String, dynamic> aggregateResult);

  bool _validateRequired() {
    if (required == true && value == null) {
      final localize = locator<AppLocalizations>();
      markError(localize.validateRequiredMsg);
      return false;
    }
    return true;
  }

  bool _evaluate(ConditionOperator operator, String targetValue) {
    if (display) {
      if (parent != null && parent!.display) {
        return evaluate(operator, targetValue);
      }
    }
    return false;
  }

  bool evaluate(ConditionOperator operator, String targetValue);

  String get displayName {
    return label != "" && label != null ? label! : parent!.label;
  }
}
