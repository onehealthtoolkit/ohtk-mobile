import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/models/entities/user.dart';

class FollowupReport {
  String id;
  String description;
  bool testFlag;
  String reportTypeId;
  String reportTypeName;
  String incidentId;
  Map<String, dynamic>? data;
  String? gpsLocation;
  List<IncidentReportImage>? images;
  User? user;

  FollowupReport({
    required this.id,
    required this.description,
    required this.testFlag,
    required this.reportTypeId,
    required this.reportTypeName,
    required this.incidentId,
    this.data,
    this.gpsLocation,
    this.images,
    this.user,
  });

  factory FollowupReport.fromJson(Map<String, dynamic> json) {
    return FollowupReport(
      id: json["id"],
      description: json["rendererData"],
      testFlag: json["testFlag"],
      reportTypeId: (json["reportType"] as Map)["id"],
      reportTypeName: (json["reportType"] as Map)["name"],
      incidentId: (json["incident"] as Map)["id"],
      data: json["data"],
      gpsLocation: json["gpsLocation"],
      images: json["images"] != null
          ? (json["images"] as List)
              .map((image) => IncidentReportImage.fromJson(image))
              .toList()
          : [],
      user:
          json['reportedBy'] != null ? User.fromJson(json['reportedBy']) : null,
    );
  }
}
