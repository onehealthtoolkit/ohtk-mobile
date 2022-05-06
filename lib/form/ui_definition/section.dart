import 'question.dart';

class Section {
  String label;
  String? description;

  List<Question> questions = [];

  Section({
    required this.label,
    this.description,
  });

  addQuestion(Question question) {
    questions.add(question);
  }

  factory Section.fromJson(dynamic json) {
    var section = Section(
      label: json['label'],
      description: json['description'],
    );
    section.questions = (json['questions'] as List)
        .map((questionJson) => Question.fromJson(questionJson))
        .toList();
    return section;
  }
}
