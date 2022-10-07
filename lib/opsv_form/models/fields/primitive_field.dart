part of opensurveillance_form;

abstract class PrimitiveField<T> extends Field {
  final Observable<T?> _value = Observable(null);

  PrimitiveField(
    String id,
    String name, {
    String? label,
    String? description,
    String? suffixLabel,
    bool? required,
    String? requiredMessage,
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

  @override
  T? get value => _value.value;

  set value(T? v) {
    runInAction(() {
      _value.value = v;
      if (!isValid) {
        clearError();
      }
    });
  }

  @override
  void loadJsonValue(Map<String, dynamic> json) {
    if (json[name] != null) {
      value = json[name];
    }
  }

  @override
  void toJsonValue(Map<String, dynamic> aggregateResult) {
    aggregateResult[name] = value;
    aggregateResult["${name}__value"] = renderedValue;
  }
}
