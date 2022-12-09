import 'package:podd_app/models/entities/observation_definition.dart';

class ObservationDefinitionQueryResult {
  List<ObservationDefinition> data;
  bool hasNextPage;

  ObservationDefinitionQueryResult(this.data, this.hasNextPage);

  factory ObservationDefinitionQueryResult.fromJson(Map<String, dynamic> json) {
    return ObservationDefinitionQueryResult(
      (json["results"] as List)
          .map((item) => ObservationDefinition.fromJson(item))
          .toList(),
      (json["pageInfo"] as Map)["hasNextPage"],
    );
  }
}

class ObservationDefinitionGetResult {
  ObservationDefinition data;

  ObservationDefinitionGetResult({
    required this.data,
  });

  factory ObservationDefinitionGetResult.fromJson(
      Map<String, dynamic> jsonMap) {
    return ObservationDefinitionGetResult(
        data: ObservationDefinition.fromJson(jsonMap));
  }
}
