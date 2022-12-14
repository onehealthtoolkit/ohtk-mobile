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
        imageUrl = json['imageUrl'];
}
