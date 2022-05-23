import 'package:mobx/mobx.dart';
import 'package:podd_app/form/form_data/definitions/form_data_definition.dart';
import 'package:podd_app/form/form_data/form_data.dart';

import 'base_form_value.dart';

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
