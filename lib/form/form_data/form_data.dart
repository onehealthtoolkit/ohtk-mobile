import 'package:decimal/decimal.dart';
import 'package:mobx/mobx.dart';
import 'package:uuid/uuid.dart';

import 'form_data_definition.dart';

var uuid = const Uuid();

typedef ValidateFunction = bool Function(FormData root);

abstract class IValidatable {
  bool validate(FormData root);
}

abstract class Validatable implements IValidatable {
  List<ValidateFunction> validationFunctions = [];

  @override
  bool validate(FormData root) {
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
      if (_isValid.value == false) {
        _isValid.value = true;
        _invalidateMessage.value = null;
      }
    })();
  }

  T? get value => _value.value;

  bool get isValid => _isValid.value;

  String? get invalidateMessage => _invalidateMessage.value;

  @override
  BaseFormValue(List<ValidationDataDefinition> validationDefinitions) {
    for (var definition in validationDefinitions) {
      if (definition is RequiredValidationDefinition) {
        validationFunctions.add((FormData root) {
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
}

class StringFormValue extends BaseFormValue<String?> {
  StringFormValue(validationDefinitions) : super(validationDefinitions);
}

class IntegerFormValue extends BaseFormValue<int?> {
  IntegerFormValue(validationDefinitions) : super(validationDefinitions);
}

class BooleanFormValue extends BaseFormValue<bool?> {
  BooleanFormValue(validationDefinitions) : super(validationDefinitions);
}

class DateFormValue extends BaseFormValue<DateTime?> {
  DateFormValue(validationDefinitions) : super(validationDefinitions);
}

class DecimaFormlValue extends BaseFormValue<Decimal?> {
  DecimaFormlValue(validationDefinitions) : super(validationDefinitions);
}

class ImagesFormValue extends Validatable {
  final _value = ObservableList<String>.of([]);
  final _isValid = Observable<bool>(true);
  final _invalidateMessage = Observable<String?>(null);

  add(String imageId) {
    Action(() {
      _value.add(imageId);
      if (_isValid.value == false) {
        _isValid.value = true;
        if (_invalidateMessage.value != null) {
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
        validationFunctions.add((FormData root) {
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

class FormData implements IValidatable {
  Map<String, IValidatable> values = {};
  late String id;
  String? name;
  FormDataDefinition? definition;

  FormData({this.name, this.definition}) {
    id = uuid.v4();
    definition?.properties.forEach((key, value) {
      if (value is StringDataDefinition) {
        addStringValue(key, value.validations);
      } else if (value is IntegerDataDefinition) {
        addIntegerValue(key, value.validations);
      } else if (value is BooleanDataDefinition) {
        addBooleanValue(key, value.validations);
      } else if (value is DateDataDefinition) {
        addDateFormValue(key, value.validations);
      } else if (value is DecimalDataDefinition) {
        addDecimalValue(key, value.validations);
      } else if (value is FormDataDefinition) {
        addFormDataValue(key, FormData(name: key, definition: value));
      } else if (value is ArrayDataDefinition) {
        addArrayDataValue(key, value.cols);
      } else if (value is ImagesDataDefinition) {
        addImagesDataValue(key, value.validations);
      }
    });
  }

  getFormValue(String name) {
    return values[name];
  }

  addStringValue(String name, List<ValidationDataDefinition> validations) {
    values[name] = StringFormValue(validations);
    return values[name];
  }

  addIntegerValue(String name, List<ValidationDataDefinition> validations) {
    values[name] = IntegerFormValue(validations);
    return values[name];
  }

  addBooleanValue(String name, List<ValidationDataDefinition> validations) {
    values[name] = BooleanFormValue(validations);
    return values[name];
  }

  addDateFormValue(String name, List<ValidationDataDefinition> validations) {
    values[name] = DateFormValue(validations);
    return values[name];
  }

  addDecimalValue(String name, List<ValidationDataDefinition> validations) {
    values[name] = DecimaFormlValue(validations);
    return values[name];
  }

  addFormDataValue(String name, FormData value) {
    values[name] = value;
    return values[name];
  }

  addArrayDataValue(String name, FormDataDefinition cols) {
    values[name] = ArrayFormValue(cols);
    return values[name];
  }

  addImagesDataValue(String name, List<ValidationDataDefinition> validations) {
    values[name] = ImagesFormValue(validations);
    return values[name];
  }

  Map<String, dynamic> toJson() {
    final values = <String, dynamic>{};

    definition?.properties.forEach((key, value) {
      if (value is StringDataDefinition) {
        values[key] = (getFormValue(key) as StringFormValue).value;
      } else if (value is IntegerDataDefinition) {
        values[key] = (getFormValue(key) as IntegerFormValue).value;
      } else if (value is BooleanDataDefinition) {
        values[key] = (getFormValue(key) as BooleanFormValue).value;
      } else if (value is DateDataDefinition) {
        values[key] = (getFormValue(key) as DateFormValue).value;
      } else if (value is DecimalDataDefinition) {
        values[key] = (getFormValue(key) as DecimaFormlValue).value;
      } else if (value is FormDataDefinition) {
        values[key] = (getFormValue(key) as FormData).toJson();
      } else if (value is ArrayDataDefinition) {
        addArrayDataValue(key, value.cols);
        values[key] = (getFormValue(key) as ArrayFormValue).toJson();
      }
    });
    return values;
  }

  @override
  bool validate(FormData root) {
    var valid = true;
    values.forEach((key, value) {
      valid = valid && value.validate(root);
    });
    return valid;
  }
}

class ArrayFormValue extends Validatable {
  final FormDataDefinition cols;
  final _value = ObservableList<FormData>.of([]);

  ArrayFormValue(this.cols);

  createNewRow() {
    var formData = FormData(definition: cols);
    Action(() {
      _value.add(formData);
    })();
  }

  deleteRowAt(int index) {
    Action(() {
      _value.removeAt(index);
    })();
  }

  int get length => _value.length;

  List<Map<String, dynamic>> toJson() {
    return _value.map((element) => element.toJson()).toList();
  }
}
