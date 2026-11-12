import 'dart:io';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/pending_media_parent_type.dart';
import 'package:podd_app/models/entities/report_file.dart';
import 'package:podd_app/models/file_submit_result.dart';
import 'package:podd_app/models/submission_problem.dart';
import 'package:podd_app/services/api/file_api.dart';
import 'package:podd_app/services/db_service.dart';
import 'package:podd_app/services/submission_flights.dart';
import 'package:podd_app/services/submission_session.dart';
import 'package:sqflite/sqflite.dart';
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

  Future<List<ReportFile>> markForRemoteParent({
    required String localParentId,
    required String parentType,
    required String remoteParentId,
  });

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
  }

  init() async {
    var rows = await _dbService.db.query("report_file");
    rows.map((row) => ReportFile.fromMap(row)).forEach((file) {
      _pendingReportFiles.add(file);
    });
  }

  @override
  List<ReportFile> get pendingReportFiles => _pendingReportFiles;

  final _flights = SubmissionFlights<FileSubmitResult>();

  @override
  Future<FileSubmitResult> submit(ReportFile file) =>
      _flights.run(file.id, () => _submitOnce(file));

  Future<FileSubmitResult> _submitOnce(ReportFile file) async {
    FileSubmitResult result;
    try {
      await ensureSubmissionSession();
      result = PendingMediaParentType.isObservation(file.parentType)
          ? await _fileApi.submitObservationRecordFile(
              file,
              file.effectiveParentId,
            )
          : await _fileApi.submit(file);
    } catch (e) {
      final problem = SubmissionProblem.from(e);
      result = FileSubmitFailure(
          e is OperationException
              ? e
              : OperationException(
                  linkException: e is LinkException ? e : null,
                  graphqlErrors: e is LinkException
                      ? []
                      : [GraphQLError(message: problem.message)]),
          problem: problem);
    }
    if (result is FileSubmitSuccess) {
      await removeReportFile(file.id);
      _pendingReportFiles.removeWhere((item) => item.id == file.id);
      // Local cleanup must not turn an acknowledged upload into a retry.
      try {
        final localFile = file.localFile;
        if (localFile != null && await localFile.exists()) {
          await localFile.delete();
        }
      } on FileSystemException {
        // A leftover cache file can be cleaned up independently.
      }
    } else {
      _pendingReportFiles.addIf(
          !_pendingReportFiles.any((item) => item.id == file.id), file);
    }
    return result;
  }

  @override
  Future<FileSubmitResult> submitObservationRecordFile(
      ReportFile file, String recordId) async {
    final updated = file.withRemoteParent(
        parentType: PendingMediaParentType.isObservation(file.parentType)
            ? file.parentType
            : PendingMediaParentType.observationSubject,
        remoteParentId: recordId);
    await saveReportFile(updated);
    return submit(updated);
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
    if (file != null && await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<void> saveReportFile(ReportFile reportFile) async {
    var db = _dbService.db;
    await db.insert(
      "report_file",
      reportFile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    final pendingIndex =
        _pendingReportFiles.indexWhere((file) => file.id == reportFile.id);
    if (pendingIndex != -1) {
      _pendingReportFiles[pendingIndex] = reportFile;
    }
  }

  @override
  Future<List<ReportFile>> markForRemoteParent({
    required String localParentId,
    required String parentType,
    required String remoteParentId,
  }) async {
    final files = await findAllReportFilesByReportId(localParentId);
    for (final file in files) {
      final updated = file.withRemoteParent(
        parentType: parentType,
        remoteParentId: remoteParentId,
      );
      await saveReportFile(updated);
      _pendingReportFiles.addIf(
          !_pendingReportFiles.any((item) => item.id == updated.id), updated);
    }
    return findAllReportFilesByReportId(localParentId);
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
    var allReportFolder = Directory('$localPath/reports');
    if (await allReportFolder.exists()) {
      await allReportFolder.delete(recursive: true);
    }
  }

  @override
  Future<void> remove(String reportId) async {
    var files = await findAllReportFilesByReportId(reportId);
    await Future.forEach(files, (element) async {
      await removePendingFile(element.id);
    });

    var localPath = await _localFilePath;
    var reportFolder = File('$localPath/reports/$reportId');
    try {
      await reportFolder.delete(recursive: true);
    } catch (e) {
      /// path not exist, do nothing
    }
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
