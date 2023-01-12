import 'package:podd_app/models/entities/observation_subject.dart';

class SubjectRecordQueryResult {
  List<ObservationSubjectRecord> data;
  bool hasNextPage;

  SubjectRecordQueryResult(this.data, this.hasNextPage);

  factory SubjectRecordQueryResult.fromJson(Map<String, dynamic> json) {
    return SubjectRecordQueryResult(
      (json["results"] as List)
          .map((item) => ObservationSubjectRecord.fromJson(item))
          .toList(),
      (json["pageInfo"] as Map)["hasNextPage"],
    );
  }
}

class SubjectRecordGetResult {
  ObservationSubjectRecord data;

  SubjectRecordGetResult({
    required this.data,
  });

  factory SubjectRecordGetResult.fromJson(Map<String, dynamic> jsonMap) {
    return SubjectRecordGetResult(
        data: ObservationSubjectRecord.fromJson(jsonMap));
  }
}
