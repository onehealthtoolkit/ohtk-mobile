import 'package:podd_app/models/entities/base_report_image.dart';
import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/models/entities/utils.dart';

class ObservationReportImage extends BaseReportImage {
  ObservationReportImage(Map<String, dynamic> json) : super(json);

  factory ObservationReportImage.fromJson(Map<String, dynamic> json) =>
      ObservationReportImage(json);
}

class ObservationSubject {
  int id;
  int definitionId;
  int? authorityId;
  Map<String, dynamic>? formData;
  String? gpsLocation;
  String title;
  String description;
  String identity;
  bool isActive;
  List<ObservationReportImage>? images;

  List<ObservationSubjectMonitoring> monitoringRecords;

  ObservationSubject({
    required this.id,
    required this.definitionId,
    required this.isActive,
    required this.title,
    required this.description,
    required this.identity,
    this.authorityId,
    this.formData,
    this.gpsLocation,
    this.monitoringRecords = const [],
    this.images,
  });

  String? get imageUrl {
    return images != null && images!.isNotEmpty ? images![0].imageUrl : null;
  }

  ObservationSubject.fromJson(Map<String, dynamic> json)
      : id = cvInt(json, (m) => m['id']),
        definitionId = cvInt(json, (m) => m['definitionId']),
        isActive = json['isActive'],
        authorityId = json['authorityId'],
        formData = Map<String, dynamic>.from(json['formData']),
        title = json['title'],
        description = json['description'],
        identity = json['identity'],
        gpsLocation = json['gpsLocation'],
        images = json["images"] != null
            ? (json["images"] as List)
                .map((image) => ObservationReportImage.fromJson(image))
                .toList()
            : [],
        monitoringRecords = json['monitoringRecords'] != null
            ? (json['monitoringRecords'] as List)
                .map((item) => ObservationSubjectMonitoring.fromJson(item))
                .toList()
            : [];
}
