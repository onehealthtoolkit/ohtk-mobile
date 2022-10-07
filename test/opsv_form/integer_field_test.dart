import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';

void main() {
  late IntegerField field;
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
