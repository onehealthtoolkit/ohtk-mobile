import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/observation_monitoring_record_submit_result.dart';
import 'package:podd_app/models/observation_subject_submit_result.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:podd_app/services/observation_record_service.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:stacked/stacked.dart';

class ReSubmitViewModel extends ReactiveViewModel {
  late StreamSubscription _connectionChangeStream;

  final _logger = locator<Logger>();
  final IReportService _reportService = locator<IReportService>();
  final IObservationRecordService _recordService =
      locator<IObservationRecordService>();

  final submissionStates = <String, Progress>{};

  bool isOffline = true;

  ReSubmitViewModel() {
    _connectionChangeStream =
        Connectivity().onConnectivityChanged.listen(connectionChanged);
  }

  void connectionChanged(ConnectivityResult result) async {
    if (result != ConnectivityResult.none) {
      try {
        final result = await InternetAddress.lookup("ohtk.org");
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          _logger.i('connected');
          isOffline = false;
        }
      } on SocketException catch (_) {
        _logger.w('not connected: lookup ohtk.org failed');
        isOffline = true;
      }
    } else {
      _logger.w('not connected: no connection');
      isOffline = true;
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

  @override
  List<ReactiveServiceMixin> get reactiveServices =>
      [_reportService, _recordService];

  void submitAllPendings() async {
    for (var report in pendingReports) {
      _submitReport(report);
    }
    for (var record in pendingSubjectRecords) {
      _submitSubjectRecord(record);
    }
    for (var record in pendingMonitoringRecords) {
      _submitMonitoringRecord(record);
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

  get isEmpty {
    return _reportService.pendingReports.isEmpty &&
        _recordService.pendingSubjectRecords.isEmpty &&
        _recordService.pendingMonitoringRecords.isEmpty;
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
  final DateTime date;

  SubmissionItem({
    required this.id,
    required this.name,
    required this.date,
  });
}
