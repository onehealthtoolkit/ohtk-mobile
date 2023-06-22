import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  late DecimalField field;

  setUpAll(() {
    locator.registerSingletonAsync<AppLocalizations>(() async {
      return AppLocalizations.delegate.load(const Locale('en'));
    });
  });

  group("json value", () {
    setUp(() {
      field = DecimalField("id", "salary");
    });

    test("to json with value", () {
      var salary = Decimal.parse("100.00");
      field.value = salary;
      Map<String, dynamic> json = {};
      field.toJsonValue(json);
      expect(json["salary"], salary.toStringAsFixed(2));
      expect(json["salary__value"], salary.toStringAsFixed(2));
    });

    test("to json without value", () {
      Map<String, dynamic> json = {};
      field.toJsonValue(json);
      expect(json["salary"], isNull);
      expect(json["salary__value"], isEmpty);
    });

    test("load json data", () {
      var salary = Decimal.parse("100.00");
      field.loadJsonValue({"salary": salary.toStringAsFixed(2)});
      expect(field.value, salary);
    });

    test("init from json definition", () {
      var field = DecimalField.fromJson(
          {"id": "1", "name": "salary", "required": true});
      expect(field.name, "salary");
      expect(field.required, isTrue);
    });
  });

  group("validation", () {
    test("required", () {
      field = DecimalField("id", "date");
      expect(field.validate(), isTrue);
      field = DecimalField("id", "date", required: true);
      expect(field.validate(), isFalse);
      var salary = Decimal.parse("100.00");
      field.value = salary;
      expect(field.validate(), isTrue);
    });
  });
}
