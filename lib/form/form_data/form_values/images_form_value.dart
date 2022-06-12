import 'package:mobx/mobx.dart';
import 'package:podd_app/form/form_data/definitions/form_data_validation.dart';

import 'base_form_value.dart';

class ImagesFormValue extends FormValue {
  final _value = ObservableList<String>.of([]);
  final _invalidMessage = Observable<String?>(null);

  add(String imageId) {
    Action(() {
      _value.add(imageId);
      _validate();
    })();
  }

  remove(String id) {
    Action(() {
      _value.remove(id);
      _validate();
    })();
  }

  List<String> get value => _value;

  @override
  bool get isValid => _invalidMessage.value == null;

  @override
  String? get invalidMessage => _invalidMessage.value;

  int get length => _value.length;

  _validate() {
    if (_value.isEmpty) {
      _invalidMessage.value = "this field is required";
      return false;
    }
    _invalidMessage.value = null;
    return true;
  }

  ImagesFormValue(List<ValidationDataDefinition> validationDefinitions)
      : super(validationDefinitions);

  @override
  void initValidation(ValidationDataDefinition validationDefinition) {
    if (validationDefinition is RequiredValidationDefinition) {
      validationFunctions.add((IFormData root) {
        return _validate();
      });
    }
  }

  @override
  String toString() {
    return _value.join(',');
  }

  @override
  toJson() {
    return _value.join(',');
  }
}
