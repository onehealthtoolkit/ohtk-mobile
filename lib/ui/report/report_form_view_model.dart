import 'dart:convert';

import 'package:flutter_native_timezone/flutter_native_timezone.dart';
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
  final bool _testFlag;
  bool isReady = false;
  String _reportId = "";
  Form _formStore = Form.fromJson({}, "");
  ReportFormState state = ReportFormState.formInput;
  bool? _incidentInAuthority = true;

  Form get formStore => _formStore;

  ReportFormViewModel(this._testFlag, this._reportType) {
    init();
  }

  init() async {
    final String _timezone = await FlutterNativeTimezone.getLocalTimezone();
    _reportId = _uuid.v4();
    _formStore = Form.fromJson(json.decode(_reportType.definition), _reportId);
    _formStore.setTimezone(_timezone);
    isReady = true;
    notifyListeners();
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

  Future<ReportSubmitResult> submit() async {
    setBusy(true);
    String? gpsLocation = _findFirstLocationValue(_formStore);
    DateTime? incidentDate = _findFirstIncidentDateValue(_formStore);

    var report = Report(
      id: _reportId,
      data: _formStore.toJsonValue(),
      reportTypeId: _reportType.id,
      reportTypeName: _reportType.name,
      incidentDate: incidentDate ?? DateTime.now(),
      gpsLocation: gpsLocation,
      incidentInAuthority: _incidentInAuthority,
      testFlag: _testFlag,
    );

    var result = await _reportService.submit(report);

    setBusy(false);
    return result;
  }

  String? _findFirstLocationValue(Form form) {
    String? result;
    var field = form.findField(((field) =>
        (field is LocationField) &&
        (field.longitude != null && field.latitude != null)));

    if (field != null && field is LocationField) {
      result = "${field.longitude.toString()},${field.latitude.toString()}";
    }
    return result;
  }

  DateTime? _findFirstIncidentDateValue(Form form) {
    DateTime? result;
    var field = form.findField((field) =>
        field is DateField &&
        field.tags != null &&
        field.tags!.contains("incident_date"));

    if (field != null && field is DateField) {
      result = field.value;
    }
    return result;
  }
}
