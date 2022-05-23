import 'package:mobx/mobx.dart';
import 'package:podd_app/form/form_data/definitions/form_data_definition.dart';
import 'package:podd_app/form/form_data/definitions/form_data_validation.dart';

import 'base_form_value.dart';

class SingleChoicesFormValue extends BaseFormValue<String?> {
  SingleChoiceDataDefinition dataDefinition;

  final _text = Observable<String?>(null);

  set text(String? newValue) {
    Action(() {
      _text.value = newValue;
      clearError();
    })();
  }

  String? get text => _text.value;

  @override
  set value(String? newValue) {
    Action(() {
      super.value = newValue;
      _text.value = null;
    })();
  }

  SingleChoicesFormValue(this.dataDefinition)
      : super(dataDefinition.validations);

  @override
  initialValidation(ValidationDataDefinition validationDefinition) {
    if (validationDefinition is RequiredValidationDefinition) {
      validationFunctions.add((IFormData root) {
        if (value == null) {
          markError("This field is required");
          return false;
        } else {
          if (dataDefinition.hasInput) {
            var selectedOption = dataDefinition.options
                .firstWhere((option) => option.value == value);
            if (selectedOption.input) {
              if (text == null) {
                markError("This field is required");
                return false;
              }
            }
          }
        }

        clearError();
        return true;
      });
    }
  }
}
