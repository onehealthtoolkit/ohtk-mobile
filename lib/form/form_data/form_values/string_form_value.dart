import 'package:podd_app/form/form_data/definitions/form_data_validation.dart';

import 'base_form_value.dart';

class StringFormValue extends BaseFormValue<String?> {
  StringFormValue(validationDefinitions) : super(validationDefinitions);

  @override
  initialValidation(ValidationDataDefinition validationDefinition) {
    super.initialValidation(validationDefinition);
    if (validationDefinition is MinMaxLengthValidationDefinition) {
      validationFunctions.add((IFormData root) {
        if (validationDefinition.minLength != null) {
          if (value == null ||
              value!.length < validationDefinition.minLength!) {
            markError(
                "This field must be at least ${validationDefinition.minLength} characters");
            return false;
          }
        }
        if (validationDefinition.maxLength != null) {
          if (value == null ||
              value!.length > validationDefinition.maxLength!) {
            markError(
                "This field must not be more than ${validationDefinition.maxLength} characters");
            return false;
          }
        }
        return true;
      });
    }
  }
}
