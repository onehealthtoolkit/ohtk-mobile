import 'package:podd_app/form/form_data/form_values/base_form_value.dart';
import 'package:podd_app/form/form_data/form_values/condition.dart';
import 'package:podd_app/form/form_data/form_values/location_form_value.dart';
import 'package:uuid/uuid.dart';

import 'definitions/form_data_definition.dart';
import 'definitions/form_data_validation.dart';
import 'form_values/array_form_value.dart';
import 'form_values/boolean_form_value.dart';
import 'form_values/date_form_value.dart';
import 'form_values/decimal_form_value.dart';
import 'form_values/images_form_value.dart';
import 'form_values/integer_form_value.dart';
import 'form_values/multiple_choices_form_value.dart';
import 'form_values/single_choices_form_value.dart';
import 'form_values/string_form_value.dart';

var uuid = const Uuid();

class FormData extends FormValue with IFormData {
  Map<String, FormValue> values = {};
  late String id;
  String? name;
  FormDataDefinition? definition;

  FormData({this.name, this.definition}) : super(emptyValidations) {
    id = uuid.v4();
    definition?.properties.forEach((key, value) {
      EnableConditionState? cs;
      if (value is StringDataDefinition) {
        cs = addStringValue(key, value.validations);
      } else if (value is IntegerDataDefinition) {
        cs = addIntegerValue(key, value.validations);
      } else if (value is BooleanDataDefinition) {
        cs = addBooleanValue(key, value.validations);
      } else if (value is DateDataDefinition) {
        cs = addDateFormValue(key, value.validations);
      } else if (value is DecimalDataDefinition) {
        cs = addDecimalValue(key, value.validations);
      } else if (value is FormDataDefinition) {
        cs = addFormDataValue(key, FormData(name: key, definition: value));
      } else if (value is ArrayDataDefinition) {
        cs = addArrayDataValue(key, value.cols);
      } else if (value is ImagesDataDefinition) {
        cs = addImagesDataValue(key, value.validations);
      } else if (value is SingleChoiceDataDefinition) {
        cs = addSingleChoiceDataValue(value);
      } else if (value is MultipleChoiceDataDefinition) {
        cs = addMultipleChoicesDataValue(value);
      } else if (value is LocationDataDefinition) {
        cs = addLocationDataValue(key, value.validations);
      }
      if (cs != null) {
        cs.setConditionEvaluateFn(createCondition(value.enableCondition));
        cs.dependOn = value.enableCondition?.name;
      }
    });
  }

  FormValue getFormValue(String name) {
    return values[name]!;
  }

  addStringValue(String name, List<ValidationDataDefinition> validations) {
    values[name] = StringFormValue(validations);
    return values[name];
  }

  addIntegerValue(String name, List<ValidationDataDefinition> validations) {
    values[name] = IntegerFormValue(validations);
    return values[name];
  }

  addBooleanValue(String name, List<ValidationDataDefinition> validations) {
    values[name] = BooleanFormValue(validations);
    return values[name];
  }

  addDateFormValue(String name, List<ValidationDataDefinition> validations) {
    values[name] = DateFormValue(validations);
    return values[name];
  }

  addDecimalValue(String name, List<ValidationDataDefinition> validations) {
    values[name] = DecimalFormValue(validations);
    return values[name];
  }

  addFormDataValue(String name, FormData value) {
    values[name] = value;
    return values[name];
  }

  addArrayDataValue(String name, FormDataDefinition cols) {
    values[name] = ArrayFormValue(cols);
    return values[name];
  }

  addImagesDataValue(String name, List<ValidationDataDefinition> validations) {
    values[name] = ImagesFormValue(validations);
    return values[name];
  }

  addSingleChoiceDataValue(SingleChoiceDataDefinition definition) {
    values[definition.name] = SingleChoicesFormValue(definition);
  }

  addMultipleChoicesDataValue(MultipleChoiceDataDefinition definition) {
    values[definition.name] = MultipleChoicesFormValue(definition);
  }

  addLocationDataValue(
      String name, List<ValidationDataDefinition> validations) {
    values[name] = LocationFormValue(validations);
    return values[name];
  }

  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    definition?.properties.forEach((key, value) {
      var formValue = getFormValue(key);
      json[key] = formValue.toJson();

      if (value is SingleChoiceDataDefinition) {
        var singleChoicesValue = getFormValue(key) as SingleChoicesFormValue;
        if (value.hasInput) {
          json["${key}_text"] = singleChoicesValue.text;
        }
      } else if (value is MultipleChoiceDataDefinition) {
        var multipleChoicesValue =
            (getFormValue(key) as MultipleChoicesFormValue);
        json["${key}_values"] = multipleChoicesValue.toString();
      }
    });
    return json;
  }

  @override
  bool validate(IFormData root) {
    var valid = true;
    values.forEach((key, value) {
      valid = valid && value.validate(root);
    });
    return valid;
  }

  @override
  String? get invalidMessage => null;

  @override
  bool get isValid {
    var valid = true;
    values.forEach((key, value) {
      valid = valid && value.isValid;
    });
    return valid;
  }

  @override
  void initValidation(ValidationDataDefinition validationDefinition) {}

  @override
  bool isEqual(String value) {
    throw UnimplementedError();
  }
}
