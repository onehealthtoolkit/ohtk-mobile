import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report_file.dart';
import 'package:podd_app/services/db_service.dart';

abstract class IFileService {
  Future<File> createLocalFileInAppDirectory(
      String reportId, String id, String extension);

  Future<void> removeLocalFileFromAppDirectory(String id);

  Future<void> saveReportFile(ReportFile reportFile);

  Future<ReportFile> getReportFile(String id);

  Future<void> removeReportFile(String id);

  Future<List<ReportFile>> findAllReportFilesByReportId(String reportId);

  Future<void> removeAll();

  Future<void> remove(String reportId);
}

class FileService extends IFileService {
  final IDbService _dbService = locator<IDbService>();

  Future<String> get _localFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  @override
  Future<File> createLocalFileInAppDirectory(
      String reportId, String id, String extension) async {
    final path = await _localFilePath;
    final extStr = extension.isNotEmpty ? ".$extension" : '';
    final f = await File('$path/reports/$reportId/$id$extStr')
        .create(recursive: true);
    return f;
  }

  @override
  Future<void> removeLocalFileFromAppDirectory(String id) async {
    var reportFile = await getReportFile(id);
    final file = reportFile.localFile;
    if (file != null) {
      await file.delete();
    }
  }

  @override
  Future<void> saveReportFile(ReportFile reportFile) async {
    var _db = _dbService.db;
    await _db.insert("report_file", reportFile.toMap());
  }

  @override
  Future<ReportFile> getReportFile(String id) async {
    var _db = _dbService.db;
    var results = await _db.query(
      'report_file',
      where: "id = ?",
      whereArgs: [
        id,
      ],
    );
    if (results.isNotEmpty) {
      return ReportFile.fromMap(results[0]);
    }
    throw "File not found";
  }

  @override
  Future<void> removeReportFile(String id) async {
    var _db = _dbService.db;
    await _db.delete("report_file", where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<List<ReportFile>> findAllReportFilesByReportId(String reportId) async {
    var _db = _dbService.db;
    var results = await _db.query(
      'report_file',
      where: "report_id = ?",
      whereArgs: [
        reportId,
      ],
    );
    return results.map((row) => ReportFile.fromMap(row)).toList();
  }

  @override
  Future<void> removeAll() async {
    var _db = _dbService.db;
    await _db.delete("report_file");

    var localPath = await _localFilePath;
    var allReportFolder = File('$localPath/reports');
    await allReportFolder.delete(recursive: true);
  }

  @override
  Future<void> remove(String reportId) async {
    var _db = _dbService.db;
    await _db
        .delete("report_file", where: "report_id = ?", whereArgs: [reportId]);

    var localPath = await _localFilePath;
    var reportFolder = File('$localPath/reports/$reportId');
    await reportFolder.delete(recursive: true);
  }
}
