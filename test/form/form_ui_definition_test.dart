import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/form/ui_definition/fields/images_field_ui_definition.dart';
import 'package:podd_app/form/ui_definition/fields/integer_field_ui_definition.dart';
import 'package:podd_app/form/ui_definition/fields/location_field_ui_definition.dart';
import 'package:podd_app/form/ui_definition/fields/text_field_ui_definition.dart';
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
  });
}
