import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/form/form_data/form_data_definition.dart';
import 'package:podd_app/form/form_data/form_data_definition_builder.dart';
import 'package:podd_app/form/ui_definition/form_ui_definition.dart';

void main() {
  group("form ui definition -> form data", () {
    test("ui text field -> StringDataDefinition", () {
      var uiDefinition = FormUIDefinition.fromJson(json.decode("""
      {
        "sections": [
          {
            "label": "section1",
            "questions": [{
              "label": "ข้อมูลชื่อ",
              "fields": [
                {
                  "id": "initial",
                  "name": "initial",
                  "label": "คำนำหน้าชื่อ",
                  "mandatory": true,
                  "type": "text"
                }
              ]
            }]
          }
        ]
      }
      """));
      Map<String, BaseDataDefinition> formValue =
          parseFormUIDefinition(uiDefinition);
      expect(formValue['initial'], const TypeMatcher<StringDataDefinition>());
    });

    test("ui integer field -> IntegerDataDefinition ", () {
      var uiDefinition = FormUIDefinition.fromJson(json.decode("""
      {
        "sections": [
          {
            "label": "section1",
            "questions": [{
              "label": "ข้อมูลชื่อ",
              "fields": [
                {
                  "id": "age",
                  "name": "age",
                  "label": "age",
                  "mandatory": true,
                  "type": "integer"
                }
              ]
            }]
          }
        ]
      }
      """));
      Map<String, BaseDataDefinition> formValue =
          parseFormUIDefinition(uiDefinition);
      expect(formValue['age'], const TypeMatcher<IntegerDataDefinition>());
    });

    test("ui image field -> StringDataDefinition ", () {
      var uiDefinition = FormUIDefinition.fromJson(json.decode("""
      {
        "sections": [
          {
            "label": "section1",
            "questions": [{
              "label": "ข้อมูลชื่อ",
              "fields": [
                {
                  "id": "images",
                  "name": "images",
                  "label": "images",
                  "mandatory": true,
                  "type": "image"
                }
              ]
            }]
          }
        ]
      }
      """));
      Map<String, BaseDataDefinition> formValue =
          parseFormUIDefinition(uiDefinition);
      expect(formValue['images'], const TypeMatcher<StringDataDefinition>());
    });
  });

  test("ui locaiton field -> StringDataDefinition", () {
    var uiDefinition = FormUIDefinition.fromJson(json.decode("""
      {
        "sections": [
          {
            "label": "section1",
            "questions": [{
              "label": "ข้อมูลทั่วไป",
              "fields": [                
                {
                  "id": "location",
                  "name": "location",
                  "label": "location",
                  "mandatory": true,
                  "type": "location"
                }
              ]
            }]
          }
        ]
      }
      """));
    Map<String, BaseDataDefinition> formValue =
        parseFormUIDefinition(uiDefinition);
    expect(formValue['location'], const TypeMatcher<StringDataDefinition>());
  });
}
