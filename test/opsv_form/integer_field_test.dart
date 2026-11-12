import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:podd_app/l10n/app_localizations.dart';

void main() {
  late IntegerField field;

  setUpAll(() async {
    locator.registerSingletonAsync<AppLocalizations>(() async {
      return AppLocalizations.delegate.load(const Locale('en'));
    });
    await locator.allReady();
  });

  group("json value", () {
    setUp(() {
      field = IntegerField("id", "age");
    });

    test("toJson with value", () {
      field.value = 12;
      Map<String, dynamic> json = {};
      field.toJsonValue(json);
      expect(json["age"], 12);
      expect(json["age__value"], "12");
    });

    test("toJson without value", () {
      Map<String, dynamic> json = {};
      field.toJsonValue(json);
      expect(json["age"], isNull);
      expect(json["age__value"], isEmpty);
    });

    test("load json data", () {
      field.loadJsonValue({"age": 23});
      expect(field.value, 23);
    });
  });

  group("validation", () {
    test("optional animal total stays blank with configured bounds", () {
      field = IntegerField.fromJson({
        "id": "num_total_animal",
        "name": "num_total_animal",
        "required": false,
        "min": 0,
      });
      expect(field.validate(), isTrue);
      final values = <String, dynamic>{};
      field.toJsonValue(values);
      expect(values["num_total_animal"], isNull);

      field.value = 12;
      expect(field.validate(), isTrue);
      field.value = null;
      expect(field.validate(), isTrue);
      expect(field.invalidMessage, isNull);
    });

    test("optional integer still validates supplied values", () {
      field = IntegerField("id", "count", required: false, min: 0, max: 10);
      expect(field.validate(), isTrue);
      field.value = -1;
      expect(field.validate(), isFalse);
      field.value = 0;
      expect(field.validate(), isTrue);
      field.value = 10;
      expect(field.validate(), isTrue);
      field.value = 11;
      expect(field.validate(), isFalse);
      field.value = null;
      expect(field.validate(), isTrue);
    });

    test("optional integer may omit either bound", () {
      for (final bounds in [
        {"min": 0},
        {"max": 10},
        {"min": 0, "max": 10},
      ]) {
        field = IntegerField.fromJson({
          "id": "count",
          "name": "count",
          "required": false,
          ...bounds,
        });
        expect(field.validate(), isTrue);
      }
    });

    test("required bounded integer still rejects blank", () {
      field = IntegerField("id", "count", required: true, min: 0, max: 10);
      expect(field.validate(), isFalse);
      field.value = 0;
      expect(field.validate(), isTrue);
      field.value = null;
      expect(field.validate(), isFalse);
    });

    test("no required", () {
      field = IntegerField("id", "age", required: false);
      expect(field.validate(), isTrue);
    });

    test("with required", () {
      field = IntegerField("id", "age", required: true);
      expect(field.validate(), isFalse);
      field.value = 22;
      expect(field.validate(), isTrue);
    });

    test("with min value", () {
      field = IntegerField("id", "age",
          required: true, min: 10, minMessage: "custom min message");
      field.value = 9;
      expect(field.validate(), isFalse);
      expect(field.invalidMessage, "custom min message");
      field.value = 10;
      expect(field.validate(), isTrue);
      expect(field.invalidMessage, isNull);
      field.value = 11;
      expect(field.validate(), isTrue);
    });

    test("with max value", () {
      field = IntegerField("id", "age",
          required: true, max: 100, maxMessage: "custom max message");
      field.value = 101;
      expect(field.validate(), isFalse);
      expect(field.invalidMessage, "custom max message");
      field.value = 100;
      expect(field.validate(), isTrue);
      expect(field.invalidMessage, isNull);
      field.value = 11;
      expect(field.validate(), isTrue);
    });
  });
}
