import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/form/form_data/definitions/form_data_definition.dart';
import 'package:podd_app/form/form_data/definitions/form_data_validation.dart';
import 'package:podd_app/form/form_data/form_data.dart';
import 'package:podd_app/form/form_data/form_values/array_form_value.dart';
import 'package:podd_app/form/form_data/form_values/boolean_form_value.dart';
import 'package:podd_app/form/form_data/form_values/date_form_value.dart';
import 'package:podd_app/form/form_data/form_values/decimal_form_value.dart';
import 'package:podd_app/form/form_data/form_values/images_form_value.dart';
import 'package:podd_app/form/form_data/form_values/integer_form_value.dart';
import 'package:podd_app/form/form_data/form_values/location_form_value.dart';
import 'package:podd_app/form/form_data/form_values/multiple_choices_form_value.dart';
import 'package:podd_app/form/form_data/form_values/single_choices_form_value.dart';
import 'package:podd_app/form/form_data/form_values/string_form_value.dart';
import 'package:podd_app/form/ui_definition/fields/option_field_ui_definition.dart';

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

  group("Serialize to json", () {
    test("String value", () {
      var formData = FormData(
        name: "root",
        definition: FormDataDefinition(
          "root",
          {
            "name": StringDataDefinition(
              "name",
              List<ValidationDataDefinition>.empty(),
            ),
          },
        ),
      );
      var json = formData.toJson();
      expect(json["name"], isNull);
      var formValue = formData.getFormValue("name") as StringFormValue;
      formValue.value = "John";
      json = formData.toJson();
      expect(json["name"], "John");
    });

    test("Integer value", () {
      var formData = FormData(
        name: "root",
        definition: FormDataDefinition(
          "root",
          {
            "age": IntegerDataDefinition(
              "age",
              List<ValidationDataDefinition>.empty(),
            ),
          },
        ),
      );
      var formValue = formData.getFormValue("age") as IntegerFormValue;
      formValue.value = 34;
      var json = formData.toJson();
      expect(json["age"], 34);
    });

    test("Date value", () {
      var formData = FormData(
        name: "root",
        definition: FormDataDefinition(
          "root",
          {
            "date": DateDataDefinition(
              "date",
              List<ValidationDataDefinition>.empty(),
            ),
          },
        ),
      );
      var currentDate = DateTime(2022, 1, 1, 10, 0);
      var formValue = formData.getFormValue("date") as DateFormValue;
      formValue.value = currentDate;
      var json = formData.toJson();
      expect(json["date"], currentDate.toIso8601String());
    });

    test("Boolean value", () {
      var formData = FormData(
        name: "root",
        definition: FormDataDefinition(
          "root",
          {
            "active": BooleanDataDefinition(
              "active",
              List<ValidationDataDefinition>.empty(),
            ),
          },
        ),
      );
      var formValue = formData.getFormValue("active") as BooleanFormValue;
      formValue.value = true;
      var json = formData.toJson();
      expect(json["active"], true);
    });

    test("Decimal value", () {
      var formData = FormData(
        name: "root",
        definition: FormDataDefinition(
          "root",
          {
            "salary": DecimalDataDefinition(
              "salary",
              List<ValidationDataDefinition>.empty(),
            ),
          },
        ),
      );
      var formValue = formData.getFormValue("salary") as DecimalFormValue;
      formValue.value = Decimal.ten;
      var json = formData.toJson();
      expect(json["salary"], Decimal.ten.toJson());
    });

    test("Location value", () {
      const NAME = "location";
      const VALUE = "13.012,100,0930";
      var formData = FormData(
        name: "root",
        definition: FormDataDefinition(
          "root",
          {
            NAME: LocationDataDefinition(
              NAME,
              List<ValidationDataDefinition>.empty(),
            ),
          },
        ),
      );

      var formValue = formData.getFormValue(NAME) as LocationFormValue;
      formValue.value = VALUE;
      var json = formData.toJson();
      expect(json[NAME], VALUE);
    });

    test("Location value", () {
      const NAME = "location";
      const VALUE = "13.012,100,0930";
      var formData = FormData(
        name: "root",
        definition: FormDataDefinition(
          "root",
          {
            NAME: LocationDataDefinition(
              NAME,
              List<ValidationDataDefinition>.empty(),
            ),
          },
        ),
      );

      var formValue = formData.getFormValue(NAME) as LocationFormValue;
      formValue.value = VALUE;
      var json = formData.toJson();
      expect(json[NAME], VALUE);
    });

    test("single choice value", () {
      const NAME = "disease";
      const VALUE = "sars";
      var formData = FormData(
        name: "root",
        definition: FormDataDefinition(
          "root",
          {
            NAME: SingleChoiceDataDefinition(
              NAME,
              List<Option>.of([
                Option(label: "mers", value: "mers"),
                Option(label: "sars", value: "sars"),
                Option(label: "flu", value: "flu"),
              ]),
              List<ValidationDataDefinition>.empty(),
            ),
          },
        ),
      );

      var formValue = formData.getFormValue(NAME) as SingleChoicesFormValue;
      formValue.value = VALUE;
      var json = formData.toJson();
      expect(json[NAME], VALUE);
    });

    test("single choice value with free text", () {
      const NAME = "disease";
      const VALUE = "other";
      var formData = FormData(
        name: "root",
        definition: FormDataDefinition(
          "root",
          {
            NAME: SingleChoiceDataDefinition(
              NAME,
              List<Option>.of([
                Option(label: "mers", value: "mers"),
                Option(label: "sars", value: "sars"),
                Option(label: "flu", value: "flu"),
                Option(label: "other", value: "other", textInput: true),
              ]),
              List<ValidationDataDefinition>.empty(),
            ),
          },
        ),
      );

      var formValue = formData.getFormValue(NAME) as SingleChoicesFormValue;
      formValue.value = VALUE;
      formValue.text = "dengue";
      var json = formData.toJson();
      expect(json[NAME], VALUE);
      expect(json["${NAME}_text"], "dengue");
    });

    test("multiple choices value", () {
      const NAME = "symptom";
      const VALUE = "sore throat";
      var formData = FormData(
        name: "root",
        definition: FormDataDefinition(
          "root",
          {
            NAME: MultipleChoiceDataDefinition(
              NAME,
              List<Option>.of([
                Option(label: "sore throat", value: "sore throat"),
                Option(label: "cough", value: "cough"),
                Option(label: "headache", value: "headache"),
              ]),
              List<ValidationDataDefinition>.empty(),
            ),
          },
        ),
      );

      var formValue = formData.getFormValue(NAME) as MultipleChoicesFormValue;
      formValue.setSelectedFor("cough", true);
      formValue.setSelectedFor("headache", true);
      var json = formData.toJson();

      expect(json[NAME], isNotNull);
      expect(json[NAME], "cough,headache");
      var subName = "${NAME}_values";
      expect(json[subName], isNotNull);
      expect(json[subName]["sore throat"], false);
      expect(json[subName]["cough"], true);
      expect(json[subName]["headache"], true);
    });

    test("images value", () {
      const NAME = "images";
      var formData = FormData(
        name: "root",
        definition: FormDataDefinition(
          "root",
          {
            NAME: ImagesDataDefinition(
              NAME,
              List<ValidationDataDefinition>.empty(),
            ),
          },
        ),
      );

      var formValue = formData.getFormValue(NAME) as ImagesFormValue;
      formValue.add("image1");
      formValue.add("image2");
      var json = formData.toJson();
      expect(json[NAME], isNotNull);
      expect(json[NAME], "image1,image2");
    });
  });
}
