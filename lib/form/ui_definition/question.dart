import 'fields/field_ui_definition.dart';

class Question {
  String label;
  String? description;
  String? objectName;

  List<FieldUIDefinition> fields = [];

  Question({
    required this.label,
    this.description,
    this.objectName,
  });

  addField(FieldUIDefinition field) {
    fields.add(field);
  }

  factory Question.fromJson(dynamic json) {
    var question = Question(
      label: json['label'],
      description: json['description'],
      objectName: json['objectName'],
    );
    question.fields = (json['fields'] as List)
        .map((fieldJson) => FieldUIDefinition.fromJson(fieldJson))
        .toList();

    return question;
  }
}
