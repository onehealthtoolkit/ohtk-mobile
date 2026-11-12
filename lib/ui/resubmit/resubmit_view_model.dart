import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/file_submit_result.dart';
import 'package:podd_app/models/image_submit_result.dart';
import 'package:podd_app/models/observation_monitoring_record_submit_result.dart';
import 'package:podd_app/models/observation_subject_submit_result.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:podd_app/models/submission_problem.dart';
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
  final submissionProblems = <String, SubmissionProblem>{};

  bool isOffline = true;
  bool isSubmittingAll = false;
  bool _stopBatch = false;
  SubmissionProblem? batchProblem;

  ReSubmitViewModel() {
    _connectionChangeStream =
        Connectivity().onConnectivityChanged.listen(connectionChanged);
    Connectivity().checkConnectivity().then(connectionChanged,
        onError: (Object error) {
      _logger.w('Cannot check network interface');
    });
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
            )
              ..state = submissionStates[report.id] ?? Progress.none
              ..problem = submissionProblems[report.id])
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
            )
              ..state = submissionStates[record.id] ?? Progress.none
              ..problem = submissionProblems[record.id])
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
            )
              ..state = submissionStates[record.id] ?? Progress.none
              ..problem = submissionProblems[record.id])
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
            )
              ..state = submissionStates[image.id] ?? Progress.none
              ..problem = submissionProblems[image.id])
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
            )
              ..state = submissionStates[file.id] ?? Progress.none
              ..problem = submissionProblems[file.id])
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
    _stopBatch = false;
    batchProblem = null;
    notifyListeners();
    try {
      // Snapshot every category before draining: an attachment attempted with
      // its parent must not immediately be retried a second time in this batch.
      final reports = List<SubmissionState>.of(pendingReports);
      final subjects = List<SubmissionState>.of(pendingSubjectRecords);
      final monitorings = List<SubmissionState>.of(pendingMonitoringRecords);
      final images = List<SubmissionState>.of(pendingImages);
      final files = List<SubmissionState>.of(pendingFiles);
      for (final item in reports) {
        await _submitReport(item);
      }
      for (final item in subjects) {
        await _submitSubjectRecord(item);
      }
      for (final item in monitorings) {
        await _submitMonitoringRecord(item);
      }
      for (final item in images) {
        await _submitImage(item);
      }
      for (final item in files) {
        await _submitFile(item);
      }
    } finally {
      isSubmittingAll = false;
      notifyListeners();
    }
  }

  void _pauseIfSessionUnavailable(SubmissionProblem problem) {
    if (problem.kind == SubmissionProblemKind.authentication ||
        problem.kind == SubmissionProblemKind.connection) {
      _stopBatch = true;
      batchProblem = problem;
    }
  }

  void _rememberAttachments(Map<String, SubmissionProblem> problems) {
    for (final entry in problems.entries) {
      submissionProblems[entry.key] = entry.value;
      submissionStates[entry.key] = Progress.fail;
      _pauseIfSessionUnavailable(entry.value);
    }
  }

  Future<void> _attempt(
      SubmissionState state, Future<SubmissionProblem?> Function() send) async {
    if (_stopBatch) return;
    final id = state.item.id;
    submissionStates[id] = Progress.pending;
    submissionProblems.remove(id);
    notifyListeners();
    try {
      final problem = await send();
      if (problem != null) {
        submissionProblems[id] = problem;
        _pauseIfSessionUnavailable(problem);
      }
      submissionStates[id] =
          problem == null ? Progress.complete : Progress.fail;
    } catch (e) {
      final problem = SubmissionProblem.from(e);
      submissionProblems[id] = problem;
      _pauseIfSessionUnavailable(problem);
      submissionStates[id] = Progress.fail;
    } finally {
      notifyListeners();
    }
  }

  Future<void> _submitReport(SubmissionState state) =>
      _attempt(state, () async {
        final records = _reportService.pendingReports
            .where((item) => item.id == state.item.id);
        if (records.isEmpty) return null;
        final result = await _reportService.submit(records.first);
        if (result is ReportSubmitSuccess) {
          _rememberAttachments(result.attachmentProblems);
          return null;
        }
        if (result is ReportSubmitFailure) {
          return result.problem ?? SubmissionProblem.from(result.exception);
        }
        if (result is ReportSubmitPending) {
          return result.problem ??
              SubmissionProblem.from(StateError('No acknowledgement'));
        }
        return SubmissionProblem.from(
            StateError('Unexpected submission result'));
      });

  Future<void> _submitSubjectRecord(SubmissionState state) =>
      _attempt(state, () async {
        final records = _recordService.pendingSubjectRecords
            .where((item) => item.id == state.item.id);
        if (records.isEmpty) return null;
        final result = await _recordService.submitSubjectRecord(records.first);
        if (result is SubjectRecordSubmitSuccess) {
          _rememberAttachments(result.attachmentProblems);
          return null;
        }
        if (result is SubjectRecordSubmitFailure) {
          return result.problem ?? SubmissionProblem.from(result.exception);
        }
        if (result is SubjectRecordSubmitPending) {
          return result.problem ??
              SubmissionProblem.from(StateError('No acknowledgement'));
        }
        return SubmissionProblem.from(
            StateError('Unexpected submission result'));
      });

  Future<void> _submitMonitoringRecord(SubmissionState state) =>
      _attempt(state, () async {
        final records = _recordService.pendingMonitoringRecords
            .where((item) => item.id == state.item.id);
        if (records.isEmpty) return null;
        final result =
            await _recordService.submitMonitoringRecord(records.first);
        if (result is MonitoringRecordSubmitSuccess) {
          _rememberAttachments(result.attachmentProblems);
          return null;
        }
        if (result is MonitoringRecordSubmitFailure) {
          return result.problem ?? SubmissionProblem.from(result.exception);
        }
        if (result is MonitoringRecordSubmitPending) {
          return result.problem ??
              SubmissionProblem.from(StateError('No acknowledgement'));
        }
        return SubmissionProblem.from(
            StateError('Unexpected submission result'));
      });

  Future<void> _submitImage(SubmissionState state) => _attempt(state, () async {
        final records = _imageService.pendingImages
            .where((item) => item.id == state.item.id);
        if (records.isEmpty) return null;
        final result = await _imageService.submit(records.first);
        if (result is ImageSubmitSuccess) return null;
        if (result is ImageSubmitFailure) {
          return result.problem ?? SubmissionProblem.from(result.exception);
        }
        return SubmissionProblem.from(
            StateError('Unexpected submission result'));
      });

  Future<void> _submitFile(SubmissionState state) => _attempt(state, () async {
        final records = _fileService.pendingReportFiles
            .where((item) => item.id == state.item.id);
        if (records.isEmpty) return null;
        final result = await _fileService.submit(records.first);
        if (result is FileSubmitSuccess) return null;
        if (result is FileSubmitFailure) {
          return result.problem ?? SubmissionProblem.from(result.exception);
        }
        return SubmissionProblem.from(
            StateError('Unexpected submission result'));
      });

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
  SubmissionProblem? problem;

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
