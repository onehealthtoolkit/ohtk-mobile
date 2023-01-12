import 'dart:convert';

import 'package:intl/intl.dart';

class SubjectRecord {
  String id;
  Map<String, dynamic> data;
  int definitionId;
  DateTime? incidentDate;
  String? gpsLocation;

  SubjectRecord({
    required this.id,
    required this.data,
    required this.definitionId,
    this.incidentDate,
    this.gpsLocation,
  });

  SubjectRecord.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        data = json.decode(map["data"]),
        definitionId = map["definition_id"],
        incidentDate = map["incident_date"] != null
            ? DateFormat("yyyy-MM-dd").parse(map["incident_date"])
            : null,
        gpsLocation = map["gps_location"];

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "data": json.encode(data),
      "definition_id": definitionId,
      "incident_date": incidentDate != null
          ? DateFormat("yyyy-MM-dd").format(incidentDate!)
          : null,
      "gps_location": gpsLocation,
    };
  }

  @override
  bool operator ==(Object other) {
    return (other is SubjectRecord && other.id == id);
  }

  @override
  int get hashCode => Object.hash(id, data, definitionId, incidentDate);
}
