import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:podd_app/services/config_service.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:stacked/stacked.dart';

class ReSubmitViewModel extends ReactiveViewModel {
  late StreamSubscription _connectionChangeStream;

  final _logger = locator<Logger>();
  final IReportService _reportService = locator<IReportService>();
  final _configService = locator<ConfigService>();
  final reportStates = <String, Progress>{};

  bool isOffline = true;

  ReSubmitViewModel() {
    _connectionChangeStream =
        Connectivity().onConnectivityChanged.listen(connectionChanged);
  }

  void connectionChanged(ConnectivityResult result) async {
    if (result != ConnectivityResult.none) {
      try {
        final result =
            await InternetAddress.lookup(_configService.serverDomain);
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          _logger.i('connected');
          isOffline = false;
        }
      } on SocketException catch (_) {
        _logger
            .w('not connected: lookup ${_configService.serverDomain} failed');
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

  List<PendingReportState> get pendingReports {
    return _reportService.pendingReports
        .map((report) => PendingReportState(report: report)
          ..state = reportStates[report.id] ?? Progress.none)
        .toList();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_reportService];

  void submitAllPendingReport() {
    for (var report in pendingReports) {
      _submit(report);
    }
  }

  _submit(PendingReportState state) async {
    reportStates[state.report.id] = Progress.pending;
    notifyListeners();

    var result = await _reportService.submit(state.report);

    if (result is ReportSubmitSuccess) {
      _logger.i("resubmit report success");
      reportStates[state.report.id] = Progress.complete;
      notifyListeners();
    }
    if (result is ReportSubmitPending) {
      _logger.e("resubmit report fail");
      reportStates[state.report.id] = Progress.fail;
      notifyListeners();
    }
  }

  Future<void> deletePendingReport(String id) async {
    await _reportService.removePendingReport(id);
    notifyListeners();
  }

  get isEmpty {
    return _reportService.pendingReports.isEmpty;
  }
}

enum Progress {
  none,
  pending,
  complete,
  fail,
}

class PendingReportState {
  final Report report;
  Progress state = Progress.none;

  PendingReportState({
    required this.report,
  });
}
