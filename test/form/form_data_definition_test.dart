import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/form/form_data/definitions/form_data_definition.dart';
import 'package:podd_app/form/form_data/definitions/form_data_validation.dart';
import 'package:podd_app/form/ui_definition/fields/option_field_ui_definition.dart';
import 'package:podd_app/form/ui_definition/form_ui_definition.dart';

var emptyValidations = List<ValidationDataDefinition>.empty();
void main() {
  group(
    "Form Data Definition",
    () {
      test(
        "Initialize.",
        () {
          var formData = FormDataDefinition('root', {
            "firstName": StringDataDefinition("firstName", emptyValidations),
            "age": IntegerDataDefinition("age", emptyValidations),
            "dob": DateDataDefinition("dob", emptyValidations),
            "salary": DecimalDataDefinition("salary", emptyValidations)
          });

          expect(4, formData.properties.length);
        },
      );
    },
  );

  group(
    "ArrayDataDefinition",
    () {
      test(
        "initialize",
        () {
          var arrayData = ArrayDataDefinition(
            "educations",
            FormDataDefinition(
              'education',
              {
                "year": IntegerDataDefinition("year", emptyValidations),
                "institute":
                    StringDataDefinition("institute", emptyValidations),
                "grade": DecimalDataDefinition("grade", emptyValidations)
              },
            ),
          );
          expect(3, arrayData.cols.properties.length);
        },
      );
    },
  );

  group('FormUIDefinition to FormDataDefinition', () {
    test('Mapping Textfield to StringDataDefinition', () {
      var ui = FormUIDefinition();
      var s1 = Section(label: "s1");
      var q1 = Question(label: "q1");
      ui.sections.add(s1);
      s1.addQuestion(q1);
      q1.addField(TextFieldUIDefinition(id: "id1", name: "firstName"));
      q1.addField(TextFieldUIDefinition(id: "id2", name: "lastName"));

      var dataDefinition = FormDataDefinition.fromUIDefinition(ui);
      expect(
          dataDefinition.properties["firstName"], isA<StringDataDefinition>());
      expect(
          dataDefinition.properties["lastName"], isA<StringDataDefinition>());
    });

    test('Support multiple sections', () {
      var ui = FormUIDefinition();
      var s1 = Section(label: "s1");
      var s2 = Section(label: "s2");
      var q1 = Question(label: "q1");
      var q2 = Question(label: "q2");
      ui.sections.add(s1);
      ui.sections.add(s2);
      s1.addQuestion(q1);
      s2.addQuestion(q2);
      q1.addField(TextFieldUIDefinition(id: "id1", name: "firstName"));
      q1.addField(TextFieldUIDefinition(id: "id2", name: "lastName"));
      q2.addField(TextFieldUIDefinition(id: "id3", name: "address"));

      var dataDefinition = FormDataDefinition.fromUIDefinition(ui);
      expect(
          dataDefinition.properties["firstName"], isA<StringDataDefinition>());
      expect(
          dataDefinition.properties["lastName"], isA<StringDataDefinition>());
      expect(dataDefinition.properties["address"], isA<StringDataDefinition>());
    });

    test('Map integerField to IntegerDataDefinition', () {
      var ui = FormUIDefinition();
      var s1 = Section(label: "s1");
      var q1 = Question(label: "q1");
      ui.sections.add(s1);
      s1.addQuestion(q1);
      q1.addField(IntegerFieldUIDefinition(id: "id1", name: "age"));

      var dataDefinition = FormDataDefinition.fromUIDefinition(ui);
      expect(dataDefinition.properties["age"], isA<IntegerDataDefinition>());
    });

    test('Map single choice to SingleChoiceDataDefinition', () {
      var ui = FormUIDefinition();
      var s1 = Section(label: "s1");
      var q1 = Question(label: "q1");
      ui.sections.add(s1);
      s1.addQuestion(q1);
      q1.addField(SingleChoicesFieldUIDefinition(
          id: "id1", name: "age", options: List<Option>.empty()));

      var dataDefinition = FormDataDefinition.fromUIDefinition(ui);
      expect(
          dataDefinition.properties["age"], isA<SingleChoiceDataDefinition>());
    });

    test('Map single choice to SingleChoiceDataDefinition with option text',
        () {
      var ui = FormUIDefinition();
      var s1 = Section(label: "s1");
      var q1 = Question(label: "q1");
      ui.sections.add(s1);
      s1.addQuestion(q1);

      List<Option> options = [
        Option(label: "5-10", value: "5-10"),
        Option(label: "11-18", value: "11-18"),
        Option(label: "19-50", value: "19-50", input: true)
      ];
      var f1 = SingleChoicesFieldUIDefinition(
          id: "id1", name: "age", options: options);
      q1.addField(f1);

      var dataDefinition = FormDataDefinition.fromUIDefinition(ui);
      expect(
          dataDefinition.properties["age"], isA<SingleChoiceDataDefinition>());
      expect(
          (dataDefinition.properties["age"] as SingleChoiceDataDefinition)
              .hasInput,
          true);
    });

    test(
        'Map multiple choices field to sub FormDataDefinition and each choice will map to BooleanDataDefinition',
        () {
      var ui = FormUIDefinition();
      var s1 = Section(label: "s1");
      var q1 = Question(label: "q1");
      ui.sections.add(s1);
      s1.addQuestion(q1);

      List<Option> options = [
        Option(label: "cough", value: "cough"),
        Option(label: "fever", value: "fever"),
        Option(label: "sore throat", value: "sore throat")
      ];

      var f1 = MultipleChoicesFieldUIDefinition(
          id: "id1", name: "symptom", options: options);

      q1.addField(f1);
      var dataDefinition = FormDataDefinition.fromUIDefinition(ui);
      expect(dataDefinition.properties['symptom'], isA<FormDataDefinition>());
      var subDataDefinition =
          dataDefinition.properties['symptom'] as FormDataDefinition;
      expect(
          subDataDefinition.properties['cough'], isA<BooleanDataDefinition>());
      expect(
          subDataDefinition.properties['fever'], isA<BooleanDataDefinition>());
      expect(subDataDefinition.properties['sore throat'],
          isA<BooleanDataDefinition>());
    });

    test('multiple choices should support free text input', () {
      var ui = FormUIDefinition();
      var s1 = Section(label: "s1");
      var q1 = Question(label: "q1");
      ui.sections.add(s1);
      s1.addQuestion(q1);
      List<Option> options = [
        Option(label: "cough", value: "primary", input: true),
        Option(label: "fever", value: "secondary", input: true)
      ];
      var f1 = MultipleChoicesFieldUIDefinition(
        id: "id1",
        name: "education",
        options: options,
      );

      q1.addField(f1);
      var dataDefinition = FormDataDefinition.fromUIDefinition(ui);
      expect(dataDefinition.properties['education'], isA<FormDataDefinition>());
      var subDataDefinition =
          dataDefinition.properties['education'] as FormDataDefinition;
      expect(subDataDefinition.properties['primary'],
          isA<BooleanDataDefinition>());
      expect(subDataDefinition.properties['secondary'],
          isA<BooleanDataDefinition>());

      expect(subDataDefinition.properties['primary_text'],
          isA<StringDataDefinition>());
      expect(subDataDefinition.properties['secondary_text'],
          isA<StringDataDefinition>());
    });

    test(
      'question that define isObject=True should have sub formdataDefinition',
      () {
        var ui = FormUIDefinition();
        var s1 = Section(label: "s1");
        var q1 = Question(label: "address", objectName: 'address');
        ui.sections.add(s1);
        s1.addQuestion(q1);
        q1.addField(TextFieldUIDefinition(id: "province", name: "province"));
        q1.addField(TextFieldUIDefinition(id: "zipCode", name: "zipCode"));

        var dataDefinition = FormDataDefinition.fromUIDefinition(ui);
        expect(dataDefinition.properties['address'], isA<FormDataDefinition>());

        var subDataDefinition =
            dataDefinition.properties['address'] as FormDataDefinition;
        expect(subDataDefinition.properties['province'],
            isA<StringDataDefinition>());
        expect(subDataDefinition.properties['zipCode'],
            isA<StringDataDefinition>());
      },
    );

    test(
      "map tableField to ArrayFormDataDefinition",
      () {
        var ui = FormUIDefinition();
        var s1 = Section(label: "s1");
        var q1 = Question(label: "educations");
        ui.sections.add(s1);
        s1.addQuestion(q1);
        var f1 = TableFieldUIDefinition(id: "1", name: "educations", cols: [
          TextFieldUIDefinition(id: "name", name: 'name'),
          IntegerFieldUIDefinition(id: "year", name: "year"),
        ]);
        q1.addField(f1);

        var dataDefinition = FormDataDefinition.fromUIDefinition(ui);
        expect(dataDefinition.properties['educations'],
            isA<ArrayDataDefinition>());
        var array =
            dataDefinition.properties['educations'] as ArrayDataDefinition;
        expect(array.cols.properties['name'], isA<StringDataDefinition>());
        expect(array.cols.properties['year'], isA<IntegerDataDefinition>());
      },
    );
  });
}
