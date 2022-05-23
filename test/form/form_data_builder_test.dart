import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/form/form_data/definitions/form_data_definition.dart';
import 'package:podd_app/form/form_data/definitions/form_data_definition_builder.dart';
import 'package:podd_app/form/form_data/definitions/form_data_validation.dart';
import 'package:podd_app/form/ui_definition/form_ui_definition.dart';

template(String body) {
  return json.decode("""
      {
        "sections": [
          {
            "label": "section1",
            "questions": [{
              "label": "ข้อมูลชื่อ",
              "fields": [
                $body
              ]
            }]
          }
        ]
      }
      """);
}

void main() {
  group("form ui definition -> form data", () {
    group("Text Field", () {
      test("ui text field -> StringDataDefinition", () {
        var uiDefinition = FormUIDefinition.fromJson(template("""{
                  "id": "initial",
                  "name": "initial",
                  "label": "คำนำหน้าชื่อ",
                  "type": "text"
                }"""));
        Map<String, BaseDataDefinition> formValue =
            parseFormUIDefinition(uiDefinition);
        expect(formValue['initial'], const TypeMatcher<StringDataDefinition>());
      });

      test("required validation", () {
        var uiDefinition = FormUIDefinition.fromJson(template("""{
                  "id": "initial",
                  "name": "initial",
                  "label": "คำนำหน้าชื่อ",
                  "type": "text",
                  "required": true
                }"""));
        Map<String, BaseDataDefinition> formValue =
            parseFormUIDefinition(uiDefinition);
        StringDataDefinition dataDefinition =
            formValue['initial'] as StringDataDefinition;
        expect(dataDefinition.validations.length, 1);
        expect(dataDefinition.validations[0],
            const TypeMatcher<RequiredValidationDefinition>());
      });

      test("min validation", () {
        var uiDefinition = FormUIDefinition.fromJson(template("""{
                  "id": "citizenId",
                  "name": "citizenId",
                  "label": "citizen id",
                  "type": "text",
                  "minLength": 13
                }"""));
        Map<String, BaseDataDefinition> formValue =
            parseFormUIDefinition(uiDefinition);
        StringDataDefinition dataDefinition =
            formValue['citizenId'] as StringDataDefinition;
        expect(dataDefinition.validations.length, 1);
        expect(dataDefinition.validations[0],
            const TypeMatcher<MinMaxLengthValidationDefinition>());
        expect(
            13,
            (dataDefinition.validations[0] as MinMaxLengthValidationDefinition)
                .minLength);
      });

      test("max validation", () {
        var uiDefinition = FormUIDefinition.fromJson(template("""{
                  "id": "citizenId",
                  "name": "citizenId",
                  "label": "citizen id",
                  "type": "text",
                  "minLength": 13,
                  "maxLength": 20
                }"""));
        Map<String, BaseDataDefinition> formValue =
            parseFormUIDefinition(uiDefinition);
        StringDataDefinition dataDefinition =
            formValue['citizenId'] as StringDataDefinition;
        expect(dataDefinition.validations.length, 1);
        expect(dataDefinition.validations[0],
            const TypeMatcher<MinMaxLengthValidationDefinition>());
        expect(
            13,
            (dataDefinition.validations[0] as MinMaxLengthValidationDefinition)
                .minLength);
        expect(
            20,
            (dataDefinition.validations[0] as MinMaxLengthValidationDefinition)
                .maxLength);
      });
    });

    group("Integer Field", () {
      test("ui integer field -> IntegerDataDefinition ", () {
        var uiDefinition = FormUIDefinition.fromJson(template("""{
                  "id": "age",
                  "name": "age",
                  "label": "age",
                  "type": "integer"
                }"""));
        Map<String, BaseDataDefinition> formValue =
            parseFormUIDefinition(uiDefinition);
        expect(formValue['age'], const TypeMatcher<IntegerDataDefinition>());
      });

      test("min validation", () {
        var uiDefinition = FormUIDefinition.fromJson(template("""{
                  "id": "age",
                  "name": "age",
                  "label": "age",
                  "type": "integer",
                  "min": 0,
                  "max": 120
                }"""));
        Map<String, BaseDataDefinition> formValue =
            parseFormUIDefinition(uiDefinition);
        IntegerDataDefinition dataDefinition =
            formValue['age'] as IntegerDataDefinition;
        expect(dataDefinition.validations.length, 1);
        expect(dataDefinition.validations[0],
            const TypeMatcher<MinMaxValidationDefinition>());
        expect(0,
            (dataDefinition.validations[0] as MinMaxValidationDefinition).min);
        expect(120,
            (dataDefinition.validations[0] as MinMaxValidationDefinition).max);
      });
    });

    group("Images Field", () {
      test("ui image field -> ImagesDataDefinition ", () {
        var uiDefinition = FormUIDefinition.fromJson(template("""{
                  "id": "images",
                  "name": "images",
                  "label": "images",
                  "type": "images"
                  }"""));
        Map<String, BaseDataDefinition> formValue =
            parseFormUIDefinition(uiDefinition);
        expect(formValue['images'], const TypeMatcher<ImagesDataDefinition>());
      });
    });

    group("Location Field", () {
      test("ui locaiton field -> StringDataDefinition", () {
        var uiDefinition = FormUIDefinition.fromJson(template("""{
                  "id": "location",
                  "name": "location",
                  "label": "location",
                  "mandatory": true,
                  "type": "location"
                }"""));
        Map<String, BaseDataDefinition> formValue =
            parseFormUIDefinition(uiDefinition);
        expect(
            formValue['location'], const TypeMatcher<LocationDataDefinition>());
      });
    });

    group("Singlechoices Field", () {
      test("ui singlechoices field -> SingleChoicesDataDefinition", () {
        var uiDefinition = FormUIDefinition.fromJson(template("""{
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
          }"""));
        Map<String, BaseDataDefinition> formValue =
            parseFormUIDefinition(uiDefinition);
        expect(formValue['disease'],
            const TypeMatcher<SingleChoiceDataDefinition>());
      });

      test(
          "ui singlechoices field with input flag -> SingleChoicesDataDefinition",
          () {
        var uiDefinition = FormUIDefinition.fromJson(template("""{
            "id": "1",
            "label": "disease",
            "name": "disease",
            "type": "singlechoices",
            "description": "desc",
            "required": true,
            "options": [
              {
                "label": "dengue",
                "value": "dengue",
                "input": true            
              },
              {
                "label": "mers",
                "value": "mers"
              }
            ]
          }"""));
        Map<String, BaseDataDefinition> formValue =
            parseFormUIDefinition(uiDefinition);
        expect(formValue['disease'],
            const TypeMatcher<SingleChoiceDataDefinition>(),
            reason: 'formValue must have a disease field');
        var definition = formValue['disease'] as SingleChoiceDataDefinition;
        expect(definition.hasInput, true);
      });
    });
  });
}
