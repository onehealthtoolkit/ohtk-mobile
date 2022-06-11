import 'package:mobx/mobx.dart';
import 'package:podd_app/form/form_data/definitions/form_data_definition.dart';
import 'package:podd_app/form/form_data/definitions/form_data_validation.dart';
import 'package:podd_app/form/form_data/form_data.dart';

import 'base_form_value.dart';

class ArrayFormValue extends IValidatable with EnableConditionState {
  final FormDataDefinition cols;
  final _value = ObservableList<FormData>.of([]);

  ArrayFormValue(this.cols) : super([]);

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

  @override
  // TODO: implement invalidMessage
  String? get invalidMessage => throw UnimplementedError();

  @override
  // TODO: implement isValid
  bool get isValid => throw UnimplementedError();

  @override
  void initValidation(ValidationDataDefinition validationDefinition) {
    // TODO: implement initValidation
  }

  @override
  String getStringValue() {
    // TODO: implement getStringValue
    throw UnimplementedError();
  }
}
