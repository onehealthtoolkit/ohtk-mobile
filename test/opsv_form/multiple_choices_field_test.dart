import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  late MultipleChoicesField field;

  setUpAll(() {
    locator.registerSingletonAsync<AppLocalizations>(() async {
      return AppLocalizations.delegate.load(const Locale('en'));
    });
  });

  group("json", () {
    setUp(() {
      field = MultipleChoicesField("id", "symptom", [
        ChoiceOption(label: "sore throat", value: "sore_throat"),
        ChoiceOption(label: "headache", value: "headache", textInput: true),
        ChoiceOption(label: "fever", value: "fever"),
      ]);
    });
    test("init from json", () {
      var field = MultipleChoicesField.fromJson({
        "id": "1",
        "name": "disease",
        "options": [
          {"label": "dengue", "value": "dengue", "textInput": false},
          {"label": "mers", "value": "mers", "textInput": false},
          {"label": "other", "value": "other", "textInput": true},
        ]
      });
      expect(field.options.length, 3);
    });

    test("toJson without value", () {
      Map<String, dynamic> json = {};
      field.toJsonValue(json);
      expect(json["symptom"], isNotNull);
      expect(json["symptom"]["sore_throat"], isFalse);
      expect(json["symptom"]["headache"], isFalse);
      expect(json["symptom"]["fever"], isFalse);
      expect(json["symptom"]["value"], "");
      expect(json["symptom__value"], isEmpty);
    });

    test("toJson with value", () {
      field.setSelectedFor("sore_throat", true);
      field.setSelectedFor("fever", true);
      Map<String, dynamic> json = {};
      field.toJsonValue(json);
      expect(json["symptom"], isNotNull);
      expect(json["symptom"]["sore_throat"], isTrue);
      expect(json["symptom"]["headache"], isFalse);
      expect(json["symptom"]["fever"], isTrue);
      expect(json["symptom"]["value"], "sore_throat, fever");
      expect(json["symptom__value"], "sore_throat, fever");
    });

    test("toJson with value and text", () {
      field.setSelectedFor("sore_throat", true);
      field.setSelectedFor("headache", true);
      field.setTextValueFor("headache", "migraine");
      Map<String, dynamic> json = {};
      field.toJsonValue(json);
      expect(json["symptom"], isNotNull);
      expect(json["symptom"]["sore_throat"], isTrue);
      expect(json["symptom"]["headache"], isTrue);
      expect(json["symptom"]["fever"], isFalse);
      expect(json["symptom"]["value"], "sore_throat, headache");
      expect(json["symptom__value"], "sore_throat, headache - migraine");
    });

    test("load jsonValue", () {
      field.loadJsonValue({
        "symptom": {
          "sore_throat": false,
          "headache": true,
          "fever": false,
        }
      });
      expect(field.valueFor("sore_throat"), false);
      expect(field.valueFor("headache"), true);
      expect(field.valueFor("fever"), false);
    });
  });

  group("validation", () {
    test("is not required", () {
      field = MultipleChoicesField(
        "id",
        "symptom",
        [
          ChoiceOption(label: "sore throat", value: "sore_throat"),
          ChoiceOption(label: "headache", value: "headache"),
          ChoiceOption(label: "fever", value: "fever"),
        ],
        required: false,
      );
      expect(field.validate(), isTrue);
    });
    test("is required", () {
      field = MultipleChoicesField(
        "id",
        "symptom",
        [
          ChoiceOption(label: "sore throat", value: "sore_throat"),
          ChoiceOption(label: "headache", value: "headache"),
          ChoiceOption(label: "fever", value: "fever"),
        ],
        required: true,
      );
      expect(field.validate(), isFalse);

      field.setSelectedFor("headache", true);
      expect(field.validate(), isTrue);

      field.setSelectedFor("headache", false);
      expect(field.validate(), isFalse);
    });
  });
}
