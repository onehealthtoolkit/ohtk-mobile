import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/file_submit_result.dart';
import 'package:podd_app/models/image_submit_result.dart';
import 'package:podd_app/models/observation_monitoring_record_submit_result.dart';
import 'package:podd_app/models/observation_subject_submit_result.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:podd_app/services/file_service.dart';
import 'package:podd_app/services/image_service.dart';
import 'package:podd_app/services/observation_record_service.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:stacked/stacked.dart';

class ReSubmitViewModel extends ReactiveViewModel {
  late StreamSubscription<List<ConnectivityResult>> _connectionChangeStream;

  final _logger = locator<Logger>();
  final IReportService _reportService = locator<IReportService>();
  final IObservationRecordService _recordService =
      locator<IObservationRecordService>();
  final IImageService _imageService = locator<IImageService>();
  final IFileService _fileService = locator<IFileService>();

  final submissionStates = <String, Progress>{};

  bool isOffline = true;
  bool isSubmittingAll = false;

  ReSubmitViewModel() {
    _connectionChangeStream =
        Connectivity().onConnectivityChanged.listen(connectionChanged);
  }

  void connectionChanged(List<ConnectivityResult> result) async {
    if (result.contains(ConnectivityResult.none)) {
      _logger.w('not connected: no connection');
      isOffline = true;
    } else {
      _logger.i('network interface connected');
      isOffline = false;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _connectionChangeStream.cancel();
  }

  List<SubmissionState> get pendingReports {
    return _reportService.pendingReports
        .map((report) => SubmissionState(
              item: SubmissionItem(
                id: report.id,
                name: report.reportTypeName ?? "",
                date: report.incidentDate,
              ),
            )..state = submissionStates[report.id] ?? Progress.none)
        .toList();
  }

  List<SubmissionState> get pendingSubjectRecords {
    return _recordService.pendingSubjectRecords
        .map((record) => SubmissionState(
              item: SubmissionItem(
                id: record.id,
                name: record.definitionName,
                date: record.recordDate,
              ),
            )..state = submissionStates[record.id] ?? Progress.none)
        .toList();
  }

  List<SubmissionState> get pendingMonitoringRecords {
    return _recordService.pendingMonitoringRecords
        .map((record) => SubmissionState(
              item: SubmissionItem(
                id: record.id,
                name: record.monitoringDefinitionName,
                date: record.recordDate,
              ),
            )..state = submissionStates[record.id] ?? Progress.none)
        .toList();
  }

  List<SubmissionState> get pendingImages {
    final reportIds = pendingReports.map((e) => e.item.id).toList();
    final subjectRecordIds =
        pendingSubjectRecords.map((e) => e.item.id).toList();
    final monitoringRecordIds =
        pendingMonitoringRecords.map((e) => e.item.id).toList();

    final allPendingCaseIds =
        reportIds + subjectRecordIds + monitoringRecordIds;

    /// Only dangling images but their reports were already submitted.
    /// (images that failed to send along with their reports)
    /// All images that are not submitted with their pending reports, subject or monitoring records,
    /// are excluded from pending image list, because they will be included with their parent submission.
    var images = _imageService.pendingImages
        .where((image) => !allPendingCaseIds.contains(image.reportId));

    return images
        .map((image) => SubmissionState(
              item: SubmissionItem(
                id: image.id,
                name: image.id,
              ),
            )..state = submissionStates[image.id] ?? Progress.none)
        .toList();
  }

  List<SubmissionState> get pendingFiles {
    final reportIds = pendingReports.map((e) => e.item.id).toList();
    final subjectRecordIds =
        pendingSubjectRecords.map((e) => e.item.id).toList();
    final monitoringRecordIds =
        pendingMonitoringRecords.map((e) => e.item.id).toList();

    final allPendingCaseIds =
        reportIds + subjectRecordIds + monitoringRecordIds;

    /// Only files without their parent reports (same case as pending images)
    var files = _fileService.pendingReportFiles
        .where((file) => !allPendingCaseIds.contains(file.reportId));

    return files
        .map((file) => SubmissionState(
              item: SubmissionItem(
                id: file.id,
                name: file.id,
              ),
            )..state = submissionStates[file.id] ?? Progress.none)
        .toList();
  }

  @override
  List<ListenableServiceMixin> get listenableServices =>
      [_reportService, _recordService, _imageService, _fileService];

  Future<void> submitAllPendings() async {
    if (isSubmittingAll) {
      return;
    }
    isSubmittingAll = true;
    notifyListeners();
    try {
      for (var report in List<SubmissionState>.of(pendingReports)) {
        await _submitReport(report);
      }
      for (var record in List<SubmissionState>.of(pendingSubjectRecords)) {
        await _submitSubjectRecord(record);
      }
      for (var record in List<SubmissionState>.of(pendingMonitoringRecords)) {
        await _submitMonitoringRecord(record);
      }
      for (var image in List<SubmissionState>.of(pendingImages)) {
        await _submitImage(image);
      }
      for (var file in List<SubmissionState>.of(pendingFiles)) {
        await _submitFile(file);
      }
    } finally {
      isSubmittingAll = false;
      notifyListeners();
    }
  }

  _submitReport(SubmissionState state) async {
    var item = state.item;
    submissionStates[item.id] = Progress.pending;
    notifyListeners();

    var report = _reportService.pendingReports
        .firstWhere((report) => report.id == item.id);
    var result = await _reportService.submit(report);

    if (result is ReportSubmitSuccess) {
      _logger.i("resubmit report success");
      submissionStates[item.id] = Progress.complete;
      notifyListeners();
    }
    if (result is ReportSubmitPending) {
      _logger.e("resubmit report fail");
      submissionStates[item.id] = Progress.fail;
      notifyListeners();
    }
  }

  _submitSubjectRecord(SubmissionState state) async {
    var item = state.item;
    submissionStates[item.id] = Progress.pending;
    notifyListeners();

    var record = _recordService.pendingSubjectRecords
        .firstWhere((record) => record.id == item.id);
    var result = await _recordService.submitSubjectRecord(record);

    if (result is SubjectRecordSubmitSuccess) {
      _logger.i("resubmit subject record success");
      submissionStates[item.id] = Progress.complete;
      notifyListeners();
    }
    if (result is SubjectRecordSubmitPending) {
      _logger.e("resubmit subject record fail");
      submissionStates[item.id] = Progress.fail;
      notifyListeners();
    }
  }

  _submitMonitoringRecord(SubmissionState state) async {
    var item = state.item;
    submissionStates[item.id] = Progress.pending;
    notifyListeners();

    var record = _recordService.pendingMonitoringRecords
        .firstWhere((record) => record.id == item.id);
    var result = await _recordService.submitMonitoringRecord(record);

    if (result is MonitoringRecordSubmitSuccess) {
      _logger.i("resubmit monitoring record success");
      submissionStates[item.id] = Progress.complete;
      notifyListeners();
    }
    if (result is MonitoringRecordSubmitPending) {
      _logger.e("resubmit monitoring record fail");
      submissionStates[item.id] = Progress.fail;
      notifyListeners();
    }
  }

  _submitImage(SubmissionState state) async {
    var item = state.item;
    submissionStates[item.id] = Progress.pending;
    notifyListeners();

    var record = _imageService.pendingImages
        .firstWhere((record) => record.id == item.id);
    var result = await _imageService.submit(record);

    if (result is ImageSubmitSuccess) {
      _logger.i("resubmit report image success");
      submissionStates[item.id] = Progress.complete;
      notifyListeners();
    }
    if (result is ImageSubmitFailure) {
      _logger.e("resubmit report image fail");
      submissionStates[item.id] = Progress.fail;
      notifyListeners();
    }
  }

  _submitFile(SubmissionState state) async {
    var item = state.item;
    submissionStates[item.id] = Progress.pending;
    notifyListeners();

    var record = _fileService.pendingReportFiles
        .firstWhere((record) => record.id == item.id);
    var result = await _fileService.submit(record);

    if (result is FileSubmitSuccess) {
      _logger.i("resubmit report file success");
      submissionStates[item.id] = Progress.complete;
      notifyListeners();
    }
    if (result is FileSubmitFailure) {
      _logger.e("resubmit report file fail");
      submissionStates[item.id] = Progress.fail;
      notifyListeners();
    }
  }

  Future<void> deletePendingReport(String id) async {
    await _reportService.removePendingReport(id);
    notifyListeners();
  }

  Future<void> deletePendingSubjectRecord(String id) async {
    await _recordService.removePendingSubjectRecord(id);
    notifyListeners();
  }

  Future<void> deletePendingMonitoringRecord(String id) async {
    await _recordService.removePendingMonitoringRecord(id);
    notifyListeners();
  }

  Future<void> deletePendingImage(String id) async {
    await _imageService.removePendingImage(id);
    notifyListeners();
  }

  Future<void> deletePendingFile(String id) async {
    await _fileService.removePendingFile(id);
    notifyListeners();
  }

  get isEmpty {
    return _reportService.pendingReports.isEmpty &&
        _recordService.pendingSubjectRecords.isEmpty &&
        _recordService.pendingMonitoringRecords.isEmpty &&
        _imageService.pendingImages.isEmpty &&
        _fileService.pendingReportFiles.isEmpty;
  }
}

enum Progress {
  none,
  pending,
  complete,
  fail,
}

class SubmissionState {
  final SubmissionItem item;
  Progress state = Progress.none;

  SubmissionState({
    required this.item,
  });
}

class SubmissionItem {
  final String id;
  final String name;
  final DateTime? date;

  SubmissionItem({
    required this.id,
    required this.name,
    this.date,
  });
}
