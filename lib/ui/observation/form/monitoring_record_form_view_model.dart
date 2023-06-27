import 'dart:convert';

import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_monitoring_definition.dart';
import 'package:podd_app/models/entities/observation_report_monitoring_record.dart';
import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/models/observation_monitoring_record_submit_result.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:podd_app/services/observation_definition_service.dart';
import 'package:podd_app/services/observation_record_service.dart';
import 'package:podd_app/ui/report/form_base_view_model.dart';
import 'package:uuid/uuid.dart';

var _uuid = const Uuid();

class ObservationMonitoringRecordFormViewModel extends FormBaseViewModel {
  final IObservationRecordService _observationService =
      locator<IObservationRecordService>();
  final IObservationDefinitionService _observationDefinitionService =
      locator<IObservationDefinitionService>();

  final String _monitoringDefinitionId;
  final String _subjectId;
  final ObservationMonitoringRecord? _monitoringRecord;
  ObservationMonitoringDefinition? definition;

  String _reportId = "";
  Form _formStore = Form.fromJson({}, "");

  @override
  Form get formStore => _formStore;

  ObservationMonitoringRecordFormViewModel(
      this._monitoringDefinitionId, this._subjectId,
      [this._monitoringRecord]) {
    init();
  }

  init() async {
    var id = int.parse(_monitoringDefinitionId);
    definition = await _observationDefinitionService
        .getObservationMonitoringDefinition(id);

    if (definition != null) {
      _reportId = _uuid.v4();
      _formStore =
          Form.fromJson(json.decode(definition!.formDefinition), _reportId);

      final String timezone = await FlutterNativeTimezone.getLocalTimezone();
      _formStore.setTimezone(timezone);

      if (_monitoringRecord != null) {
        _formStore.loadJsonValue(_monitoringRecord!.formData ?? {});
      }
      isReady = true;
      notifyListeners();
    }
  }

  @override
  bool get isTestMode => false;

  Future<MonitoringRecordSubmitResult> submit() async {
    setBusy(true);

    var report = MonitoringRecord(
      id: _reportId,
      data: _formStore.toJsonValue(),
      monitoringDefinitionId: definition!.id,
      monitoringDefinitionName: definition!.name,
      subjectId: _subjectId,
      recordDate: DateTime.now(),
    );

    MonitoringRecordSubmitResult result;
    if (_monitoringRecord != null) {
      /// No data saving in form non-editing mode
      result = MonitoringRecordSubmitPending();
    } else {
      result = await _observationService.submitMonitoringRecord(report);
    }

    setBusy(false);
    return result;
  }
}
