part of opensurveillance_form;

class Section {
  late Form form;
  String label;
  String? description;
  List<Question> questions = List.empty(growable: true);

  Section(this.label, {this.description});

  factory Section.fromJson(Map<String, dynamic> json) {
    var section = Section(json["label"]);
    var jsonQuestions = json["questions"] as List;
    for (var jsonQuestion in jsonQuestions) {
      section.questions.add(Question.fromJson(jsonQuestion));
    }
    return section;
  }

  factory Section.withQuestions(label, List<Question> questions,
      {description}) {
    var section = Section(label, description: description);
    section.questions = questions;
    return section;
  }

  get numberOfQuestions => questions.length;

  void _registerValues(Values values, Form form) {
    this.form = form;
    for (var question in questions) {
      question._registerValues(values, form);
    }
  }

  bool validate() {
    var result = true;
    for (var question in questions) {
      result = result && question.validate();
    }
    return result;
  }

  void loadJsonValue(Map<String, dynamic> json) {
    for (var question in questions) {
      question.loadJsonValue(json);
    }
  }

  void toJsonValue(Map<String, dynamic> result) {
    for (var question in questions) {
      question.toJsonValue(result);
    }
  }

  IList<Condition> allConiditions() {
    return ilist(questions).flatMap((question) => question.allConditions());
  }
}
