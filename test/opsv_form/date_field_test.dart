import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';

void main() {
  late DateField field;
  group("json value", () {
    setUp(() {
      field = DateField("id", "date");
    });

    test("to json with value", () {
      var now = DateTime.now();
      field.value = now;
      Map<String, dynamic> json = {};
      field.toJsonValue(json);
      expect(json["date"],
          DateTime(now.year, now.month, now.day).toIso8601String());
      expect(
        json["date__value"],
        DateFormat("yyyy-MM-dd").format(DateTime(now.year, now.month, now.day)),
      );
    });

    test("to json without value", () {
      Map<String, dynamic> json = {};
      field.value = null;
      field.toJsonValue(json);
      expect(json["date"], isNull);
      expect(json["date__value"], isEmpty);
    });

    test("load json data", () {
      var now = DateTime.now();
      field.loadJsonValue({"date": now.toIso8601String()});
      expect(field.value, DateTime(now.year, now.month, now.day));
    });

    test("init from json definition", () {
      var field =
          DateField.fromJson({"id": "1", "name": "dob", "required": true});
      expect(field.name, "dob");
      expect(field.required, isTrue);
    });
  });

  group("validation", () {
    test("required", () {
      field = DateField("id", "date");
      expect(field.validate(), isTrue);
      field = DateField("id", "date", required: true);
      field.value = null;
      expect(field.validate(), isFalse);
      field.value = DateTime.now();
      expect(field.validate(), isTrue);
    });
  });
}
