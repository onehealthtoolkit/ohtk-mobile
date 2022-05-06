import 'package:decimal/decimal.dart';
import 'package:mobx/mobx.dart';
import 'package:uuid/uuid.dart';

import 'form_data_definition.dart';

var uuid = const Uuid();

class BaseFormValue<T> {
  final _value = Observable<T?>(null);

  set value(T? newValue) {
    Action(() {
      _value.value = newValue;
    })();
  }

  T? get value => _value.value;
}

class StringFormValue extends BaseFormValue<String?> {}

class IntegerFormValue extends BaseFormValue<int?> {}

class BooleanFormValue extends BaseFormValue<bool?> {}

class DateFormValue extends BaseFormValue<DateTime?> {}

class DecimaFormlValue extends BaseFormValue<Decimal?> {}

class ImagesFormValue {
  final _value = ObservableList<String>.of([]);

  add(String imageId) {
    Action(() {
      _value.add(imageId);
    })();
  }

  remove(String id) {
    Action(() {
      _value.remove(id);
    })();
  }

  List<String> get value => _value;

  int get length => _value.length;
}

class FormData {
  var values = {};
  late String id;
  String? name;
  FormDataDefinition? definition;

  FormData({this.name, this.definition}) {
    id = uuid.v4();
    definition?.properties.forEach((key, value) {
      if (value is StringDataDefinition) {
        addStringValue(key);
      } else if (value is IntegerDataDefinition) {
        addIntegerValue(key);
      } else if (value is BooleanDataDefinition) {
        addBooleanValue(key);
      } else if (value is DateDataDefinition) {
        addDateFormValue(key);
      } else if (value is DecimalDataDefinition) {
        addDecimalValue(key);
      } else if (value is FormDataDefinition) {
        addFormDataValue(key, FormData(name: key, definition: value));
      } else if (value is ArrayDataDefinition) {
        addArrayDataValue(key, value.cols);
      } else if (value is ImagesDataDefinition) {
        addImagesDataValue(key);
      }
    });
  }

  getFormValue(String name) {
    return values[name];
  }

  addStringValue(String name) {
    values[name] = StringFormValue();
    return values[name];
  }

  addIntegerValue(String name) {
    values[name] = IntegerFormValue();
    return values[name];
  }

  addBooleanValue(String name) {
    values[name] = BooleanFormValue();
    return values[name];
  }

  addDateFormValue(String name) {
    values[name] = DateFormValue();
    return values[name];
  }

  addDecimalValue(String name) {
    values[name] = DecimaFormlValue();
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

  addImagesDataValue(String name) {
    values[name] = ImagesFormValue();
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
        values[key] = (getFormValue(key) as ArrayFormValue)
            .value
            ?.map((it) => it.toJson())
            .toList();
      }
    });
    return values;
  }
}

class ArrayFormValue extends BaseFormValue<List<FormData>> {
  final FormDataDefinition cols;

  ArrayFormValue(this.cols) {
    _value.value = [];
  }

  createNewRow() {
    var formData = FormData(definition: cols);
    Action(() {
      _value.value ??= [];
      _value.value!.add(formData);
    })();
  }

  deleteRowAt(int index) {
    Action(() {
      var len = _value.value?.length;
      if (len != null) {
        if (len > index) {
          _value.value?.removeAt(index);
        }
      } else {
        return;
      }
    })();
  }

  int get length => _value.value?.length ?? 0;
}
