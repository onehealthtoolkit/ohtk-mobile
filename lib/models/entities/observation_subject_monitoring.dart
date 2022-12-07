class ObservationSubjectMonitoring {
  String id;
  String definitionId;
  String subjectId;
  String monitoringId;
  Map<String, dynamic>? formData;
  String? title;
  String? description;
  String? imageUrl;

  ObservationSubjectMonitoring({
    required this.id,
    required this.definitionId,
    required this.subjectId,
    required this.monitoringId,
    this.formData,
    this.title,
    this.description,
    this.imageUrl,
  });

  ObservationSubjectMonitoring.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        definitionId = json['definitionId'],
        subjectId = json['subjectId'],
        monitoringId = json['monitoringId'],
        formData = json['formData'],
        title = json['title'],
        description = json['description'],
        imageUrl = json['imageUrl'];
}
