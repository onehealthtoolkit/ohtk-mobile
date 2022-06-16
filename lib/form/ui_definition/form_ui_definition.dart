import 'package:podd_app/form/ui_definition/fields/field_ui_definition.dart';
import 'package:podd_app/form/ui_definition/question.dart';

import 'section.dart';
export "section.dart" show Section;
export "question.dart" show Question;
export 'fields/field_ui_definition.dart';

typedef DefinitionFindFunction = bool Function(
    FieldUIDefinition field, Question question);

class FormUIDefinition {
  List<Section> sections = [];
  FormUIDefinition();

  factory FormUIDefinition.fromJson(dynamic json) {
    var form = FormUIDefinition();
    var sectionsJson = json['sections'] as List;
    var _sections = sectionsJson
        .map((sectionJson) => Section.fromJson(sectionJson))
        .toList();
    form.sections.addAll(_sections);
    return form;
  }

  List<FieldUIDefinition> find(DefinitionFindFunction findFunction) {
    var result = List<FieldUIDefinition>.from([]);
    for (var section in sections) {
      for (var question in section.questions) {
        for (var field in question.fields) {
          if (findFunction(field, question)) {
            result.add(field);
          }
        }
      }
    }
    return result;
  }
}
