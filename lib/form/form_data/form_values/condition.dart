import 'package:podd_app/form/form_data/form_data.dart';
import 'package:podd_app/form/ui_definition/condition_definition.dart';

typedef ConditionEvaluateFn = bool Function(FormData data);

bool alwaysEnable(FormData _data) {
  return true;
}

ConditionEvaluateFn createCondition(ConditionDefinition? definition) {
  if (definition != null) {
    if (definition.operator == ConditionOperator.equal) {
      return (FormData formData) {
        var formValue = formData.getFormValue(definition.name);
        var strValue = formValue.getStringValue();
        if (definition.operator == ConditionOperator.equal) {
          return strValue == definition.value;
        }
        return true;
      };
    }
  }
  return alwaysEnable;
}
