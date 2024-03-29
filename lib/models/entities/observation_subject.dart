import 'package:podd_app/models/entities/base_report_file.dart';
import 'package:podd_app/models/entities/base_report_image.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/models/entities/utils.dart';

class ObservationRecordImage extends BaseReportImage {
  ObservationRecordImage(Map<String, dynamic> json) : super(json);

  factory ObservationRecordImage.fromJson(Map<String, dynamic> json) =>
      ObservationRecordImage(json);
}

class ObservationRecordFile extends BaseReportFile {
  ObservationRecordFile(Map<String, dynamic> json) : super(json);

  factory ObservationRecordFile.fromJson(Map<String, dynamic> json) =>
      ObservationRecordFile(json);
}

class ObservationSubjectRecord {
  String id;
  int definitionId;
  int? authorityId;
  Map<String, dynamic>? formData;
  String? gpsLocation;
  String title;
  String description;
  String identity;
  bool isActive;
  ObservationDefinition? definition;
  List<ObservationRecordImage>? images;
  List<ObservationRecordFile>? files;
  List<ObservationMonitoringRecord> monitoringRecords;

  ObservationSubjectRecord({
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
    this.files,
  });

  String? get imageUrl {
    return images != null && images!.isNotEmpty ? images![0].imageUrl : null;
  }

  ObservationSubjectRecord.fromJson(Map<String, dynamic> json)
      : id = json['id'],
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
                .map((image) => ObservationRecordImage.fromJson(image))
                .toList()
            : [],
        files = json["uploadFiles"] != null
            ? (json["uploadFiles"] as List)
                .map((file) => ObservationRecordFile.fromJson(file))
                .toList()
            : [],
        monitoringRecords = json['monitoringRecords'] != null
            ? (json['monitoringRecords'] as List)
                .map((item) => ObservationMonitoringRecord.fromJson(item))
                .toList()
            : [];
}
