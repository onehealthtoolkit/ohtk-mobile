import 'dart:io';

import 'package:podd_app/models/entities/pending_media_parent_type.dart';

class ReportFile {
  final String id;
  final String reportId;
  final String name;
  final String filePath;
  final String fileExtension;
  final String fileType;
  final String parentType;
  final String? remoteParentId;

  ReportFile(
    this.id,
    this.reportId,
    this.name,
    this.filePath,
    this.fileExtension,
    this.fileType, {
    this.parentType = PendingMediaParentType.incidentReport,
    this.remoteParentId,
  });

  File? get localFile {
    File? f;
    try {
      f = File(filePath);
    } catch (e) {
      // file not found
    }
    return f;
  }

  String get idExt => id + (fileExtension.isNotEmpty ? ".$fileExtension" : '');

  String get effectiveParentId => remoteParentId ?? reportId;

  ReportFile.fromMap(Map map)
      : id = map['id'],
        reportId = map['report_id'],
        name = map['name'],
        fileExtension = map['file_extension'],
        filePath = map['file_path'],
        fileType = map['file_type'],
        parentType =
            map['parent_type'] ?? PendingMediaParentType.incidentReport,
        remoteParentId = map['remote_parent_id'];

  ReportFile withRemoteParent({
    required String parentType,
    required String remoteParentId,
  }) {
    return ReportFile(
      id,
      reportId,
      name,
      filePath,
      fileExtension,
      fileType,
      parentType: parentType,
      remoteParentId: remoteParentId,
    );
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "report_id": reportId,
        "name": name,
        "file_extension": fileExtension,
        "file_path": filePath,
        "file_type": fileType,
        "parent_type": parentType,
        "remote_parent_id": remoteParentId,
      };
}
