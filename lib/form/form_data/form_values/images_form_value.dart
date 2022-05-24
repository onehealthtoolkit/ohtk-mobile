import 'package:mobx/mobx.dart';
import 'package:podd_app/form/form_data/definitions/form_data_validation.dart';

import 'base_form_value.dart';

class ImagesFormValue extends IValidatable {
  final _value = ObservableList<String>.of([]);
  final _invalidateMessage = Observable<String?>(null);

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
  bool get isValid => _invalidateMessage.value == null;

  @override
  String? get invalidateMessage => _invalidateMessage.value;

  int get length => _value.length;

  _validate() {
    if (_value.isEmpty) {
      _invalidateMessage.value = "this field is required";
      return false;
    }
    _invalidateMessage.value = null;
    return true;
  }

  ImagesFormValue(validationDefinitions) {
    for (var definition in validationDefinitions) {
      if (definition is RequiredValidationDefinition) {
        validationFunctions.add((IFormData root) {
          return _validate();
        });
      }
    }
  }
}
