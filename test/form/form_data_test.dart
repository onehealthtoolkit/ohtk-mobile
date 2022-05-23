import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/form/form_data/definitions/form_data_definition.dart';
import 'package:podd_app/form/form_data/definitions/form_data_validation.dart';
import 'package:podd_app/form/form_data/form_values/array_form_value.dart';
import 'package:podd_app/form/form_data/form_values/integer_form_value.dart';
import 'package:podd_app/form/form_data/form_values/string_form_value.dart';

void main() {
  group("String Form Value", () {
    test('StringFormValue initialize with null value', () {
      StringFormValue sv =
          StringFormValue(List<ValidationDataDefinition>.empty());
      expect(sv.value, null);
    });

    test('StringFormValue initialize with null and then assign some value', () {
      StringFormValue sv =
          StringFormValue(List<ValidationDataDefinition>.empty());
      sv.value = "hello";
      expect(sv.value, "hello");
    });
  });

  group("Integer form value", () {
    test("IntegerFormValue init with null", () {
      var iv = IntegerFormValue(List<ValidationDataDefinition>.empty());
      expect(iv.value, null);
    });

    test("IntegerFormValue init with null and then assign some value", () {
      var iv = IntegerFormValue(List<ValidationDataDefinition>.empty());
      iv.value = 230;
      expect(iv.value, 230);
    });
  });

  group("Array of FormData", () {
    test("When initialize should contain empty array", () {
      var ary = ArrayFormValue(FormDataDefinition("cols", {}));
      expect(ary.length, 0);
    });

    test("create new row", () {
      var ary = ArrayFormValue(FormDataDefinition("cols", {}));

      ary.createNewRow();

      expect(ary.length, 1);
    });

    test("create and delete row", () {
      var ary = ArrayFormValue(FormDataDefinition("cols", {}));

      ary.createNewRow();
      ary.createNewRow();

      expect(ary.length, 2);

      ary.deleteRowAt(0);
      expect(ary.length, 1);
    });
  });
}
