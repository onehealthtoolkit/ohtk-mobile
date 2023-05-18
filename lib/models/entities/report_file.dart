import 'dart:io';

class ReportFile {
  final String id;
  final String reportId;
  final String name;
  final String filePath;
  final String fileExtension;
  final String fileType;

  ReportFile(
    this.id,
    this.reportId,
    this.name,
    this.filePath,
    this.fileExtension,
    this.fileType,
  );

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

  ReportFile.fromMap(Map map)
      : id = map['id'],
        reportId = map['report_id'],
        name = map['name'],
        fileExtension = map['file_extension'],
        filePath = map['file_path'],
        fileType = map['file_type'];

  Map<String, dynamic> toMap() => {
        "id": id,
        "report_id": reportId,
        "name": name,
        "file_extension": fileExtension,
        "file_path": filePath,
        "file_type": fileType,
      };
}
