import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/models/entities/utils.dart';

class ObservationSubject {
  int id;
  int definitionId;
  int? authorityId;
  Map<String, dynamic>? formData;
  String title;
  String description;
  String identity;
  String? imageUrl;
  bool isActive;

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
    this.imageUrl,
    this.monitoringRecords = const [],
  });

  ObservationSubject.fromJson(Map<String, dynamic> json)
      : id = cvInt(json, (m) => m['id']),
        definitionId = cvInt(json, (m) => m['definitionId']),
        isActive = json['isActive'],
        authorityId = json['authorityId'],
        formData = Map<String, dynamic>.from(json['formData']),
        title = json['title'],
        description = json['description'],
        identity = json['identity'],
        imageUrl = json['imageUrl'],
        monitoringRecords = json['monitoringRecords'] != null
            ? (json['monitoringRecords'] as List)
                .map((item) => ObservationSubjectMonitoring.fromJson(item))
                .toList()
            : [];
}
