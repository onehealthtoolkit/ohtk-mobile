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

  String get evaluatedTitle => formatWithAnyMap(
        titleTemplate,
        ref.toJsonValue(),
      );

  String get evaluatedDescription => formatWithAnyMap(
        descriptionTemplate,
        ref.toJsonValue(),
      );
}

class SubformField extends Field {
  final forms = ObservableList<Subform>.of([]);

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
      f = forms.firstWhere((element) => element.name == name);
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

  _getNewSubformVarName() {
    return "${name}_${DateTime.now().millisecondsSinceEpoch}";
  }

  getSubformRecordTitle(String name) {
    var index = forms.indexWhere((element) => element.name == name);

    /// Title of subform view
    /// Use field label, if none, use question label, if none, use field name
    var title = label != null && label!.isNotEmpty
        ? label
        : (parent != null && parent!.label.isNotEmpty)
            ? parent!.label
            : this.name;
    return '(${index + 1}) $title';
  }

  Subform? addSubform({String? varName, Map<String, dynamic>? value}) {
    var formVarName = varName ?? _getNewSubformVarName();

    var subformForm = Form.fromJson(
      formReference!.jsonDefinition,
      '${formReference!.id}_$formVarName',
      formReference!.testFlag,
    );
    subformForm.loadJsonValue(value ?? {});

    var subform = Subform(subformForm,
        name: formVarName.trim(),
        titleTemplate: titleTemplate ?? '',
        descriptionTemplate: descriptionTemplate ?? '');

    forms.add(subform);
    return subform;
  }

  void deleteSubform(Subform subform) {
    forms.remove(subform);
  }

  @override
  void loadJsonValue(Map<String, dynamic> json) {
    if (json[name] != null && json[name] is SubformValueMap) {
      if (formReference != null) {
        var formValues = json[name] as SubformValueMap;

        for (var formValueMap in formValues.entries) {
          var varName = formValueMap.key;
          addSubform(varName: varName, value: formValueMap.value);
        }
      }
    }
  }

  @override
  String get renderedValue => IList.flattenOption(
          ilist(forms).map((o) => o.name.isNotEmpty ? some(o.name) : none()))
      .toList()
      .join(', ');

  @override
  void toJsonValue(Map<String, dynamic> aggregateResult) {
    Map<String, dynamic> json = {};
    var count = 0;
    for (var subform in forms) {
      count++;
      var values = subform.ref.toJsonValue();
      values['subformTitle'] = subform.evaluatedTitle;
      values['subformDescription'] = subform.evaluatedDescription;

      json['${name}_$count'] = values;
    }
    json["value"] = renderedValue;

    aggregateResult[name] = json;
    aggregateResult["${name}__value"] = renderedValue;
  }

  @override
  get value => throw UnimplementedError();
}
