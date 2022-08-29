import 'package:intl/intl.dart';

class IncidentReportImage {
  String id;
  String filePath;
  String thumbnailPath;

  IncidentReportImage(
      {required this.id, required this.filePath, required this.thumbnailPath});

  factory IncidentReportImage.fromJson(Map<String, dynamic> json) =>
      IncidentReportImage(
          id: json["id"],
          filePath: json["file"],
          thumbnailPath: json["thumbnail"]);
}

class IncidentReport {
  String id;
  Map<String, dynamic>? data;
  String description;
  String reportTypeId;
  String reportTypeName;
  DateTime incidentDate;
  DateTime createdAt;
  DateTime updatedAt;
  String? gpsLocation;
  List<IncidentReportImage>? images;
  String? caseId;
  int? threadId;

  IncidentReport({
    required this.id,
    this.data,
    required this.description,
    required this.reportTypeId,
    required this.reportTypeName,
    required this.incidentDate,
    required this.createdAt,
    required this.updatedAt,
    this.gpsLocation,
    this.images,
    this.caseId,
    this.threadId,
  });

  factory IncidentReport.fromJson(Map<String, dynamic> json) {
    return IncidentReport(
      id: json["id"],
      description: json["rendererData"],
      reportTypeId: (json["reportType"] as Map)["id"],
      reportTypeName: (json["reportType"] as Map)["name"],
      incidentDate: DateFormat("yyyy-MM-dd").parse(json["incidentDate"]),
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      gpsLocation: json["gpsLocation"],
      data: json["data"],
      caseId: json["caseId"],
      threadId: json["threadId"],
      images: json["images"] != null
          ? (json["images"] as List)
              .map((image) => IncidentReportImage.fromJson(image))
              .toList()
          : [],
    );
  }
}
