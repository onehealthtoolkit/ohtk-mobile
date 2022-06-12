import 'package:podd_app/form/form_data/form_data.dart';
import 'package:podd_app/form/ui_definition/condition_definition.dart';

typedef ConditionEvaluateFn = bool Function(FormData data);

bool alwaysEnable(FormData _data) {
  return true;
}

ConditionEvaluateFn createCondition(ConditionDefinition? definition) {
  if (definition != null) {
    bool equalEvalate(FormData formData) {
      var formValue = formData.getFormValue(definition.name);
      if (definition.operator == ConditionOperator.equal) {
        return formValue.isEqual(definition.value);
      }
      return true;
    }

    if (definition.operator == ConditionOperator.equal) {
      return equalEvalate;
    }
  }
  return alwaysEnable;
}
