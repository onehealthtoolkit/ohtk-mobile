import 'package:intl/intl.dart';
import 'package:podd_app/models/entities/base_report_file.dart';
import 'package:podd_app/models/entities/base_report_image.dart';

class IncidentReportImage extends BaseReportImage {
  IncidentReportImage(Map<String, dynamic> json) : super(json);

  factory IncidentReportImage.fromJson(Map<String, dynamic> json) =>
      IncidentReportImage(json);
}

class IncidentReportFile extends BaseReportFile {
  IncidentReportFile(Map<String, dynamic> json) : super(json);

  factory IncidentReportFile.fromJson(Map<String, dynamic> json) =>
      IncidentReportFile(json);
}

class IncidentReport {
  String id;
  Map<String, dynamic>? data;
  String description;
  String reportTypeId;
  String reportTypeName;
  bool reportTypeFollowable;
  DateTime incidentDate;
  DateTime createdAt;
  DateTime updatedAt;
  String? gpsLocation;
  List<IncidentReportImage>? images;
  List<IncidentReportFile>? files;
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
    this.files,
    this.caseId,
    this.threadId,
    this.authorityName,
    this.testFlag = false,
    this.reportTypeFollowable = false,
  });

  factory IncidentReport.fromJson(Map<String, dynamic> json) {
    var reportTypeFollowable = false;
    if (json["reportType"] != null) {
      var reportTypeMap = json["reportType"] as Map;
      if (reportTypeMap["isFollowable"] != null) {
        reportTypeFollowable = reportTypeMap["isFollowable"] as bool;
      }
    }
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
      files: json["uploadFiles"] != null
          ? (json["uploadFiles"] as List)
              .map((file) => IncidentReportFile.fromJson(file))
              .toList()
          : [],
      authorityName: json["authorities"] != null
          ? (json["authorities"] as List)
              .map((authority) => authority["name"])
              .join(",")
          : "",
      reportTypeFollowable: reportTypeFollowable,
    );
  }

  String get trimWhitespaceDescription {
    // replace multiple consecutive whitespace or newline with single whitespace
    return description.replaceAll(RegExp(r"\s+"), " ");
  }
}
