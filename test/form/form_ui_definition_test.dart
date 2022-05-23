import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
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
  group('Test json parser', () {
    test("text field definition", () {
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

    test("integer field definition", () {
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

    test("Location field definition", () {
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

    test("Images field definition", () {
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

    test("Min, Max validation for Text Feidl", () {
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
  });
}
