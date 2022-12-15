import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/models/entities/observation_report_subject.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/observation_definition_query_result.dart';
import 'package:podd_app/models/observation_subject_query_result.dart';
import 'package:podd_app/models/observation_subject_submit_result.dart';
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

  Future<ObservationSubjectQueryResult> fetchObservationSubjects(
    int definitionId, {
    limit = 20,
    offset = 0,
  }) async {
    const query = r'''
      query observationSubjects($limit: Int, $offset: Int, $definitionId: String) {
        observationSubjects(limit: $limit, offset: $offset, definition_Id_In: [$definitionId]) {
          totalCount
          results { 
            id
            definitionId
            title
            description
            identity
            isActive
            formData
            monitoringRecords {
              id
              title
              description
              monitoringDefinitionId
              subjectId
              isActive
              formData
            }
          }
          pageInfo {
            hasNextPage
          }
        }          
      }
    ''';
    return runGqlQuery<ObservationSubjectQueryResult>(
      query: query,
      variables: {
        "limit": limit,
        "offset": offset,
        "definitionId": definitionId.toString()
      },
      fetchPolicy: FetchPolicy.cacheAndNetwork,
      typeConverter: (resp) => ObservationSubjectQueryResult.fromJson(resp),
    );
  }

  Future<ObservationSubjectGetResult> getObservationSubject(int id) {
    const query = r'''
      query observationSubject($id: ID!) {
        observationSubject(id: $id) {
          id
          definitionId
          title
          description
          definitionId
          identity
          isActive
          formData
          monitoringRecords {
            id
            title
            description
            monitoringDefinitionId
            subjectId
            isActive
            formData
          }
        }
      }
    ''';
    return runGqlQuery(
        query: query,
        variables: {"id": id},
        typeConverter: (resp) => ObservationSubjectGetResult.fromJson(resp));
  }

  Future<ObservationSubjectSubmitResult> submit(
      ObservationReportSubject report) async {
    const mutation = r'''
      mutation submitObservationSubject($data: GenericScalar!, $definitionId: Int!) {
        submitObservationSubject(data: $data, definitionId: $definitionId) {
          result {
            id
            definitionId
            title
            description
            identity
            isActive
            formData
            monitoringRecords {
              id
              title
              description
            }
          }  	
        }
      }
    ''';
    try {
      var result = await runGqlMutation<ObservationSubject>(
        mutation: mutation,
        parseData: (json) => ObservationSubject.fromJson(json!["result"]),
        variables: {
          "definitionId": report.definitionId,
          "data": report.data,
        },
      );

      return ObservationSubjectSubmitSuccess(result);
    } on OperationException catch (e) {
      return ObservationSubjectSubmitFailure(e);
    }
  }
}
