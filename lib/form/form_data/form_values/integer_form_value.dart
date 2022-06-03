import 'package:podd_app/form/form_data/definitions/form_data_validation.dart';

import 'base_form_value.dart';

class IntegerFormValue extends BaseFormValue<int?> {
  IntegerFormValue(validationDefinitions) : super(validationDefinitions);

  @override
  initValidation(ValidationDataDefinition validationDefinition) {
    super.initValidation(validationDefinition);
    if (validationDefinition is MinMaxValidationDefinition) {
      validationFunctions.add((IFormData root) {
        if (validationDefinition.min != null) {
          if (value == null || value! < validationDefinition.min!) {
            markError(
                "This field value must be at least ${validationDefinition.min}");
            return false;
          }
        }
        if (validationDefinition.max != null) {
          if (value == null || value! > validationDefinition.max!) {
            markError(
                "This field value must not more than ${validationDefinition.max}");
            return false;
          }
        }
        return true;
      });
    }
  }
}
