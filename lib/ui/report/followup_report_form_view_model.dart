import 'dart:convert';

import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/models/followup_submit_result.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:stacked/stacked.dart';
import 'package:uuid/uuid.dart';

enum ReportFormState {
  formInput,
  confirmation,
}

enum BackAction {
  navigationPop,
  doNothing,
}

var _uuid = const Uuid();

class FollowupReportFormViewModel extends BaseViewModel {
  final IReportService _reportService = locator<IReportService>();

  final ReportType reportType;
  final String incidentId;
  late String _reportId;
  late Form _formStore;
  ReportFormState state = ReportFormState.formInput;

  Form get formStore => _formStore;

  FollowupReportFormViewModel({
    required this.incidentId,
    required this.reportType,
  }) {
    _reportId = _uuid.v4();
    final definition = reportType.followupDefinition != null
        ? json.decode(reportType.followupDefinition!)
        : {"sections": []};

    _formStore = Form.fromJson(definition, _reportId);
  }

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

  next() {
    if (state == ReportFormState.formInput) {
      if (formStore.couldGoToNextSection) {
        formStore.next();
      } else {
        if (formStore.currentSection.validate()) {
          state = ReportFormState.confirmation;
          notifyListeners();
        }
      }
    } else {}
  }

  Future<FollowupSubmitResult> submit() async {
    setBusy(true);
    var data = _formStore.toJsonValue();
    var result = await _reportService.submitFollowup(
      incidentId,
      _reportId,
      data,
    );
    setBusy(false);
    return result;
  }
}
