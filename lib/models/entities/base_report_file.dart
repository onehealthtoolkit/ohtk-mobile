class BaseReportFile {
  String id;
  String filePath;
  String fileType;
  String fileUrl;

  BaseReportFile(Map<String, dynamic> json)
      : id = json["id"],
        filePath = json["file"],
        fileType = json["fileType"],
        fileUrl = json["fileUrl"];
}
