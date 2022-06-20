import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:podd_app/services/api/image_api.dart';
import 'package:podd_app/services/api/report_api.dart';
import 'package:podd_app/services/db_service.dart';
import 'package:podd_app/services/image_service.dart';

import 'package:stacked/stacked.dart';

abstract class IReportService with ReactiveServiceMixin {
  Future<ReportSubmitResult> submit(Report report);

  List<Report> get pendingReports;

  Future<void> submitAllPendingReport();
}

class ReportService extends IReportService {
  final _reportApi = locator<ReportApi>();
  final _imageApi = locator<ImageApi>();
  final _imageService = locator<IImageService>();
  final _dbService = locator<IDbService>();

  final ReactiveList<Report> _pendingReports = ReactiveList<Report>();

  ReportService() {
    listenToReactiveValues([_pendingReports]);
    _init();
  }

  _init() async {
    var rows = await _dbService.db.query("report");
    rows.map((row) => Report.fromMap(row)).forEach((report) {
      _pendingReports.add(report);
    });
  }

  @override
  submit(Report report) async {
    try {
      var result = await _reportApi.submit(report);

      if (result is ReportSubmitSuccess) {
        await _deleteFromLocalDB(report);

        // submit images
        var images = await _imageService.findByReportId(report.id);
        for (var image in images) {
          _imageApi.submit(image);
        }
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
      submit(report);
    }
  }
}
