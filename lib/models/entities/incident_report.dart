import 'package:intl/intl.dart';
import 'package:podd_app/models/entities/base_report_image.dart';

class IncidentReportImage extends BaseReportImage {
  IncidentReportImage(Map<String, dynamic> json) : super(json);

  factory IncidentReportImage.fromJson(Map<String, dynamic> json) =>
      IncidentReportImage(json);
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
  String? authorityName;
  bool testFlag;

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
    this.authorityName,
    this.testFlag = false,
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
      testFlag: json["testFlag"] != null ? (json["testFlag"] as bool) : false,
      images: json["images"] != null
          ? (json["images"] as List)
              .map((image) => IncidentReportImage.fromJson(image))
              .toList()
          : [],
      authorityName: json["authorities"] != null
          ? (json["authorities"] as List)
              .map((authority) => authority["name"])
              .join(",")
          : "",
    );
  }

  String get trimWhitespaceDescription {
    // replace multiple consecutive whitespace or newline with single whitespace
    return description.replaceAll(RegExp(r"\s+"), " ");
  }
}
