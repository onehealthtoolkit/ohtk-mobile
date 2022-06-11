import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/form/ui_definition/condition_definition.dart';
import 'package:podd_app/form/ui_definition/form_ui_definition.dart';

template(text) => """{
        "sections": [
          {
            "label": "section1",
            "questions": [
              {
                "label": "q1",
                "fields": [
                  $text 
                ]
              }
            ]
          }
        ]
      }""";

void main() {
  group("Text Field", () {
    test("Parse text field definition", () {
      var str = template("""
                  {
                    "id": "1",
                    "label": "name",
                    "name": "name",
                    "type": "text",
                    "description": "desc",
                    "suffixLabel": "my suffix",
                    "required": true
                  }""");
      var def = FormUIDefinition.fromJson(json.decode(str));
      var field = def.sections[0].questions[0].fields[0];
      expect(field, const TypeMatcher<TextFieldUIDefinition>());
      expect(field.required, isTrue);
      expect(field.suffixLabel, "my suffix");
    });

    test("Min, Max validation for Text Field", () {
      var str = template("""
                  {
                    "id": "1",
                    "label": "name",
                    "name": "name",
                    "type": "text",
                    "description": "desc",
                    "suffixLabel": "my suffix",
                    "required": true,
                    "minLength": 3,
                    "maxLength": 20
                  }""");
      var def = FormUIDefinition.fromJson(json.decode(str));
      var field = def.sections[0].questions[0].fields[0];
      expect(field, const TypeMatcher<TextFieldUIDefinition>());
      var textField = field as TextFieldUIDefinition;
      expect(textField.minLength, 3);
      expect(textField.maxLength, 20);
    });

    test("Support display condition", () {
      var str = template("""
        {
          "id": "1",
          "label": "name",
          "name": "name",
          "type": "text",
          "description": "desc",
          "suffixLabel": "my suffix",
          "required": true,
          "enableCondition": {
            "name": "age",
            "operator": "=",
            "value": "12"
          }
        }
      """);
      var def = FormUIDefinition.fromJson(json.decode(str));
      var field = def.sections[0].questions[0].fields[0];
      expect(field.enableCondition, isNotNull);
      expect(field.enableCondition!.name, "age");
      expect(field.enableCondition!.operator, ConditionOperator.equal);
      expect(field.enableCondition!.value, "12");
    });
  });

  group("Integer Field", () {
    test("Parse integer field definition", () {
      var str = template("""
                  {
                    "id": "1",
                    "label": "age",
                    "name": "age",
                    "type": "integer",
                    "description": "desc",
                    "suffixLabel": "years",
                    "required": false
                  }""");
      var def = FormUIDefinition.fromJson(json.decode(str));
      var field = def.sections[0].questions[0].fields[0];
      expect(field, const TypeMatcher<IntegerFieldUIDefinition>());
      expect(field.required, isFalse);
      expect(field.suffixLabel, "years");
    });

    test("Min, Max Validation for Integer field", () {
      var str = template("""{
        "id": "1",
        "label": "age",
        "name": "age",
        "type": "integer",
        "required": true,
        "min": 0,
        "max": 90
      }""");
      var def = FormUIDefinition.fromJson(json.decode(str));
      var field = def.sections[0].questions[0].fields[0];
      expect(field, const TypeMatcher<IntegerFieldUIDefinition>());
      var intField = field as IntegerFieldUIDefinition;
      expect(intField.max, 90);
      expect(intField.min, 0);
    });

    test("Support display condition", () {
      var str = template("""
        {
          "id": "1",
          "label": "age",
          "name": "age",
          "type": "integer",
          "required": true,
          "enableCondition": {
            "name": "age",
            "operator": "=",
            "value": "12"
          }
        }
      """);
      var def = FormUIDefinition.fromJson(json.decode(str));
      var field = def.sections[0].questions[0].fields[0];
      expect(field.enableCondition, isNotNull);
      expect(field.enableCondition!.name, "age");
      expect(field.enableCondition!.operator, ConditionOperator.equal);
      expect(field.enableCondition!.value, "12");
    });
  });

  group("Location Field", () {
    test("parse location field definition", () {
      var str = template("""
                  {
                    "id": "1",
                    "label": "location",
                    "name": "location",
                    "type": "location",
                    "description": "desc",
                    "required": true
                  }""");
      var def = FormUIDefinition.fromJson(json.decode(str));
      var field = def.sections[0].questions[0].fields[0];
      expect(field, const TypeMatcher<LocationFieldUIDefinition>());
      expect(field.required, isTrue);
    });
  });

  group("Image Field", () {
    test("Parse images field definition", () {
      var str = template("""
                  {
                    "id": "1",
                    "label": "images",
                    "name": "images",
                    "type": "images",
                    "description": "desc",
                    "required": true
                  }""");
      var def = FormUIDefinition.fromJson(json.decode(str));
      var field = def.sections[0].questions[0].fields[0];
      expect(field, const TypeMatcher<ImagesFieldUIDefinition>());
      expect(field.required, isTrue);
    });

    test("Support display condition", () {
      var str = template("""
        {
          "id": "1",
          "label": "images",
          "name": "images",
          "type": "images",
          "description": "desc",
          "required": true,
          "enableCondition": {
            "name": "age",
            "operator": "=",
            "value": "12"
          }
        }
      """);
      var def = FormUIDefinition.fromJson(json.decode(str));
      var field = def.sections[0].questions[0].fields[0];
      expect(field.enableCondition, isNotNull);
      expect(field.enableCondition!.name, "age");
      expect(field.enableCondition!.operator, ConditionOperator.equal);
      expect(field.enableCondition!.value, "12");
    });
  });

  group("Singlechoices Field", () {
    test("Parse single choices field", () {
      var str = template("""
          {
            "id": "1",
            "label": "disease",
            "name": "disease",
            "type": "singlechoices",
            "description": "desc",
            "required": true,
            "options": [
              {
                "label": "dengue",
                "value": "dengue"
              },
              {
                "label": "mers",
                "value": "mers"
              }
            ]
          }
        """);
      var def = FormUIDefinition.fromJson(json.decode(str));
      var field = def.sections[0].questions[0].fields[0];
      expect(field, const TypeMatcher<SingleChoicesFieldUIDefinition>());
      var singleChoicesField = field as SingleChoicesFieldUIDefinition;
      expect(2, singleChoicesField.options.length);
      expect("dengue", singleChoicesField.options[0].label);
    });

    test("Support display condition", () {
      var str = template("""
        {
          "id": "1",
          "label": "disease",
          "name": "disease",
          "type": "singlechoices",
          "description": "desc",
          "required": true,
          "options": [
            {
              "label": "dengue",
              "value": "dengue"
            },
            {
              "label": "mers",
              "value": "mers"
            }
          ],
          "enableCondition": {
            "name": "age",
            "operator": "=",
            "value": "12"
          }
        }
      """);
      var def = FormUIDefinition.fromJson(json.decode(str));
      var field = def.sections[0].questions[0].fields[0];
      expect(field.enableCondition, isNotNull);
      expect(field.enableCondition!.name, "age");
      expect(field.enableCondition!.operator, ConditionOperator.equal);
      expect(field.enableCondition!.value, "12");
    });
  });

  group("MultipleChoices Field", () {
    test("Parse multiple choices field", () {
      var str = template("""
          {
            "id": "1",
            "label": "symptom",
            "name": "symptom",
            "type": "multiplechoices",
            "description": "desc",
            "required": true,
            "options": [
              {
                "label": "cough",
                "value": "cough"
              },
              {
                "label": "fever",
                "value": "fever"
              }
            ]
          }
        """);
      var def = FormUIDefinition.fromJson(json.decode(str));
      var field = def.sections[0].questions[0].fields[0];
      expect(field, const TypeMatcher<MultipleChoicesFieldUIDefinition>());
    });

    test("Support display condition", () {
      var str = template("""
        {
          "id": "1",
          "label": "symptom",
          "name": "symptom",
          "type": "multiplechoices",
          "description": "desc",
          "required": true,
          "options": [
            {
              "label": "cough",
              "value": "cough"
            },
            {
              "label": "fever",
              "value": "fever"
            }
          ],
          "enableCondition": {
            "name": "age",
            "operator": "=",
            "value": "12"
          }
        }
      """);
      var def = FormUIDefinition.fromJson(json.decode(str));
      var field = def.sections[0].questions[0].fields[0];
      expect(field.enableCondition, isNotNull);
      expect(field.enableCondition!.name, "age");
      expect(field.enableCondition!.operator, ConditionOperator.equal);
      expect(field.enableCondition!.value, "12");
    });
  });

  group("Date field", () {
    test("Parse date field", () {
      var str = template("""
          {
            "id": "1",
            "label": "date",
            "name": "date",
            "type": "date",
            "description": "date",
            "required": true            
          }
        """);
      var def = FormUIDefinition.fromJson(json.decode(str));
      var field = def.sections[0].questions[0].fields[0];
      expect(field, const TypeMatcher<DateFieldUIDefinition>());
    });

    test("Support display condition", () {
      var str = template("""
          {
            "id": "1",
            "label": "date",
            "name": "date",
            "type": "date",
            "description": "date",
            "required": true,
            "enableCondition": {
              "name": "age",
              "operator": "=",
              "value": "12"
            }                       
          }
        """);
      var def = FormUIDefinition.fromJson(json.decode(str));
      var field = def.sections[0].questions[0].fields[0];
      expect(field.enableCondition, isNotNull);
      expect(field.enableCondition!.name, "age");
      expect(field.enableCondition!.operator, ConditionOperator.equal);
      expect(field.enableCondition!.value, "12");
    });
  });
}
