import 'dart:convert';

import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/models/followup_submit_result.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:podd_app/ui/report/form_base_view_model.dart';
import 'package:uuid/uuid.dart';

var _uuid = const Uuid();

class FollowupReportFormViewModel extends FormBaseViewModel {
  final IReportService _reportService = locator<IReportService>();

  final ReportType reportType;
  final String incidentId;
  String _reportId = "";
  Form _formStore = Form.fromJson({}, "");

  FollowupReportFormViewModel({
    required this.incidentId,
    required this.reportType,
  }) {
    init();
  }

  init() async {
    final String _timezone = await FlutterNativeTimezone.getLocalTimezone();
    _reportId = _uuid.v4();
    final definition = reportType.followupDefinition != null
        ? json.decode(reportType.followupDefinition!)
        : {"sections": []};

    _formStore = Form.fromJson(definition, _reportId);
    _formStore.setTimezone(_timezone);
    isReady = true;
    notifyListeners();
  }

  @override
  Form get formStore => _formStore;

  @override
  bool get isTestMode => false;

  Future<FollowupSubmitResult> submit() async {
    setBusy(true);
    var data = formStore.toJsonValue();
    var result = await _reportService.submitFollowup(
      incidentId,
      _reportId,
      data,
    );
    setBusy(false);
    return result;
  }
}
