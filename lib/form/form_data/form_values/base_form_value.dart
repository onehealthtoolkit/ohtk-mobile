import 'package:mobx/mobx.dart';
import 'package:podd_app/form/form_data/definitions/form_data_validation.dart';

abstract class IFormData {}

typedef ValidateFunction = bool Function(IFormData root);

abstract class IValidatable {
  bool validate(IFormData root);
}

abstract class Validatable implements IValidatable {
  List<ValidateFunction> validationFunctions = [];

  @override
  bool validate(IFormData root) {
    return validationFunctions.every((v) => v(root));
  }
}

abstract class BaseFormValue<T> extends Validatable {
  final _value = Observable<T?>(null);
  final _isValid = Observable<bool>(true);
  final _invalidateMessage = Observable<String?>(null);

  set value(T? newValue) {
    Action(() {
      _value.value = newValue;
      clearError();
    })();
  }

  T? get value => _value.value;

  bool get isValid => _isValid.value;

  String? get invalidateMessage => _invalidateMessage.value;

  void markError(String message) {
    Action(() {
      _isValid.value = false;
      _invalidateMessage.value = message;
    })();
  }

  void clearError() {
    Action(() {
      if (_isValid.value == false) {
        _isValid.value = true;
        _invalidateMessage.value = null;
      }
    })();
  }

  @override
  BaseFormValue(List<ValidationDataDefinition> validationDefinitions) {
    for (var definition in validationDefinitions) {
      initialValidation(definition);
    }
  }

  initialValidation(ValidationDataDefinition validationDefinition) {
    if (validationDefinition is RequiredValidationDefinition) {
      validationFunctions.add((IFormData root) {
        if (_value.value == null || _value.value == "") {
          _isValid.value = false;
          _invalidateMessage.value = "This field is required";
          return false;
        } else {
          _isValid.value = true;
          _invalidateMessage.value = null;
        }
        return true;
      });
    }
  }
}
