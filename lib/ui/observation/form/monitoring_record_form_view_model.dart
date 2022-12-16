import 'dart:convert';

import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_monitoring_definition.dart';
import 'package:podd_app/models/entities/observation_report_monitoring_record.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/models/observation_monitoring_record_submit_result.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:podd_app/services/observation_service.dart';
import 'package:stacked/stacked.dart';
import 'package:uuid/uuid.dart';

enum ObservationMonitoringRecordFormState {
  formInput,
  confirmation,
}

enum BackAction {
  navigationPop,
  doNothing,
}

var _uuid = const Uuid();

class ObservationMonitoringRecordFormViewModel extends BaseViewModel {
  final IObservationService _observationService =
      locator<IObservationService>();

  final ObservationMonitoringDefinition _definition;
  final ObservationSubject _subject;
  final ObservationSubjectMonitoring? _monitoringRecord;

  bool isReady = false;
  String _reportId = "";
  Form _formStore = Form.fromJson({}, "");
  ObservationMonitoringRecordFormState state =
      ObservationMonitoringRecordFormState.formInput;

  Form get formStore => _formStore;

  ObservationMonitoringRecordFormViewModel(this._definition, this._subject,
      [this._monitoringRecord]) {
    init();
  }

  init() async {
    _reportId = _uuid.v4();
    _formStore =
        Form.fromJson(json.decode(_definition.formDefinition), _reportId);

    final String _timezone = await FlutterNativeTimezone.getLocalTimezone();
    _formStore.setTimezone(_timezone);

    if (_monitoringRecord != null) {
      _formStore.loadJsonValue(_monitoringRecord!.formData ?? {});
    }
    isReady = true;
    notifyListeners();
  }

  BackAction back() {
    if (state == ObservationMonitoringRecordFormState.formInput) {
      if (formStore.couldGoToPreviousSection) {
        formStore.previous();
      } else {
        return BackAction.navigationPop;
      }
    } else if (state == ObservationMonitoringRecordFormState.confirmation) {
      state = ObservationMonitoringRecordFormState.formInput;
      notifyListeners();
    }
    return BackAction.doNothing;
  }

  next() {
    if (state == ObservationMonitoringRecordFormState.formInput) {
      if (formStore.couldGoToNextSection) {
        formStore.next();
      } else {
        if (formStore.currentSection.validate()) {
          state = ObservationMonitoringRecordFormState.confirmation;
          notifyListeners();
        }
      }
    } else {}
  }

  Future<ObservationMonitoringRecordSubmitResult> submit() async {
    setBusy(true);

    var report = ObservationReportMonitoringRecord(
      id: _reportId,
      data: _formStore.toJsonValue(),
      monitoringDefinitionId: _definition.id,
      subjectId: _subject.id,
    );

    ObservationMonitoringRecordSubmitResult result;
    if (_monitoringRecord != null) {
      // TODO update form data
      result = ObservationMonitoringRecordSubmitPending();
    } else {
      result = await _observationService.submitReportMonitoringRecord(report);
    }

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
}