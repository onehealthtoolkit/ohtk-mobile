class BaseReportImage {
  String id;
  String filePath;
  String thumbnailPath;
  String imageUrl;

  BaseReportImage(Map<String, dynamic> json)
      : id = json["id"],
        filePath = json["file"],
        thumbnailPath = json["thumbnail"],
        imageUrl = json["imageUrl"];
}
