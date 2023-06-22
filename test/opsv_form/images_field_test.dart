import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';

void main() {
  late ImagesField field;
  group("json value", () {
    setUp(() {
      field = ImagesField("id", "images");
    });

    test("to json with value", () {
      var ary = ["123.png", "222.png"];
      field.value = ary;
      Map<String, dynamic> json = {};
      field.toJsonValue(json);
      expect(json["images"], ary);
      expect(json["images__value"], ary.join(", "));
    });

    test("to json without value", () {
      Map<String, dynamic> json = {};
      field.toJsonValue(json);
      expect(json["images"], []);
      expect(json["images__value"], isEmpty);
    });

    test("load json data", () {
      var ary = ["123.png", "222.png"];
      field.loadJsonValue({"images": ary});
      expect(field.value, ary);
    });

    test("init from json definition", () {
      var field =
          ImagesField.fromJson({"id": "1", "name": "images", "required": true});
      expect(field.name, "images");
      expect(field.required, isTrue);
    });
  });

  group("validation", () {
    test("required", () {
      field = ImagesField("id", "images");
      expect(field.validate(), isTrue);
      field = ImagesField("id", "images", required: true);
      expect(field.validate(), isFalse);
      field.value = ["tt.png"];
      expect(field.validate(), isTrue);
    });

    test("min value", () {
      field =
          ImagesField("id", "images", min: 2, minMessage: "test_min_message");
      expect(field.validate(), isFalse);
      expect(field.invalidMessage, "test_min_message");
      field.value = ["tt.png"];
      expect(field.validate(), isFalse);
      field.add("me.png");
      expect(field.validate(), isTrue);
    });

    test("max value", () {
      field =
          ImagesField("id", "images", max: 2, maxMessage: "test_max_message");
      expect(field.validate(), isTrue);
      field.value = ["tt.png"];
      expect(field.validate(), isTrue);
      field.add("me.png");
      expect(field.validate(), isTrue);
      field.add("test1.png");
      expect(field.validate(), isFalse);
      expect(field.invalidMessage, "test_max_message");
    });

    test("min, max value", () {
      field = ImagesField("id", "images",
          min: 1,
          minMessage: "test_min_message",
          max: 2,
          maxMessage: "test_max_message");
      expect(field.validate(), isFalse);
      expect(field.invalidMessage, "test_min_message");
      field.value = ["tt.png"];
      expect(field.validate(), isTrue);
      expect(field.invalidMessage, isNull);
      field.add("me.png");
      expect(field.validate(), isTrue);
      expect(field.invalidMessage, isNull);
      field.add("test1.png");
      expect(field.validate(), isFalse);
      expect(field.invalidMessage, "test_max_message");
    });
  });
}
