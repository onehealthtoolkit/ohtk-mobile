part of opensurveillance_form;

class Question implements ConiditionSource {
  late Form form;
  final String label;
  final String? name;
  final String? description;
  List<Field> fields = List.empty(growable: true);
  Condition? condition;

  Values? values;

  Question(this.label, {this.name, this.description, this.condition});

  factory Question.fromJson(Map<String, dynamic> json) {
    Condition? condition;
    if (json['condition'] != null) {
      condition = SimpleCondition.fromJson(json["condition"]);
    }
    var question = Question(
      json["label"],
      name: json["name"],
      condition: condition,
    );
    var jsonFields = json["fields"] as List;
    for (var jsonField in jsonFields) {
      var field = Field.fromJson(jsonField);
      field.parent = question;
      question.fields.add(field);
    }
    return question;
  }

  factory Question.withFields(label, List<Field> fields,
      {String? name, String? description, Condition? condition}) {
    var question = Question(label,
        name: name, description: description, condition: condition);
    question.fields = fields;
    return question;
  }

  get numberOfFields => fields.length;

  Computed<bool>? _displayComputed;
  get display => (_displayComputed ??= Computed<bool>(() {
        if (condition != null) {
          return condition!.evaluate(form.values);
        } else {
          return true;
        }
      }, name: 'question_${label}_display'))
          .value;

  void _registerValues(Values parentValues, Form form) {
    this.form = form;
    if (name != null) {
      values = Values(parent: parentValues);
      parentValues.setValues(name!, values!);
    }
    var currentValues = name != null ? values! : parentValues;
    ilist(fields).forEach((field) {
      field._registerValues(currentValues, form);
    });
  }

  bool validate() {
    if (!display) {
      return true;
    }
    return ilist(fields).all((field) => field.validate());
  }

  void loadJsonValue(Map<String, dynamic> json) {
    var evaluateJson = json;
    if (name != null && json[name] != null) {
      evaluateJson = json[name];
    }

    for (var field in fields) {
      field.loadJsonValue(evaluateJson);
    }
  }

  void toJsonValue(Map<String, dynamic> result) {
    if (display) {
      Map<String, dynamic> aggregateResult = result;
      if (name != null) {
        aggregateResult = {};
        result[name!] = aggregateResult;
      }
      for (var field in fields) {
        field.toJsonValue(aggregateResult);
      }
    }
  }

  IList<Condition> allConditions() {
    var fieldConditions = ilist(fields).map<Option<Condition>>((field) =>
        field.condition != null ? some(field.condition!.by(field)) : none());
    IList<Option<Condition>> questionCondition =
        ilist([condition != null ? some(condition!.by(this)) : none()]);

    return IList.flattenOption(fieldConditions.plus(questionCondition));
  }

  IList<Field> allFields() {
    return ilist(fields);
  }
}
