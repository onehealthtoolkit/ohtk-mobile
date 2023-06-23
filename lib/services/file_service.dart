import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report_file.dart';
import 'package:podd_app/models/file_submit_result.dart';
import 'package:podd_app/services/api/file_api.dart';
import 'package:podd_app/services/db_service.dart';
import 'package:stacked/stacked.dart';

abstract class IFileService with ListenableServiceMixin {
  List<ReportFile> get pendingReportFiles;

  Future<File> createLocalFileInAppDirectory(
      String reportId, String id, String extension);

  Future<void> removeLocalFileFromAppDirectory(String id);

  Future<void> saveReportFile(ReportFile reportFile);

  Future<ReportFile> getReportFile(String id);

  Future<void> removeReportFile(String id);

  Future<List<ReportFile>> findAllReportFilesByReportId(String reportId);

  Future<void> removeAll();

  Future<void> remove(String reportId);

  Future<FileSubmitResult> submit(ReportFile file);

  Future<FileSubmitResult> submitObservationRecordFile(
      ReportFile file, String recordId);

  Future<void> removeAllPendingFiles();

  Future<void> removePendingFile(String id);
}

class FileService extends IFileService {
  final IDbService _dbService = locator<IDbService>();
  final _fileApi = locator<FileApi>();

  final _pendingReportFiles = ReactiveList<ReportFile>();

  FileService() {
    listenToReactiveValues([_pendingReportFiles]);
    _init();
  }

  _init() async {
    var rows = await _dbService.db.query("report_file");
    rows.map((row) => ReportFile.fromMap(row)).forEach((file) {
      _pendingReportFiles.add(file);
    });
  }

  @override
  List<ReportFile> get pendingReportFiles => _pendingReportFiles;

  @override
  Future<FileSubmitResult> submit(ReportFile file) async {
    var result = await _fileApi.submit(file);
    if (result is FileSubmitSuccess) {
      await removeLocalFileFromAppDirectory(file.id);
      await removeReportFile(file.id);
      _pendingReportFiles.remove(file);
    }
    if (result is FileSubmitFailure) {
      _pendingReportFiles.addIf(
        _pendingReportFiles.indexWhere((element) => element.id == file.id) ==
            -1,
        file,
      );
    }
    return result;
  }

  @override
  Future<FileSubmitResult> submitObservationRecordFile(
      ReportFile file, String recordId) async {
    var result = await _fileApi.submitObservationRecordFile(file, recordId);
    if (result is FileSubmitSuccess) {
      await removeLocalFileFromAppDirectory(file.id);
      await removeReportFile(file.id);
      _pendingReportFiles.remove(file);
    }
    if (result is FileSubmitFailure) {
      _pendingReportFiles.addIf(
        _pendingReportFiles.indexWhere((element) => element.id == file.id) ==
            -1,
        file,
      );
    }
    return result;
  }

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
    var db = _dbService.db;
    await db.insert("report_file", reportFile.toMap());
  }

  @override
  Future<ReportFile> getReportFile(String id) async {
    var db = _dbService.db;
    var results = await db.query(
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
    var db = _dbService.db;
    await db.delete("report_file", where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<List<ReportFile>> findAllReportFilesByReportId(String reportId) async {
    var db = _dbService.db;
    var results = await db.query(
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
    var db = _dbService.db;
    await db.delete("report_file");

    var localPath = await _localFilePath;
    var allReportFolder = File('$localPath/reports');
    await allReportFolder.delete(recursive: true);
  }

  @override
  Future<void> remove(String reportId) async {
    var db = _dbService.db;
    await db
        .delete("report_file", where: "report_id = ?", whereArgs: [reportId]);

    var localPath = await _localFilePath;
    var reportFolder = File('$localPath/reports/$reportId');
    await reportFolder.delete(recursive: true);
  }

  @override
  Future<void> removeAllPendingFiles() async {
    await removeAll();
    _pendingReportFiles.clear();
  }

  @override
  Future<void> removePendingFile(String id) async {
    await removeReportFile(id);
    try {
      var file = _pendingReportFiles.firstWhere((f) => f.id == id);
      _pendingReportFiles.remove(file);
    } catch (e) {
      // not found
    }
  }
}
