import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';

void main() {
  late Form form;

  var jsonField1 = {
    "type": "subform",
    "id": "friends",
    "name": "friends",
    "label": "friends",
    "formRef": "subform1",
    "titleTemplate": "",
    "descriptionTemplate": "",
  };
  var jsonField2 = {
    "type": "text",
    "id": "firstName",
    "name": "firstName",
    "label": "firstName",
  };

  Map<String, dynamic> jsonTemplate(
      Map<String, dynamic> subformField, Map<String, dynamic> anyField) {
    return {
      "id": "form1",
      "sections": [
        {
          "label": "party",
          "questions": [
            {
              "label": "friends",
              "fields": [subformField]
            },
            {
              "label": "owner",
              "fields": [anyField]
            }
          ]
        },
      ],
      "subforms": [
        {
          "subform1": {
            "sections": [
              {
                "label": "info",
                "questions": [
                  {
                    "label": "person",
                    "fields": [anyField]
                  }
                ]
              },
            ]
          }
        }
      ]
    };
  }

  group("parse from json", () {
    setUp(() {
      form = Form.fromJson(jsonTemplate(jsonField1, jsonField2));
    });

    test("get subform and its field", () {
      expect(form.subforms.length, 1);

      var subform = form.subforms['subform1'];
      expect(subform, isNotNull);

      var textField = subform!.getField("firstName") as TextField;
      expect(textField, isNotNull);
      expect(textField.id, jsonField2["id"]);
      expect(textField.name, jsonField2["name"]);
    });

    test("get subform field and its form reference", () {
      var subformField = form.getField("friends") as SubformField;

      expect(subformField, isNotNull);
      expect(subformField.id, jsonField1["id"]);
      expect(subformField.name, jsonField1["name"]);
      expect(subformField.formReference, isNotNull);

      var subform = form.subforms['subform1'];
      expect(subform, isNotNull);
      expect(subform!.id, subformField.formReference!.id);
      expect(subform.numberOfSections, 1);
    });
  });

  Map<String, dynamic> sourceJson = {
    "friends": {
      "friend_1": {"firstName": "Mary"},
      "friend_2": {"firstName": "Michael"}
    }
  };

  group("json value", () {
    setUp(() {
      form = Form.fromJson(jsonTemplate(jsonField1, jsonField2));
      form.loadJsonValue(sourceJson);
    });

    test("load value", () {
      var subformField = form.getField("friends") as SubformField;
      var subform0 = subformField.getSubformByName("friend_x");
      expect(subform0, isNull);

      var subform1 = subformField.getSubformByName("friend_1");
      expect(subform1, isNotNull);
      expect(subform1!.ref.getField('firstName')!.value,
          sourceJson['friends']['friend_1']['firstName']);

      var subform2 = subformField.getSubformByName("friend_2");
      expect(subform2, isNotNull);
      expect(subform2!.ref.getField('firstName')!.value,
          sourceJson['friends']['friend_2']['firstName']);
    });

    test('to json value', () {
      var subformField = form.getField("friends") as SubformField;
      var subform1 = subformField.getSubformByName("friend_1");
      expect(subform1!.ref.toJsonValue()['firstName'],
          sourceJson['friends']['friend_1']['firstName']);

      var subform2 = subformField.getSubformByName("friend_2");
      expect(subform2!.ref.toJsonValue()['firstName'],
          sourceJson['friends']['friend_2']['firstName']);

      var friend1Name = 'April';
      var friend2Name = 'Amy';

      var subform1TextField = subform1.ref.getField('firstName') as TextField;
      subform1TextField.value = friend1Name;

      var subform2TextField = subform2.ref.getField('firstName') as TextField;
      subform2TextField.value = friend2Name;

      var jsonValue = form.toJsonValue();
      expect(jsonValue['friends']['friend_1']['firstName'], friend1Name);
      expect(jsonValue['friends']['friend_2']['firstName'], friend2Name);

      expect(jsonValue['friends']['value'],
          (sourceJson['friends'] as Map<String, dynamic>).keys.join(', '));
    });
  });
}
