import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  late LocationField field;

  setUpAll(() {
    locator.registerSingletonAsync<AppLocalizations>(() async {
      return AppLocalizations.delegate.load(const Locale('en'));
    });
  });

  group("json value", () {
    setUp(() {
      field = LocationField("id", "location");
    });

    test("to json with value", () {
      var location = "100.343,13.233";
      field.value = location;
      Map<String, dynamic> json = {};
      field.toJsonValue(json);
      expect(json["location"], location);
      expect(json["location__value"], "$location (Lng,Lat)");
    });

    test("to json without value", () {
      Map<String, dynamic> json = {};
      field.toJsonValue(json);
      expect(json["location"], isNull);
      expect(json["location__value"], isEmpty);
    });

    test("load json data", () {
      var location = "100.343,13.233";
      field.loadJsonValue({"location": location});
      expect(field.value, location);
    });

    test("init from json definition", () {
      var field = LocationField.fromJson(
          {"id": "1", "name": "location", "required": true});
      expect(field.name, "location");
      expect(field.required, isTrue);
    });
  });

  group("validation", () {
    test("required", () {
      field = LocationField("id", "date");
      expect(field.validate(), isTrue);
      field = LocationField("id", "date", required: true);
      expect(field.validate(), isFalse);
      var location = "100.343,13.233";
      field.value = location;
      expect(field.validate(), isTrue);
    });
  });
}
