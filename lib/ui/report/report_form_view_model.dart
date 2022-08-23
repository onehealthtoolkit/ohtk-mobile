import 'dart:convert';

import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/models/report_submit_result.dart';
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

class ReportFormViewModel extends BaseViewModel {
  final IReportService _reportService = locator<IReportService>();

  final ReportType _reportType;
  late String _reportId;
  late Form _formStore;
  ReportFormState state = ReportFormState.formInput;
  bool? _incidentInAuthority;

  Form get formStore => _formStore;

  ReportFormViewModel(this._reportType) {
    _reportId = _uuid.v4();
    _formStore = Form.fromJson(json.decode(_reportType.definition), _reportId);
  }

  bool? get incidentInAuthority => _incidentInAuthority;

  set incidentInAuthority(bool? value) {
    _incidentInAuthority = value;
    notifyListeners();
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

  Future<ReportSubmitResult> submit() async {
    setBusy(true);
    String? gpsLocation = _findFirstLocationValue(_formStore);

    var report = Report(
      id: _reportId,
      data: _formStore.toJsonValue(),
      reportTypeId: _reportType.id,
      reportTypeName: _reportType.name,
      incidentDate: DateTime.now(),
      gpsLocation: gpsLocation,
      incidentInAuthority: _incidentInAuthority,
    );

    // var result = await _reportService.submit(report);
    print(report.data);

    setBusy(false);
    // return result;
    return ReportSubmitFailure(Exception('xx'));
  }

  String? _findFirstLocationValue(Form form) {
    String? result;
    for (var section in form.sections) {
      for (var question in section.questions) {
        for (var field in question.fields) {
          if (field is LocationField) {
            if (field.longitude != null && field.latitude != null) {
              result ??=
                  "${field.longitude.toString()},${field.latitude.toString()}";
            }
          }
        }
      }
    }
    return result;
  }
}
