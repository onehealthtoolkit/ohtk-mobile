import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  late SingleChoicesField field;
  late SingleChoicesField requiredField;

  setUpAll(() {
    locator.registerSingletonAsync<AppLocalizations>(() async {
      return AppLocalizations.delegate.load(const Locale('en'));
    });
  });

  group("json", () {
    setUp(() {
      field = SingleChoicesField(
        "id",
        "disease",
        [
          ChoiceOption(label: "dengue", value: "dengue"),
          ChoiceOption(label: "mers", value: "mers"),
          ChoiceOption(label: "monkeypox", value: "monkeypox"),
          ChoiceOption(label: "other", value: "other", textInput: true),
        ],
      );
    });

    test("init from json", () {
      var field = SingleChoicesField.fromJson({
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
      expect(json["disease"], isNull);
      expect(json["disease__value"], isEmpty);
    });

    test("toJson with value", () {
      field.value = "mers";
      Map<String, dynamic> json = {};
      field.toJsonValue(json);
      expect(json["disease"], "mers");
      expect(json["disease__value"], "mers");
    });

    test("toJson with value and text", () {
      field.value = "other";
      field.text = "covid19";
      Map<String, dynamic> json = {};
      field.toJsonValue(json);
      expect(json["disease"], "other");
      expect(json["disease__value"], "other - covid19");
    });

    test("load json value", () {
      field.loadJsonValue({
        "disease": "monkeypox",
      });
      expect(field.value, "monkeypox");
    });

    test("toJson with value with text enable", () {
      field.value = "other";
      field.text = "test";
      Map<String, dynamic> json = {};
      field.toJsonValue(json);
      expect(json["disease"], "other");
      expect(json["disease_text"], "test");
    });

    test("load json value with text enable", () {
      field.loadJsonValue({"disease": "other", "disease_text": "malaria"});
      expect(field.value, "other");
      expect(field.text, "malaria");
    });
  });

  group("validation", () {
    setUp(() {
      field = SingleChoicesField(
        "id",
        "disease",
        [
          ChoiceOption(label: "dengue", value: "dengue"),
          ChoiceOption(label: "mers", value: "mers"),
          ChoiceOption(label: "monkeypox", value: "monkeypox"),
          ChoiceOption(label: "other", value: "other", textInput: true),
        ],
      );

      requiredField = SingleChoicesField(
        "id",
        "disease",
        [
          ChoiceOption(label: "dengue", value: "dengue"),
          ChoiceOption(label: "mers", value: "mers"),
          ChoiceOption(label: "monkeypox", value: "monkeypox"),
          ChoiceOption(label: "other", value: "other", textInput: true),
        ],
        required: true,
        requiredMessage: "test required message",
      );
    });

    test("required flag", () {
      expect(field.validate(), isTrue);
      expect(requiredField.validate(), isFalse);
    });

    test("required with value should be valid", () {
      requiredField.value = "mers";
      expect(requiredField.validate(), isTrue);
    });

    test("textInput choice is selected", () {
      requiredField.value = 'other';
      expect(requiredField.validate(), isFalse);
      requiredField.text = "other text value";
      expect(requiredField.validate(), isTrue);
      requiredField.text = "";
      expect(requiredField.validate(), isFalse);
    });
  });
}
