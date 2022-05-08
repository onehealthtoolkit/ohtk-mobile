import 'dart:typed_data';

class ReportImage {
  final String id;
  final String reportId;
  final Uint8List image;

  ReportImage(this.id, this.reportId, this.image);

  ReportImage.fromMap(Map map)
      : id = map['id'],
        reportId = map['reportId'],
        image = map['image'];

  Map<String, dynamic> toMap() => {
        "id": id,
        "reportId": reportId,
        "image": image,
      };
}
