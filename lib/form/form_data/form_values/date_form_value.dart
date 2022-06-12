import 'base_form_value.dart';

class DateFormValue extends BaseFormValue<DateTime?> {
  DateFormValue(validationDefinitions) : super(validationDefinitions);

  @override
  toJson() {
    return value?.toIso8601String();
  }
}
