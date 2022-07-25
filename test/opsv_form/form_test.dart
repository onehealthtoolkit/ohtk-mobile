import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';

Map<String, dynamic> jsonTemplate(Map<String, dynamic> field) {
  return {
    "id": "form1",
    "sections": [
      {
        "label": "section1",
        "questions": [
          {
            "label": "q1",
            "fields": [field]
          }
        ]
      }
    ]
  };
}

void main() {
  late Form simpleForm;
  late Form nestedForm;

  group("parse from json", () {
    test("text field", () {
      var jsonField = {
        "type": "text",
        "id": "id1",
        "name": "firstName",
        "required": true,
        "requiredMessage": "First Name is required",
        "suffixLabel": "Mr",
        "minLength": 3,
        "maxLength": 10,
        "minLengthMessage": "First Name must has more that 3 letters",
        "maxLengthMessage": "First Name must not more than 10 letters",
      };
      var form = Form.fromJson(jsonTemplate(jsonField));
      var field = form.getField("firstName") as TextField;
      expect(field, isNotNull);
      expect(field.id, jsonField["id"]);
      expect(field.name, jsonField["name"]);
      expect(field.required, jsonField["required"]);
      expect(field.requiredMessage, jsonField["requiredMessage"]);
      expect(field.suffixLabel, jsonField["suffixLabel"]);
      expect(field.minLength, jsonField["minLength"]);
      expect(field.maxLength, jsonField["maxLength"]);
      expect(field.minLengthMessage, jsonField["minLengthMessage"]);
      expect(field.maxLengthMessage, jsonField["maxLengthMessage"]);
    });
  });

  group("condition", () {
    setUp(() {
      simpleForm = Form.withSection(
        "form1",
        [
          Section.withQuestions(
            "section1",
            [
              Question.withFields(
                "question 1",
                [
                  TextField(
                    "id1",
                    "name",
                    label: "First Name",
                    required: true,
                    condition: SimpleCondition(
                      "surname",
                      ConditionOperator.equal,
                      "test",
                    ),
                  ),
                  TextField(
                    "id2",
                    "surname",
                    label: "Last Name",
                    required: true,
                  ),
                ],
              ),
              Question.withFields(
                "question 2",
                [
                  IntegerField("age", "age", label: "Age", required: true),
                ],
                condition: SimpleCondition(
                  "surname",
                  ConditionOperator.equal,
                  "test",
                ),
              ),
            ],
          )
        ],
      );
    });
    test("all conditions", () {
      var conditions = simpleForm.allConditions();
      expect(conditions.length(), 2);
      conditions.filter((a) => a.name == 'surname').forEach((a) {
        expect((a as SimpleCondition).value, "test");
      });
    });

    test("evaluate condition", () {
      var conditions = simpleForm.allConditions();
      expect(conditions.length(), 2);
      var result = conditions.toList()[0].evaluate(simpleForm.values);
      expect(result, isFalse);

      TextField surNameField =
          simpleForm.values.getDelegate("surname")!.getField() as TextField;
      surNameField.value = "test";
      result = conditions.toList()[0].evaluate(simpleForm.values);
      expect(result, isTrue);
    });

    test("monitor condition", () {
      TextField nameField =
          simpleForm.values.getDelegate("name")!.getField() as TextField;
      TextField surNameField =
          simpleForm.values.getDelegate("surname")!.getField() as TextField;
      expect(nameField.display, isFalse);
      surNameField.value = "test";
      expect(nameField.display, isTrue);
    });
  });

  group("form with simple fields", () {
    setUp(() {
      simpleForm = Form.withSection(
        "form1",
        [
          Section.withQuestions(
            "section1",
            [
              Question.withFields(
                "question 1",
                [
                  TextField("id1", "name", label: "First Name", required: true),
                  TextField("id2", "surname",
                      label: "Last Name", required: true),
                ],
              ),
              Question.withFields(
                "question 2",
                [
                  IntegerField("age", "age", label: "Age", required: true),
                ],
              ),
            ],
          )
        ],
      );
    });

    test('basic count', () {
      expect(simpleForm.numberOfSections, 1);
      expect(simpleForm.sections[0].numberOfQuestions, 2);
      expect(simpleForm.sections[0].questions[0].numberOfFields, 2);
    });

    test('value delegate register propagation', () {
      var values = simpleForm.values;
      expect(values.keys.length, 3);
      var nameValue = values.getDelegate("name");
      expect(nameValue, isNotNull);

      var surnameValue = values.getDelegate("surname");
      expect(surnameValue, isNotNull);

      var ageValue = values.getDelegate("age");
      expect(ageValue, isNotNull);
    });

    test('empty form should validate to false', () {
      expect(simpleForm.sections[0].validate(), isFalse);
    });

    test('load json', () {
      var sourceJson = {"name": "polawat", "surname": "phetra", "age": 20};
      simpleForm.loadJsonValue(sourceJson);
      var isValid = simpleForm.sections[0].validate();
      expect(isValid, isTrue);

      var nameField =
          simpleForm.values.getDelegate("name")!.getField() as TextField;
      expect(nameField.value, "polawat");

      var surnameField =
          simpleForm.values.getDelegate("surname")!.getField() as TextField;
      expect(surnameField.value, "phetra");

      var ageField =
          simpleForm.values.getDelegate("age")!.getField() as IntegerField;
      expect(ageField.value, 20);
    });

    test("dump to json", () {
      var sourceJson = {"name": "polawat", "surname": "phetra", "age": 20};
      simpleForm.loadJsonValue(sourceJson);
      var dumpJson = simpleForm.toJsonValue();
      expect(dumpJson["name"], sourceJson["name"]);
      expect(dumpJson["surname"], sourceJson["surname"]);
      expect(dumpJson["age"], sourceJson["age"]);
    });
  });

  group("nested form with simple fields", () {
    setUp(() {
      nestedForm = Form.withSection(
        "form1",
        [
          Section.withQuestions(
            "section1",
            [
              Question.withFields(
                "question 1",
                [
                  TextField("id1", "name", label: "First Name", required: true),
                  TextField("id2", "surname",
                      label: "Last Name", required: true),
                ],
                name: 'info',
              ),
              Question.withFields(
                "question 2",
                [
                  IntegerField("age", "age", label: "Age", required: true),
                ],
              ),
            ],
          )
        ],
      );
    });

    test('value delegate register propagation', () {
      var values = nestedForm.values;
      expect(values.keys.length, 2);
      var nameValue = values.getDelegate("info.name");
      expect(nameValue, isNotNull);

      var surnameValue = values.getDelegate("info.surname");
      expect(surnameValue, isNotNull);

      var ageValue = values.getDelegate("age");
      expect(ageValue, isNotNull);
    });

    test('load json and dump to json', () {
      var values = nestedForm.values;
      var sourceJson = {
        "info": {
          "name": "polawat",
          "surname": "phetra",
        },
        "age": 20
      };
      nestedForm.loadJsonValue(sourceJson);
      var isValid = simpleForm.sections[0].validate();
      expect(isValid, isTrue);

      var nameField = values.getDelegate("info.name")!.getField() as TextField;
      expect(nameField.value, "polawat");

      var surnameField =
          values.getDelegate("info.surname")!.getField() as TextField;
      expect(surnameField.value, "phetra");

      var ageField = values.getDelegate("age")!.getField() as IntegerField;
      expect(ageField.value, 20);
    });

    test("dump to json", () {
      Map<String, dynamic> sourceJson = {
        "info": {
          "name": "polawat",
          "surname": "phetra",
        },
        "age": 20
      };
      nestedForm.loadJsonValue(sourceJson);
      var dumpJson = nestedForm.toJsonValue();
      expect(dumpJson["info"]["name"], sourceJson["info"]["name"]);
      expect(dumpJson["info"]["surname"], sourceJson["info"]["surname"]);
      expect(dumpJson["age"], sourceJson["age"]);
    });
  });

  group("form navigation", () {
    setUp(() {
      simpleForm = Form.withSection(
        "form1",
        [
          Section.withQuestions(
            "section1",
            [
              Question.withFields(
                "question 1",
                [
                  TextField(
                    "id1",
                    "name",
                    label: "First Name",
                    required: true,
                  ),
                  TextField(
                    "id2",
                    "surname",
                    label: "Last Name",
                    required: true,
                  ),
                ],
              ),
            ],
          ),
          Section.withQuestions("section2", [
            Question.withFields(
              "question 2",
              [
                IntegerField("age", "age", label: "Age", required: true),
              ],
            ),
          ])
        ],
      );
    });

    test("Should not goto next if current section is not validate", () {
      expect(simpleForm.currentSectionIdx, 0);
      expect(simpleForm.couldGoToNextSection, isTrue);
      expect(simpleForm.couldGoToPreviousSection, isFalse);
      simpleForm.next();
      expect(simpleForm.currentSectionIdx, 0);

      simpleForm.loadJsonValue({"name": "John", "surname": "Doe"});
      simpleForm.next();
      expect(simpleForm.currentSectionIdx, 1);
      expect(simpleForm.couldGoToPreviousSection, isTrue);
      expect(simpleForm.couldGoToNextSection, isFalse);
    });
  });
}
