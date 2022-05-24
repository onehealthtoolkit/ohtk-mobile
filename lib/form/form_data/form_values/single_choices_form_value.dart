import 'package:mobx/mobx.dart';
import 'package:podd_app/form/form_data/definitions/form_data_definition.dart';
import 'package:podd_app/form/form_data/definitions/form_data_validation.dart';

import 'base_form_value.dart';

class SingleChoicesFormValue extends BaseFormValue<String?> {
  SingleChoiceDataDefinition dataDefinition;

  // viewmodel for custom text input
  // enable by setting textInput = true
  final _text = Observable<String?>(null);

  // error message for custom text input
  final _invalidTextInputMessage = Observable<String?>(null);

  set text(String? newValue) {
    Action(() {
      _text.value = newValue;
      clearTextInputError();
    })();
  }

  String? get text => _text.value;

  String? get invalidTextInputMessage => _invalidTextInputMessage.value;

  void clearTextInputError() {
    Action(() {
      _invalidTextInputMessage.value = null;
    })();
  }

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
            if (selectedOption.textInput) {
              if (text == null || text == "") {
                Action(() {
                  _invalidTextInputMessage.value = "This field is required";
                })();
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
