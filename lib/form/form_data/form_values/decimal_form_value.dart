import 'package:decimal/decimal.dart';

import 'base_form_value.dart';

class DecimalFormValue extends BaseFormValue<Decimal?> {
  DecimalFormValue(validationDefinitions) : super(validationDefinitions);

  @override
  toJson() {
    return value?.toStringAsFixed(2);
  }
}
