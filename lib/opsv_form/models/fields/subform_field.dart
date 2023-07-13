part of opensurveillance_form;

typedef SubformValueMap = Map<String, Map<String, dynamic>>;

class Subform {
  Form ref;
  String name;
  String titleTemplate;
  String descriptionTemplate;

  Subform(
    this.ref, {
    required this.name,
    required this.titleTemplate,
    required this.descriptionTemplate,
  });

  String get evaluatedTitle => formatWithMap(
        titleTemplate,
        ref.toJsonValue() as Map<String, String>,
      );

  String get evaluatedDescription => formatWithMap(
        descriptionTemplate,
        ref.toJsonValue() as Map<String, String>,
      );
}

class SubformField extends Field {
  final _forms = ObservableList<Subform>.of([]);
  final String formRef;
  String? titleTemplate;
  String? descriptionTemplate;

  SubformField(
    String id,
    String name, {
    String? label,
    String? description,
    String? suffixLabel,
    bool? required,
    String? requiredMessage,
    Condition? condition,
    String? tags,
    required this.formRef,
    this.titleTemplate,
    this.descriptionTemplate,
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

  factory SubformField.fromJson(Map<String, dynamic> json) {
    var condition = parseConditionFromJson(json);

    return SubformField(
      json["id"],
      json["name"],
      label: json["label"],
      description: json["description"],
      suffixLabel: json["suffixLabel"],
      required: json["required"],
      requiredMessage: json["requiredMessage"],
      condition: condition,
      tags: json["tags"],
      formRef: json["formRef"],
      titleTemplate: json["titleTemplate"],
      descriptionTemplate: json["descriptionTemplate"] ?? '',
    );
  }

  Form? get formReference => form.subforms[formRef];

  Subform? getSubformByName(String name) {
    Subform? f;
    try {
      f = _forms.firstWhere((element) => element.name == name);
    } catch (_) {
      // not found
    }
    return f;
  }

  @override
  bool _validate() {
    return true;
  }

  @override
  bool evaluate(ConditionOperator operator, String targetValue) {
    return true;
  }

  @override
  void loadJsonValue(Map<String, dynamic> json) {
    if (json[name] != null && json[name] is SubformValueMap) {
      if (formReference != null) {
        var formValues = json[name] as SubformValueMap;
        var count = 0;

        for (var formValueMap in formValues.entries) {
          count++;
          var formName = formValueMap.key;
          var subformForm = Form.fromJson(
              formReference!.jsonDefinition, '${formReference!.id}_$count');

          subformForm.loadJsonValue(formValueMap.value);

          var subform = Subform(subformForm,
              name: formName,
              titleTemplate: titleTemplate ?? '',
              descriptionTemplate: descriptionTemplate ?? '');

          _forms.add(subform);
        }
      }
    }
  }

  @override
  String get renderedValue => IList.flattenOption(
          ilist(_forms).map((o) => o.name.isNotEmpty ? some(o.name) : none()))
      .toList()
      .join(', ');

  @override
  void toJsonValue(Map<String, dynamic> aggregateResult) {
    Map<String, dynamic> json = {};
    for (var form in _forms) {
      json[form.name] = form.ref.toJsonValue();
    }
    json["value"] = renderedValue;

    aggregateResult[name] = json;
    aggregateResult["${name}__value"] = renderedValue;
  }

  @override
  get value => throw UnimplementedError();
}
