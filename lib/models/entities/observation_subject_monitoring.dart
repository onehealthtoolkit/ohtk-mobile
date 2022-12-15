class ObservationSubjectMonitoring {
  String id;
  int subjectId;
  int monitoringDefinitionId;
  Map<String, dynamic>? formData;
  String title;
  String description;
  String? imageUrl;
  bool isActive;

  ObservationSubjectMonitoring({
    required this.id,
    required this.subjectId,
    required this.monitoringDefinitionId,
    required this.title,
    required this.description,
    required this.isActive,
    this.formData,
    this.imageUrl,
  });

  ObservationSubjectMonitoring.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        subjectId = json['subjectId'],
        monitoringDefinitionId = json['monitoringDefinitionId'],
        formData = Map<String, dynamic>.from(json['formData']),
        isActive = json['isActive'],
        title = json['title'],
        description = json['description'],
        imageUrl = json['imageUrl'];
}
