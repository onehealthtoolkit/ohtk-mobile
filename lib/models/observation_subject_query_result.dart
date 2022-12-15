import 'package:podd_app/models/entities/observation_subject.dart';

class ObservationSubjectQueryResult {
  List<ObservationSubject> data;
  bool hasNextPage;

  ObservationSubjectQueryResult(this.data, this.hasNextPage);

  factory ObservationSubjectQueryResult.fromJson(Map<String, dynamic> json) {
    return ObservationSubjectQueryResult(
      (json["results"] as List)
          .map((item) => ObservationSubject.fromJson(item))
          .toList(),
      (json["pageInfo"] as Map)["hasNextPage"],
    );
  }
}

class ObservationSubjectGetResult {
  ObservationSubject data;

  ObservationSubjectGetResult({
    required this.data,
  });

  factory ObservationSubjectGetResult.fromJson(Map<String, dynamic> jsonMap) {
    return ObservationSubjectGetResult(
        data: ObservationSubject.fromJson(jsonMap));
  }
}
