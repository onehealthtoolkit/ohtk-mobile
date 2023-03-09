import 'package:intl/intl.dart';
import 'dart:convert';

class Report {
  String id;
  Map<String, dynamic> data;
  String reportTypeId;
  DateTime incidentDate;
  String? gpsLocation;
  bool? incidentInAuthority;
  String? reportTypeName;
  bool testFlag;

  Report({
    required this.id,
    required this.data,
    required this.reportTypeId,
    required this.incidentDate,
    required this.testFlag,
    this.gpsLocation,
    this.incidentInAuthority,
    this.reportTypeName,
  });

  Report.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        testFlag = (map["test_flag"] as int) == 1,
        data = json.decode(map["data"]),
        reportTypeId = map["report_type_id"],
        reportTypeName = map["report_type_name"],
        incidentDate = DateFormat("yyyy-MM-dd").parse(map["incident_date"]),
        gpsLocation = map["gps_location"],
        incidentInAuthority = map["incident_in_authority"] == 1;

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "test_flag": testFlag ? 1 : 0,
      "data": json.encode(data),
      "report_type_id": reportTypeId,
      "report_type_name": reportTypeName,
      "incident_date": DateFormat("yyyy-MM-dd").format(incidentDate),
      "gps_location": gpsLocation,
      "incident_in_authority": incidentInAuthority,
    };
  }

  @override
  bool operator ==(Object other) {
    return (other is Report && other.id == id);
  }

  @override
  int get hashCode => Object.hash(id, data, reportTypeId, incidentDate);
}
