import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/models/configuration_result.dart';
import 'package:podd_app/models/entities/configuration.dart';
import 'package:podd_app/services/api/graph_ql_base_api.dart';

class ConfigurationApi extends GraphQlBaseApi {
  ConfigurationApi(ResolveGraphqlClient client) : super(client);

  Future<ConfigurationQueryResult> getConfigurations() async {
    const query = r'''
      query configurations {
        configurations {
          key
          value    
        }
      }
    ''';
    final result = await runGqlListQuery<Configuration>(
      query: query,
      variables: {},
      fetchPolicy: FetchPolicy.networkOnly,
      typeConverter: (resp) => Configuration.fromJson(resp),
    );

    return ConfigurationQueryResult(result);
  }
}
