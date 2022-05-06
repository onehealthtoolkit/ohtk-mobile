import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/form/form_data/form_data.dart';
import 'package:podd_app/form/form_data/form_data_definition.dart';

void main() {
  group("String Form Value", () {
    test('StringFormValue initialize with null value', () {
      StringFormValue sv = StringFormValue();
      expect(sv.value, null);
    });

    test('StringFormValue initialize with null and then assign some value', () {
      StringFormValue sv = StringFormValue();
      sv.value = "hello";
      expect(sv.value, "hello");
    });
  });

  group("Integer form value", () {
    test("IntegerFormValue init with null", () {
      var iv = IntegerFormValue();
      expect(iv.value, null);
    });

    test("IntegerFormValue init with null and then assign some value", () {
      var iv = IntegerFormValue();
      iv.value = 230;
      expect(iv.value, 230);
    });
  });

  group("Array of FormData", () {
    test("When initialize should contain empty array", () {
      var ary = ArrayFormValue(FormDataDefinition("cols", {}));
      expect(ary.value, []);
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
