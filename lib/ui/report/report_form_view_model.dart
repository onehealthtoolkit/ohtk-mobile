import 'dart:convert';

import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:podd_app/ui/report/form_base_view_model.dart';
import 'package:uuid/uuid.dart';

var _uuid = const Uuid();

class ReportFormViewModel extends FormBaseViewModel {
  final IReportService _reportService = locator<IReportService>();

  final ReportType _reportType;
  final bool _testFlag;
  String _reportId = "";
  Form _formStore = Form.fromJson({}, "");
  bool? _incidentInAuthority = true;

  ReportFormViewModel(this._testFlag, this._reportType) : super() {
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

  @override
  Form get formStore => _formStore;

  @override
  bool get isTestMode => _testFlag;

  bool? get incidentInAuthority => _incidentInAuthority;

  set incidentInAuthority(bool? value) {
    _incidentInAuthority = value;
    notifyListeners();
  }

  Future<ReportSubmitResult> submit() async {
    setBusy(true);
    String? gpsLocation = _findFirstLocationValue(formStore);
    DateTime? incidentDate = _findFirstIncidentDateValue(formStore);

    var report = Report(
      id: _reportId,
      data: formStore.toJsonValue(),
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
