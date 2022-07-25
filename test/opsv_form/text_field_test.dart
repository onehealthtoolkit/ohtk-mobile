import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';

void main() {
  group("json value", () {
    test("toJson with value", () {
      var textField = TextField("id1", "firstName");
      textField.value = "polawat";
      Map<String, dynamic> json = {};
      textField.toJsonValue(json);
      expect(json["firstName"], "polawat");
    });

    test("toJson without value", () {
      var textField = TextField("id1", "firstName");
      Map<String, dynamic> json = {};
      textField.toJsonValue(json);
      expect(json["firstName"], isNull);
    });

    test("load json data", () {
      var textField = TextField("id1", "firstName");
      textField.loadJsonValue({"firstName": "test"});
      expect(textField.value, "test");
    });
  });

  group("validation", () {
    test("text field with no required", () {
      var textField = TextField("id1", "firstName", required: false);
      var valid = textField.validate();
      expect(valid, isTrue);

      textField.value = "";
      valid = textField.validate();
      expect(valid, isTrue);
    });

    test("text field with required", () {
      var textField = TextField("id1", "firstName", required: true);
      var valid = textField.validate();
      expect(valid, isFalse);
      expect(textField.invalidMessage, "This field is required");

      textField.value = "";
      valid = textField.validate();
      expect(valid, isFalse);
      expect(textField.invalidMessage, "This field is required");
    });

    test("error must be clear after field is set with new value", () {
      var textField = TextField("id1", "firstName", required: true);
      var valid = textField.validate();
      expect(valid, isFalse);
      expect(textField.invalidMessage, isNotNull);
      textField.value = "new value";
      expect(textField.invalidMessage, isNull);
    });

    test("text field with custom required message", () {
      var customMsg = "First Name is required";
      var textField = TextField("id1", "firstName",
          required: true, requiredMessage: customMsg);
      var valid = textField.validate();
      expect(valid, isFalse);
      expect(textField.invalidMessage, customMsg);
    });

    test("text field with min and max validation", () {
      var customMinMsg = "First Name must has more that 3 letters";
      var customMaxMsg = "First Name must has not more that 10 letters";
      var textField = TextField(
        "id1",
        "firstName",
        required: true,
        minLength: 3,
        minLengthMessage: customMinMsg,
        maxLength: 10,
        maxLengthMessage: customMaxMsg,
      );
      textField.value = "x";
      var valid = textField.validate();
      expect(valid, isFalse);
      expect(textField.invalidMessage, customMinMsg);

      textField.value = "xxx";
      valid = textField.validate();
      expect(valid, isTrue);

      textField.value = "xxxxxxxxx";
      valid = textField.validate();
      expect(valid, isTrue);

      textField.value = "xxxxxxxxxx";
      valid = textField.validate();
      expect(valid, isTrue);
      expect(textField.invalidMessage, isNull);

      textField.value = "xxxxxxxxxxx";
      valid = textField.validate();
      expect(valid, isFalse);
      expect(textField.invalidMessage, customMaxMsg);
    });
  });
}
