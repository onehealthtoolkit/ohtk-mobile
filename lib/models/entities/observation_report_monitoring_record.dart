import 'dart:convert';

class ObservationReportMonitoringRecord {
  String id;
  Map<String, dynamic> data;
  int monitoringDefinitionId;
  int subjectId;

  ObservationReportMonitoringRecord({
    required this.id,
    required this.data,
    required this.monitoringDefinitionId,
    required this.subjectId,
  });

  ObservationReportMonitoringRecord.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        data = json.decode(map["data"]),
        monitoringDefinitionId = map["monitoringDefinition_id"],
        subjectId = map["subject_id"];

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "data": json.encode(data),
      "monitoringDefinition_id": monitoringDefinitionId,
      "subject_id": subjectId,
    };
  }

  @override
  bool operator ==(Object other) {
    return (other is ObservationReportMonitoringRecord && other.id == id);
  }

  @override
  int get hashCode => Object.hash(id, data, monitoringDefinitionId, subjectId);
}
