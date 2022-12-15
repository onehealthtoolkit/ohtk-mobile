import 'package:intl/intl.dart';

class ObservationSubjectReport {
  String id;
  String subjectId;
  String reportId;
  Map<String, dynamic>? formData;
  String? description;
  String? imageUrl;
  DateTime incidentDate;
  String reportTypeId;
  String reportTypeName;

  ObservationSubjectReport({
    required this.id,
    required this.subjectId,
    required this.reportId,
    required this.reportTypeId,
    required this.reportTypeName,
    required this.incidentDate,
    this.formData,
    this.description,
    this.imageUrl,
  });

  ObservationSubjectReport.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        reportTypeId = json['reportTypeId'],
        reportTypeName = json['reportTypeName'],
        incidentDate = DateFormat("yyyy-MM-dd").parse(json['incidentDate']),
        subjectId = json['subjectId'],
        reportId = json['reportId'],
        formData = json['formData'],
        description = json['description'],
        imageUrl = json['imageUrl'];
}
