import 'package:mobx/mobx.dart';
import 'package:podd_app/form/form_data/definitions/form_data_validation.dart';
import 'package:podd_app/form/form_data/form_data.dart';
import 'package:podd_app/form/form_data/form_values/condition.dart';

abstract class IFormData {}

typedef ValidateFunction = bool Function(IFormData root);

abstract class IValue {
  String getStringValue();
}

abstract class IValidatable extends EnableConditionState with IValue {
  List<ValidateFunction> validationFunctions = [];

  bool validate(IFormData root) {
    return validationFunctions.every((v) => v(root));
  }

  bool get isValid;

  String? get invalidMessage;

  IValidatable(List<ValidationDataDefinition> validationDefinitions) {
    for (var definition in validationDefinitions) {
      initValidation(definition);
    }
  }

  // implementation of required validation
  // subclass must override this method to implement another validation method.
  void initValidation(ValidationDataDefinition validationDefinition);
}

abstract class EnableConditionState {
  String? dependOn;
  ConditionEvaluateFn conditionEvaluateFn = alwaysEnable;

  setConditionEvaluateFn(ConditionEvaluateFn fn) {
    conditionEvaluateFn = fn;
  }

  bool evaluateCondition(FormData formData) {
    return conditionEvaluateFn(formData);
  }
}

abstract class BaseFormValue<T> extends IValidatable {
  final _value = Observable<T?>(null);
  final _invalidMessage = Observable<String?>(null);

  set value(T? newValue) {
    Action(() {
      _value.value = newValue;
      clearError();
    })();
  }

  T? get value => _value.value;

  @override
  bool get isValid => _invalidMessage.value == null;

  @override
  String? get invalidMessage => _invalidMessage.value;

  void markError(String message) {
    Action(() {
      _invalidMessage.value = message;
    })();
  }

  void clearError() {
    if (_invalidMessage.value != null) {
      Action(() {
        _invalidMessage.value = null;
      })();
    }
  }

  BaseFormValue(List<ValidationDataDefinition> validationDefinitions)
      : super(validationDefinitions);

  @override
  initValidation(ValidationDataDefinition validationDefinition) {
    if (validationDefinition is RequiredValidationDefinition) {
      validationFunctions.add((IFormData root) {
        if (_value.value == null || _value.value == "") {
          _invalidMessage.value = "This field is required";
          return false;
        } else {
          _invalidMessage.value = null;
        }
        return true;
      });
    }
  }

  @override
  String getStringValue() {
    return _value.value.toString();
  }
}
