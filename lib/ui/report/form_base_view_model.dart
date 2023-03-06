import 'package:stacked/stacked.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';

enum ReportFormState {
  formInput,
  confirmation,
}

enum BackAction {
  navigationPop,
  doNothing,
}

abstract class FormBaseViewModel extends BaseViewModel {
  ReportFormState state = ReportFormState.formInput;

  Form get formStore;

  bool isReady = false;

  BackAction back() {
    if (state == ReportFormState.formInput) {
      if (formStore.couldGoToPreviousSection) {
        formStore.previous();
      } else {
        return BackAction.navigationPop;
      }
    } else if (state == ReportFormState.confirmation) {
      state = ReportFormState.formInput;
      notifyListeners();
    }
    return BackAction.doNothing;
  }

  get firstInvalidQuestion {
    return formStore.currentSection.firstInvalidQuestion;
  }

  get firstInvalidQuestionIndex {
    return formStore.currentSection.firstInvalidQuestionIndex;
  }

  bool next() {
    if (state == ReportFormState.formInput) {
      if (formStore.couldGoToNextSection) {
        return formStore.next();
      } else {
        var isValid = formStore.currentSection.validate();
        if (isValid) {
          state = ReportFormState.confirmation;
          notifyListeners();
          return true;
        } else {
          return false;
        }
      }
    } else {
      return false;
    }
  }
}
