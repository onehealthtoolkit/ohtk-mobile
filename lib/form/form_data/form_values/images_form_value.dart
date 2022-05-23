import 'package:mobx/mobx.dart';
import 'package:podd_app/form/form_data/definitions/form_data_validation.dart';

import 'base_form_value.dart';

class ImagesFormValue extends Validatable {
  final _value = ObservableList<String>.of([]);
  final _isValid = Observable<bool>(true);
  final _invalidateMessage = Observable<String?>(null);

  add(String imageId) {
    Action(() {
      _value.add(imageId);
      if (isValid) {
        _isValid.value = true;
        if (invalidateMessage != null) {
          _invalidateMessage.value = null;
        }
      }
    })();
  }

  remove(String id) {
    Action(() {
      _value.remove(id);
    })();
  }

  List<String> get value => _value;

  bool get isValid => _isValid.value;

  String? get invalidateMessage => _invalidateMessage.value;

  int get length => _value.length;

  ImagesFormValue(validationDefinitions) {
    for (var definition in validationDefinitions) {
      if (definition is RequiredValidationDefinition) {
        validationFunctions.add((IFormData root) {
          if (_value.isEmpty) {
            _isValid.value = false;
            _invalidateMessage.value = "this field is required";
            return false;
          }
          return true;
        });
      }
    }
  }
}
