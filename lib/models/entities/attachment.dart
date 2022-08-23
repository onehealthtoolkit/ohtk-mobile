class Attachment {
  String id;
  DateTime createdAt;
  String filePath;
  String? thumbnailPath;

  Attachment({
    required this.id,
    required this.createdAt,
    required this.filePath,
    this.thumbnailPath,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      filePath: json['file'],
      thumbnailPath: json['thumbnail']);
}
