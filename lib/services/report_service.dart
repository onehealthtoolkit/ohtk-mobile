import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/models/entities/report.dart';
import 'package:podd_app/models/image_submit_result.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:podd_app/services/api/image_api.dart';
import 'package:podd_app/services/api/report_api.dart';
import 'package:podd_app/services/db_service.dart';
import 'package:podd_app/services/image_service.dart';

import 'package:stacked/stacked.dart';

abstract class IReportService with ReactiveServiceMixin {
  final _logger = locator<Logger>();

  Future<ReportSubmitResult> submit(Report report);

  List<Report> get pendingReports;

  List<IncidentReport> get incidentReports;

  Future<void> submitAllPendingReport();

  Future<void> fetchIncidents(bool resetFlag);

  Future<void> removeAllPendingReports();

  Future<void> removePendingReport(String id);
}

class ReportService extends IReportService {
  final _reportApi = locator<ReportApi>();
  final _imageApi = locator<ImageApi>();
  final _imageService = locator<IImageService>();
  final _dbService = locator<IDbService>();

  final ReactiveList<Report> _pendingReports = ReactiveList<Report>();
  final ReactiveList<IncidentReport> _incidents =
      ReactiveList<IncidentReport>();
  bool hasMoreIncidentReports = false;
  int currentIncidentReportNextOffset = 0;
  int incidentReportLimit = 20;

  ReportService() {
    listenToReactiveValues([_pendingReports, _incidents]);
    _init();
  }

  _init() async {
    var rows = await _dbService.db.query("report");
    rows.map((row) => Report.fromMap(row)).forEach((report) {
      _pendingReports.add(report);
    });
    fetchIncidents(true);
  }

  @override
  fetchIncidents(bool resetFlag) async {
    if (resetFlag) {
      currentIncidentReportNextOffset = 0;
    }
    var result = await _reportApi.fetchIncidentReports(
      offset: currentIncidentReportNextOffset,
      limit: incidentReportLimit,
    );
    if (resetFlag) {
      _incidents.clear();
    }
    _incidents.addAll(result.data);
    hasMoreIncidentReports = result.hasNextPage;
    currentIncidentReportNextOffset =
        currentIncidentReportNextOffset + incidentReportLimit;
  }

  @override
  submit(Report report) async {
    try {
      var result = await _reportApi.submit(report);

      if (result is ReportSubmitSuccess) {
        await _deleteFromLocalDB(report);
        result.incidentReport.images = List.of([]);

        // submit images
        var localImages = await _imageService.findByReportId(report.id);
        for (var img in localImages) {
          var submitImageResult = await _imageApi.submit(img);
          if (submitImageResult is ImageSubmitSuccess) {
            result.incidentReport.images!.add(submitImageResult.image);
          }
        }

        _incidents.insert(0, result.incidentReport);
      }

      if (result is ReportSubmitFailure) {
        _saveToLocalDB(report);
        return ReportSubmitPending();
      }
      return result;
    } on LinkException catch (_e) {
      _saveToLocalDB(report);
      return ReportSubmitPending();
    }
  }

  Future<bool> _isReportInLocalDB(String id) async {
    var _db = _dbService.db;
    var results = await _db.query(
      'report',
      where: 'id = ?',
      whereArgs: [
        id,
      ],
    );
    return results.isNotEmpty;
  }

  _deleteFromLocalDB(Report report) async {
    var _db = _dbService.db;
    _db.delete(
      "report",
      where: "id = ?",
      whereArgs: [report.id],
    );

    _pendingReports.remove(report);
  }

  _saveToLocalDB(Report report) async {
    var _db = _dbService.db;
    var isInDB = await _isReportInLocalDB(report.id);
    if (isInDB) {
      _db.update(
        "report",
        report.toMap(),
        where: "id = ?",
        whereArgs: [
          report.id,
        ],
      );
    } else {
      _db.insert("report", report.toMap());
      _pendingReports.add(report);
    }
  }

  @override
  List<Report> get pendingReports => _pendingReports;

  @override
  Future<void> submitAllPendingReport() async {
    for (var report in _pendingReports) {
      try {
        submit(report);
      } catch (e) {
        _logger.e(e);
      }
    }
  }

  @override
  List<IncidentReport> get incidentReports => _incidents;

  @override
  Future<void> removeAllPendingReports() async {
    var _db = _dbService.db;
    await _db.delete("report");

    _pendingReports.clear();

    await _imageService.removeAll();
  }

  @override
  Future<void> removePendingReport(String id) async {
    var _db = _dbService.db;
    await _db.delete("report", where: "id = ?", whereArgs: [id]);
    await _imageService.remove(id);
    _pendingReports.removeWhere((r) => r.id == id);
  }
}
