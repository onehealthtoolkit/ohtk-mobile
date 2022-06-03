import 'package:podd_app/form/form_data/form_values/base_form_value.dart';
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

class FormData extends IValidatable with IFormData {
  Map<String, IValidatable> values = {};
  late String id;
  String? name;
  FormDataDefinition? definition;

  FormData({this.name, this.definition}) : super([]) {
    id = uuid.v4();
    definition?.properties.forEach((key, value) {
      if (value is StringDataDefinition) {
        addStringValue(key, value.validations);
      } else if (value is IntegerDataDefinition) {
        addIntegerValue(key, value.validations);
      } else if (value is BooleanDataDefinition) {
        addBooleanValue(key, value.validations);
      } else if (value is DateDataDefinition) {
        addDateFormValue(key, value.validations);
      } else if (value is DecimalDataDefinition) {
        addDecimalValue(key, value.validations);
      } else if (value is FormDataDefinition) {
        addFormDataValue(key, FormData(name: key, definition: value));
      } else if (value is ArrayDataDefinition) {
        addArrayDataValue(key, value.cols);
      } else if (value is ImagesDataDefinition) {
        addImagesDataValue(key, value.validations);
      } else if (value is SingleChoiceDataDefinition) {
        addSingleChoiceDataValue(value);
      } else if (value is MultipleChoiceDataDefinition) {
        addMultipleChoicesDataValue(value);
      } else if (value is LocationDataDefinition) {
        addLocationDataValue(key, value.validations);
      }
    });
  }

  getFormValue(String name) {
    return values[name];
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
    values[name] = DecimaFormlValue(validations);
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

  Map<String, dynamic> toJson() {
    final values = <String, dynamic>{};

    definition?.properties.forEach((key, value) {
      if (value is StringDataDefinition) {
        values[key] = (getFormValue(key) as StringFormValue).value;
      } else if (value is IntegerDataDefinition) {
        values[key] = (getFormValue(key) as IntegerFormValue).value;
      } else if (value is BooleanDataDefinition) {
        values[key] = (getFormValue(key) as BooleanFormValue).value;
      } else if (value is DateDataDefinition) {
        values[key] = (getFormValue(key) as DateFormValue).value;
      } else if (value is DecimalDataDefinition) {
        values[key] = (getFormValue(key) as DecimaFormlValue).value;
      } else if (value is FormDataDefinition) {
        values[key] = (getFormValue(key) as FormData).toJson();
      } else if (value is ArrayDataDefinition) {
        addArrayDataValue(key, value.cols);
        values[key] = (getFormValue(key) as ArrayFormValue).toJson();
      }
    });
    return values;
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
}
