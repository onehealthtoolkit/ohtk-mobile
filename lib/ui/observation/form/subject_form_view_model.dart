import 'dart:convert';

import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/models/entities/observation_report_subject.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/observation_subject_submit_result.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:podd_app/services/observation_service.dart';
import 'package:stacked/stacked.dart';
import 'package:uuid/uuid.dart';

enum ObservationSubjectFormState {
  formInput,
  confirmation,
}

enum BackAction {
  navigationPop,
  doNothing,
}

var _uuid = const Uuid();

class ObservationSubjectFormViewModel extends BaseViewModel {
  final IObservationService _observationService =
      locator<IObservationService>();

  final ObservationDefinition _definition;
  final ObservationSubject? _subject;
  bool isReady = false;
  String _subjectId = "";
  Form _formStore = Form.fromJson({}, "");
  ObservationSubjectFormState state = ObservationSubjectFormState.formInput;

  Form get formStore => _formStore;

  ObservationSubjectFormViewModel(this._definition, [this._subject]) {
    init();
  }

  init() async {
    _subjectId = _subject != null ? _subject!.id : _uuid.v4();
    _formStore = Form.fromJson(
        json.decode(_definition.registerFormDefinition), _subjectId);

    final String _timezone = await FlutterNativeTimezone.getLocalTimezone();
    _formStore.setTimezone(_timezone);

    if (_subject != null) {
      _formStore.loadJsonValue(_subject!.formData ?? {});
    }
    isReady = true;
    notifyListeners();
  }

  BackAction back() {
    if (state == ObservationSubjectFormState.formInput) {
      if (formStore.couldGoToPreviousSection) {
        formStore.previous();
      } else {
        return BackAction.navigationPop;
      }
    } else if (state == ObservationSubjectFormState.confirmation) {
      state = ObservationSubjectFormState.formInput;
      notifyListeners();
    }
    return BackAction.doNothing;
  }

  next() {
    if (state == ObservationSubjectFormState.formInput) {
      if (formStore.couldGoToNextSection) {
        formStore.next();
      } else {
        if (formStore.currentSection.validate()) {
          state = ObservationSubjectFormState.confirmation;
          notifyListeners();
        }
      }
    } else {}
  }

  Future<ObservationSubjectSubmitResult> submit() async {
    setBusy(true);
    String? gpsLocation = _findFirstLocationValue(_formStore);
    DateTime? incidentDate = _findFirstIncidentDateValue(_formStore);

    var report = ObservationReportSubject(
      id: _subjectId,
      data: _formStore.toJsonValue(),
      definitionId: _definition.id,
      incidentDate: incidentDate ?? DateTime.now(),
      gpsLocation: gpsLocation,
    );

    var result = await _observationService.submit(report);

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
