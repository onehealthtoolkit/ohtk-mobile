import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/entities/utils.dart';

class ObservationSubjectMonitoring {
  int id;
  int subjectId;
  int monitoringDefinitionId;
  Map<String, dynamic>? formData;
  String title;
  String description;
  bool isActive;

  List<ObservationReportImage>? images;

  ObservationSubjectMonitoring({
    required this.id,
    required this.subjectId,
    required this.monitoringDefinitionId,
    required this.title,
    required this.description,
    required this.isActive,
    this.formData,
    this.images,
  });

  String? get imageUrl {
    return images != null && images!.isNotEmpty ? images![0].imageUrl : null;
  }

  ObservationSubjectMonitoring.fromJson(Map<String, dynamic> json)
      : id = cvInt(json, (m) => m['id']),
        subjectId = json['subjectId'],
        monitoringDefinitionId = json['monitoringDefinitionId'],
        formData = Map<String, dynamic>.from(json['formData']),
        isActive = json['isActive'],
        title = json['title'],
        description = json['description'],
        images = json["images"] != null
            ? (json["images"] as List)
                .map((image) => ObservationReportImage.fromJson(image))
                .toList()
            : [];
}
