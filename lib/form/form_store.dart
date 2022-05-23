import 'package:mobx/mobx.dart';
import 'package:podd_app/form/widgets/validation.dart';

import 'form_data/form_data.dart';
import 'form_data/form_data_definition.dart';
import 'ui_definition/form_ui_definition.dart';

part 'form_store.g.dart';

class FormStore = _FormStore with _$FormStore;

abstract class _FormStore with Store {
  final String uuid;
  final FormUIDefinition uiDefinition;
  late FormDataDefinition dataDefinition;
  late FormData formData;

  final List<ValidationCallbackFuncion> validationCallbacks = [];

  @observable
  int currentSectionIdx = 0;

  _FormStore(this.uuid, this.uiDefinition) {
    dataDefinition = FormDataDefinition.fromUIDefinition(uiDefinition);
    formData = FormData(name: 'root', definition: dataDefinition);
  }

  int get numberOfSections {
    return uiDefinition.sections.length;
  }

  @computed
  Section get currentSection {
    return uiDefinition.sections[currentSectionIdx];
  }

  @action
  void next() {
    if (couldGoToNextSection) {
      if (validate()) {
        currentSectionIdx++;
      }
    }
  }

  @action
  void previous() {
    if (couldGoToPreviousSection) {
      currentSectionIdx--;
    }
  }

  @action
  bool validate() {
    var valid = true;
    for (var question in currentSection.questions) {
      for (var field in question.fields) {
        valid = valid & formData.getFormValue(field.name).validate(formData);
      }
    }
    return valid;
  }

  @computed
  bool get couldGoToPreviousSection {
    return currentSectionIdx > 0;
  }

  @computed
  bool get couldGoToNextSection {
    return currentSectionIdx < uiDefinition.sections.length - 1;
  }

  @action
  Future<bool> submit() async {
    if (validate()) {
      return true;
    } else {
      return false;
    }
  }

  @computed
  String get currentSectionHeader {
    return uiDefinition.sections[currentSectionIdx].label;
  }

  UnRegisterValidationCallback registerValidation(
      ValidationCallbackFuncion callback) {
    validationCallbacks.add(callback);
    return () => validationCallbacks.remove(callback);
  }
}
