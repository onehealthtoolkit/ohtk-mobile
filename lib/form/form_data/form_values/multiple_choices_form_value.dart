import 'dart:collection';

import 'package:mobx/mobx.dart';
import 'package:podd_app/form/form_data/definitions/form_data_definition.dart';
import 'package:podd_app/form/form_data/definitions/form_data_validation.dart';

import 'base_form_value.dart';

class MultipleChoicesFormValue extends FormValue {
  final _invalidMessage = Observable<String?>(null);

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

  @override
  bool get isValid => _invalidMessage.value == null;

  final MultipleChoiceDataDefinition dataDefinition;
  final Map<String, Observable<bool>> _selected = HashMap.of({});
  final Map<String, Observable<String?>> _text = HashMap.of({});
  final Map<String, Observable<String?>> _invalidTextMessage = HashMap.of({});

  bool valueFor(String key) => _selected[key]?.value ?? false;
  Observable<String?>? textValueFor(String key) => _text[key];
  Observable<String?>? invalidTextMessageFor(String key) =>
      _invalidTextMessage[key];

  setTextValueFor(String key, String value) {
    Action(() {
      _text[key]?.value = value;
      _invalidTextMessage[key]?.value = null;
    })();
  }

  MultipleChoicesFormValue(this.dataDefinition)
      : super(dataDefinition.validations) {
    for (var option in dataDefinition.options) {
      _selected[option.value] = Observable(false);
      if (option.textInput) {
        _text[option.value] = Observable(null);
        _invalidTextMessage[option.value] = Observable(null);
      }
    }
  }

  @override
  void initValidation(ValidationDataDefinition validationDefinition) {
    if (validationDefinition is RequiredValidationDefinition) {
      validationFunctions.add((IFormData root) {
        bool hasTick = dataDefinition.options.any((option) {
          return valueFor(option.value);
        });
        if (!hasTick) {
          markError("This field is required");
          return false;
        } else {
          bool found = false;
          for (var option in dataDefinition.options) {
            if (option.textInput) {
              if (valueFor(option.value) &&
                  (textValueFor(option.value)!.value == null ||
                      textValueFor(option.value)!.value == '')) {
                Action(() {
                  _invalidTextMessage[option.value]!.value =
                      "this field is required";
                })();
                found = true;
              }
            }
          }
          return !found;
        }
      });
    }
  }

  void setSelectedFor(String key, bool value) {
    Action(() {
      _selected[key]?.value = value;
      if (_text[key] != null && !value) {
        _text[key]!.value = null;
      }
      clearError();
    })();
  }

  @override
  String toString() {
    var selected = [];
    for (var option in dataDefinition.options) {
      if (_selected[option.value]!.value) {
        selected.add(option.value);
      }
    }
    return selected.join(",");
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    _selected.forEach((key, value) {
      json[key] = value.value;
    });
    _text.forEach((key, value) {
      json["${key}_text"] = value.value;
    });
    return json;
  }
}
