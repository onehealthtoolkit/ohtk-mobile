import 'package:mobx/mobx.dart';
import 'package:podd_app/form/form_data/definitions/form_data_validation.dart';

abstract class IFormData {}

typedef ValidateFunction = bool Function(IFormData root);

abstract class IValidatable {
  List<ValidateFunction> validationFunctions = [];

  bool validate(IFormData root) {
    return validationFunctions.every((v) => v(root));
  }

  bool get isValid;

  String? get invalidateMessage;
}

abstract class BaseFormValue<T> extends IValidatable {
  final _value = Observable<T?>(null);
  final _invalidateMessage = Observable<String?>(null);

  set value(T? newValue) {
    Action(() {
      _value.value = newValue;
      clearError();
    })();
  }

  T? get value => _value.value;

  @override
  bool get isValid => _invalidateMessage.value == null;

  @override
  String? get invalidateMessage => _invalidateMessage.value;

  void markError(String message) {
    Action(() {
      _invalidateMessage.value = message;
    })();
  }

  void clearError() {
    if (_invalidateMessage.value != null) {
      Action(() {
        _invalidateMessage.value = null;
      })();
    }
  }

  @override
  BaseFormValue(List<ValidationDataDefinition> validationDefinitions) {
    for (var definition in validationDefinitions) {
      initialValidation(definition);
    }
  }

  // implementation of required validation
  // subclass must override this method to implement another validation method.
  initialValidation(ValidationDataDefinition validationDefinition) {
    if (validationDefinition is RequiredValidationDefinition) {
      validationFunctions.add((IFormData root) {
        if (_value.value == null || _value.value == "") {
          _invalidateMessage.value = "This field is required";
          return false;
        } else {
          _invalidateMessage.value = null;
        }
        return true;
      });
    }
  }
}
