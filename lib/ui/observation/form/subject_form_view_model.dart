import 'dart:convert';

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/models/entities/observation_report_subject.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/observation_subject_submit_result.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:podd_app/services/observation_definition_service.dart';
import 'package:podd_app/services/observation_record_service.dart';
import 'package:podd_app/ui/report/form_base_view_model.dart';
import 'package:uuid/uuid.dart';

var _uuid = const Uuid();

class ObservationSubjectFormViewModel extends FormBaseViewModel {
  final IObservationRecordService _observationService =
      locator<IObservationRecordService>();
  final IObservationDefinitionService _observationDefinitionService =
      locator<IObservationDefinitionService>();

  final String _definitionId;
  final ObservationSubjectRecord? _subject;
  String _subjectId = "";
  Form _formStore = Form.fromJson({}, "");
  ObservationDefinition? definition;

  @override
  Form get formStore => _formStore;

  ObservationSubjectFormViewModel(this._definitionId, [this._subject]) {
    init();
  }

  init() async {
    var definitionId = int.parse(_definitionId);
    definition = await _observationDefinitionService
        .getObservationDefinition(definitionId);

    if (definition != null) {
      _subjectId = _uuid.v4();
      _formStore = Form.fromJson(
          json.decode(definition!.registerFormDefinition), _subjectId);

      final String timezone = await FlutterTimezone.getLocalTimezone();
      _formStore.setTimezone(timezone);

      if (_subject != null) {
        _formStore.loadJsonValue(_subject!.formData ?? {});
      }
      isReady = true;
      notifyListeners();
    }
  }

  @override
  bool get isTestMode => false;

  Future<SubjectRecordSubmitResult> submit() async {
    setBusy(true);
    String? gpsLocation = _findFirstLocationValue(_formStore);

    var report = SubjectRecord(
      id: _subjectId,
      data: _formStore.toJsonValue(),
      definitionId: definition!.id,
      definitionName: definition!.name,
      gpsLocation: gpsLocation,
      recordDate: DateTime.now(),
    );

    SubjectRecordSubmitResult result;
    if (_subject != null) {
      /// No data saving in form non-editing mode
      result = SubjectRecordSubmitPending();
    } else {
      result = await _observationService.submitSubjectRecord(report);
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
