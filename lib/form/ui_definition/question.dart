import 'condition_definition.dart';
import 'fields/field_ui_definition.dart';

//
//  example:
//  {
//     "enableCondition": {
//       "name": "disease",
//       "operator": "=",
//       "value": "other"
//     },
//     "fields": [
//       {
//         "id": "more",
//         "name": "more",
//         "required": true,
//         "type": "text"
//       }
//     ],
//     "label": "give me more detail"
//   },
class Question {
  String label;
  String? description;
  String? objectName;
  ConditionDefinition? enableCondition;

  List<FieldUIDefinition> fields = [];

  Question({
    required this.label,
    this.description,
    this.objectName,
    this.enableCondition,
  });

  addField(FieldUIDefinition field) {
    fields.add(field);
  }

  factory Question.fromJson(dynamic json) {
    var question = Question(
      label: json['label'],
      description: json['description'],
      objectName: json['objectName'],
      enableCondition: parseCondition(json, "enableCondition"),
    );
    question.fields = (json['fields'] as List)
        .map((fieldJson) => FieldUIDefinition.fromJson(fieldJson))
        .toList();

    return question;
  }
}
