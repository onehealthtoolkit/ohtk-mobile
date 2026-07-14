import 'dart:typed_data';

import 'package:podd_app/models/entities/pending_media_parent_type.dart';

class ReportImage {
  final String id;
  final String reportId;
  final Uint8List image;
  final String parentType;
  final String? remoteParentId;

  ReportImage(
    this.id,
    this.reportId,
    this.image, {
    this.parentType = PendingMediaParentType.incidentReport,
    this.remoteParentId,
  });

  ReportImage.fromMap(Map map)
      : id = map['id'],
        reportId = map['reportId'],
        image = map['image'],
        parentType =
            map['parent_type'] ?? PendingMediaParentType.incidentReport,
        remoteParentId = map['remote_parent_id'];

  String get effectiveParentId => remoteParentId ?? reportId;

  ReportImage withRemoteParent({
    required String parentType,
    required String remoteParentId,
  }) {
    return ReportImage(
      id,
      reportId,
      image,
      parentType: parentType,
      remoteParentId: remoteParentId,
    );
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "reportId": reportId,
        "image": image,
        "parent_type": parentType,
        "remote_parent_id": remoteParentId,
      };
}
