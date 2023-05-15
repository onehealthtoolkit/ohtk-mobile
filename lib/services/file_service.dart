import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report_file.dart';
import 'package:podd_app/services/db_service.dart';

abstract class IFileService {
  Future<ReportFile> newFile(String id, String reportId, String name,
      String extension, Uint8List bytes, String? mimeType);

  Future<void> saveFile(ReportFile reportFile);

  Future<ReportFile> getFile(String id);

  Future<void> removeFile(String id);

  Future<List<ReportFile>> findByReportId(String reportId);

  Future<void> removeAll();

  Future<void> remove(String reportId);
}

class FileService extends IFileService {
  final IDbService _dbService = locator<IDbService>();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _createLocalFile(
      String reportId, String id, String extension) async {
    final path = await _localPath;
    final extStr = extension.isNotEmpty ? ".$extension" : '';
    final f = await File('$path/reports/$reportId/$id$extStr')
        .create(recursive: true);
    return f;
  }

  @override
  Future<ReportFile> newFile(
    String id,
    String reportId,
    String name,
    String extension,
    Uint8List bytes,
    String? mimeType,
  ) async {
    final file = await _createLocalFile(reportId, id, extension);
    await file.writeAsBytes(bytes);

    return ReportFile(id, reportId, name, file.path, extension, mimeType ?? '');
  }

  @override
  Future<void> saveFile(ReportFile reportFile) async {
    var _db = _dbService.db;
    await _db.insert("report_file", reportFile.toMap());
  }

  @override
  Future<ReportFile> getFile(String id) async {
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
  Future<void> removeFile(String id) async {
    var reportFile = await getFile(id);
    final file = reportFile.localFile;
    if (file != null) {
      await file.delete();
    }
    var _db = _dbService.db;
    await _db.delete("report_file", where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<List<ReportFile>> findByReportId(String reportId) async {
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

    var localPath = await _localPath;
    var allReportFolder = File('$localPath/reports');
    await allReportFolder.delete(recursive: true);
  }

  @override
  Future<void> remove(String reportId) async {
    var _db = _dbService.db;
    await _db
        .delete("report_file", where: "report_id = ?", whereArgs: [reportId]);

    var localPath = await _localPath;
    var reportFolder = File('$localPath/reports/$reportId');
    await reportFolder.delete(recursive: true);
  }
}
