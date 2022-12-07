class ObservationSubject {
  String id;
  String definitionId;
  int authorityId;
  Map<String, dynamic>? formData;
  String? title;
  String? description;
  String? identity;
  String? imageUrl;

  ObservationSubject({
    required this.id,
    required this.definitionId,
    required this.authorityId,
    this.formData,
    this.title,
    this.description,
    this.identity,
    this.imageUrl,
  });

  ObservationSubject.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        definitionId = json['definitionId'],
        authorityId = json['authorityId'],
        formData = json['formData'],
        title = json['title'],
        description = json['description'],
        identity = json['identity'],
        imageUrl = json['imageUrl'];
}
