import 'section.dart';
export "section.dart" show Section;
export "question.dart" show Question;
export 'fields/field_ui_definition.dart';

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
}
