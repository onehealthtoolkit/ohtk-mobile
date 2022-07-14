import 'package:podd_app/form/form_data/form_values/base_form_value.dart';

class LocationFormValue extends BaseFormValue<String?> {
  LocationFormValue(validations) : super(validations);

  double? get latitude {
    if (value != null) {
      var latLongAry = value!.split(',');
      var latValue = double.parse(latLongAry[1]);
      return latValue;
    } else {
      return null;
    }
  }

  double? get longitude {
    if (value != null) {
      var latLongAry = value!.split(',');
      var longValue = double.parse(latLongAry[0]);
      return longValue;
    } else {
      return null;
    }
  }
}
