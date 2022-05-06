import 'dart:convert';

import 'package:podd_app/form/form_store.dart';
import 'package:podd_app/form/ui_definition/form_ui_definition.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:stacked/stacked.dart';
import 'package:uuid/uuid.dart';

enum ReportFormState {
  formInput,
  confirmation,
}

enum BackAction {
  popAction,
  doNothing,
}

var _uuid = const Uuid();

class ReportViewModel extends BaseViewModel {
  final ReportType _reportType;
  ReportFormState state = ReportFormState.formInput;
  late String _reportId;
  late FormStore _formStore;

  FormStore get formStore => _formStore;

  ReportViewModel(this._reportType) {
    _reportId = _uuid.v4();
    var reportDefinition = _reportType.definition;
    var uiDefinition = FormUIDefinition.fromJson(json.decode(reportDefinition));
    _formStore = FormStore(_reportId, uiDefinition);
  }

  BackAction back() {
    if (state == ReportFormState.formInput) {
      if (formStore.couldGoToPreviousSection) {
        formStore.previous();
      } else {
        return BackAction.popAction;
      }
    } else if (state == ReportFormState.confirmation) {
      state = ReportFormState.formInput;
      notifyListeners();
    }
    return BackAction.doNothing;
  }

  next() {
    if (state == ReportFormState.formInput) {
      if (formStore.couldGoToNextSection) {
        formStore.next();
      } else {
        state = ReportFormState.confirmation;
        notifyListeners();
      }
    } else {}
  }
}
