import 'dart:convert';

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:podd_app/services/file_service.dart';
import 'package:podd_app/services/image_service.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:podd_app/services/report_type_service.dart';
import 'package:podd_app/ui/report/form_base_view_model.dart';
import 'package:uuid/uuid.dart';

var _uuid = const Uuid();

class ReportFormViewModel extends FormBaseViewModel {
  final IReportService _reportService = locator<IReportService>();
  final IReportTypeService _reportTypeService = locator<IReportTypeService>();
  final IImageService _imageService = locator<IImageService>();
  final IFileService _fileService = locator<IFileService>();

  final String _reportTypeId;
  final bool _testFlag;
  String _reportId = "";
  Form _formStore = Form.fromJson({}, "");
  bool? _incidentInAuthority = true;
  ReportType? reportType;

  ReportFormViewModel(this._testFlag, this._reportTypeId) : super() {
    init();
  }

  init() async {
    reportType = await _reportTypeService.getReportType(_reportTypeId);
    if (reportType != null) {
      final String timezone = await FlutterTimezone.getLocalTimezone();
      _reportId = _uuid.v4();
      _formStore = Form.fromJson(
          json.decode(reportType!.definition), _reportId, _testFlag);
      _formStore.setTimezone(timezone);
      isReady = true;
      notifyListeners();
    }
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

  clearPendingFilesAndImages() async {
    var pendingImages = await _imageService.findByReportId(_reportId);
    for (var image in pendingImages) {
      await _imageService.removePendingImage(image.id);
    }

    var pendingFiles =
        await _fileService.findAllReportFilesByReportId(_reportId);
    for (var file in pendingFiles) {
      await _fileService.removePendingFile(file.id);
    }
  }

  Future<ReportSubmitResult> submit() async {
    setBusy(true);
    String? gpsLocation = _findFirstLocationValue(formStore);
    DateTime? incidentDate = _findFirstIncidentDateValue(formStore);

    var report = Report(
      id: _reportId,
      data: formStore.toJsonValue(),
      reportTypeId: reportType!.id,
      reportTypeName: reportType!.name,
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
