import 'dart:convert';

import 'package:intl/intl.dart';

class MonitoringRecord {
  String id;
  Map<String, dynamic> data;
  DateTime recordDate;
  int monitoringDefinitionId;
  String monitoringDefinitionName;
  String subjectId;

  MonitoringRecord({
    required this.id,
    required this.data,
    required this.monitoringDefinitionId,
    required this.monitoringDefinitionName,
    required this.recordDate,
    required this.subjectId,
  });

  MonitoringRecord.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        data = json.decode(map["data"]),
        monitoringDefinitionId = map["monitoring_definition_id"],
        monitoringDefinitionName = map["monitoring_definition_name"],
        recordDate = DateFormat("yyyy-MM-dd").parse(map["record_date"]),
        subjectId = map["subject_id"];

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "data": json.encode(data),
      "monitoring_definition_id": monitoringDefinitionId,
      "monitoring_definition_name": monitoringDefinitionName,
      "record_date": DateFormat("yyyy-MM-dd").format(recordDate),
      "subject_id": subjectId,
    };
  }

  @override
  bool operator ==(Object other) {
    return (other is MonitoringRecord && other.id == id);
  }

  @override
  int get hashCode =>
      Object.hash(id, data, monitoringDefinitionId, subjectId, recordDate);
}
