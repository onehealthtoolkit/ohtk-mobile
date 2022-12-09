import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/models/observation_definition_query_result.dart';
import 'package:podd_app/services/api/graph_ql_base_api.dart';

class ObservationApi extends GraphQlBaseApi {
  ObservationApi(ResolveGraphqlClient client) : super(client);

  Future<ObservationDefinitionQueryResult> fetchObservationDefinitions({
    limit = 20,
    offset = 0,
  }) async {
    const query = r'''
      query adminObservationDefinitionQuery($limit: Int, $offset: Int) {
        adminObservationDefinitionQuery(limit: $limit, offset: $offset) {
          totalCount
          results { 
            id
            name
            description
            isActive
            registerFormDefinition
            monitoringDefinitions {
              id
              name
              description
              isActive
              formDefinition
            }
          }
          pageInfo {
            hasNextPage
          }
        }          
      }
    ''';
    return runGqlQuery<ObservationDefinitionQueryResult>(
      query: query,
      variables: {
        "limit": limit,
        "offset": offset,
      },
      fetchPolicy: FetchPolicy.cacheAndNetwork,
      typeConverter: (resp) => ObservationDefinitionQueryResult.fromJson(resp),
    );
  }
}
