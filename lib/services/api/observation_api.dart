import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/models/entities/observation_report_monitoring_record.dart';
import 'package:podd_app/models/entities/observation_report_subject.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/models/observation_definition_query_result.dart';
import 'package:podd_app/models/observation_monitoring_record_submit_result.dart';
import 'package:podd_app/models/observation_subject_monitoring_query_result.dart';
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

  Future<SubjectRecordQueryResult> fetchSubjectRecords(
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
            images {
              id
              file
              thumbnail
              imageUrl
            }
          }
          pageInfo {
            hasNextPage
          }
        }          
      }
    ''';
    return runGqlQuery<SubjectRecordQueryResult>(
      query: query,
      variables: {
        "limit": limit,
        "offset": offset,
        "definitionId": definitionId.toString()
      },
      fetchPolicy: FetchPolicy.cacheAndNetwork,
      typeConverter: (resp) => SubjectRecordQueryResult.fromJson(resp),
    );
  }

  Future<SubjectRecordGetResult> getSubjectRecord(String id) {
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
          gpsLocation
          monitoringRecords {
            id
            title
            description
            monitoringDefinitionId
            subjectId
            isActive
            formData
            images {
              id
              file
              thumbnail
              imageUrl
            }
          }
          images {
            id
            file
            thumbnail
            imageUrl
          }
        }
      }
    ''';
    return runGqlQuery(
        query: query,
        variables: {"id": id},
        typeConverter: (resp) => SubjectRecordGetResult.fromJson(resp));
  }

  Future<SubjectRecordSubmitResult> submitSubjectRecord(
      SubjectRecord report) async {
    const mutation = r'''
      mutation submitObservationSubject($data: GenericScalar!, $definitionId: Int!, $gpsLocation: String) {
        submitObservationSubject(data: $data, definitionId: $definitionId, gpsLocation: $gpsLocation) {
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
      var result = await runGqlMutation<ObservationSubjectRecord>(
        mutation: mutation,
        parseData: (json) => ObservationSubjectRecord.fromJson(json!["result"]),
        variables: {
          "definitionId": report.definitionId,
          "data": report.data,
          "gpsLocation": report.gpsLocation,
        },
      );

      return SubjectRecordSubmitSuccess(result);
    } on OperationException catch (e) {
      return SubjectRecordSubmitFailure(e);
    }
  }

  Future<MonitoringRecordSubmitResult> submitMonitoringRecord(
      MonitoringRecord report) async {
    const mutation = r'''
      mutation submitObservationSubjectMonitoring($data: GenericScalar!, $monitoringDefinitionId: Int!, $subjectId: UUID!) {
        submitObservationSubjectMonitoring(data: $data, monitoringDefinitionId: $monitoringDefinitionId, subjectId: $subjectId) {
          result {
            id
            title
            description
            isActive
            formData
            monitoringDefinitionId
            subjectId
          }  	
        }
      }
    ''';
    try {
      var result = await runGqlMutation<ObservationMonitoringRecord>(
        mutation: mutation,
        parseData: (json) =>
            ObservationMonitoringRecord.fromJson(json!["result"]),
        variables: {
          "monitoringDefinitionId": report.monitoringDefinitionId,
          "subjectId": report.subjectId,
          "data": report.data,
        },
      );

      return MonitoringRecordSubmitSuccess(result);
    } on OperationException catch (e) {
      return MonitoringRecordSubmitFailure(e);
    }
  }

  Future<MonitoringRecordQueryResult> fetchMonitoringRecords(
    String subjectId, {
    limit = 100,
    offset = 0,
  }) async {
    const query = r'''
      query observationSubjectMonitoringRecords($limit: Int, $offset: Int, $subjectId: UUID) {
        observationSubjectMonitoringRecords(limit: $limit, offset: $offset, subject_Id_In: [$subjectId]) {
          totalCount
          results { 
            id
            monitoringDefinitionId
            subjectId
            title
            description
            isActive
            formData
            images {
              id
              file
              thumbnail
              imageUrl
            }
          }
          pageInfo {
            hasNextPage
          }
        }          
      }
    ''';
    return runGqlQuery<MonitoringRecordQueryResult>(
      query: query,
      variables: {
        "limit": limit,
        "offset": offset,
        "subjectId": subjectId,
      },
      fetchPolicy: FetchPolicy.cacheAndNetwork,
      typeConverter: (resp) => MonitoringRecordQueryResult.fromJson(resp),
    );
  }

  Future<MonitoringRecordGetResult> getMonitoringRecord(String id) {
    const query = r'''
      query observationSubjectMonitoringRecord($id: ID!) {
        observationSubjectMonitoringRecord(id: $id) {
          id
          monitoringDefinitionId
          subjectId
          title
          description
          isActive
          formData
          images {
              id
              file
              thumbnail
              imageUrl
            }
        }
      }
    ''';
    return runGqlQuery(
        query: query,
        variables: {"id": id},
        typeConverter: (resp) => MonitoringRecordGetResult.fromJson(resp));
  }

  fetchSubjectRecordsInBounded(int definitionId, double topLeftX,
      double topLeftY, double bottomRightX, double bottomRightY) {
    const query = r'''
      query observationSubjectsInBounded($definitionId: Int, $topLeftX: Float, $topLeftY: Float, $bottomRightX: Float, $bottomRightY: Float) {
        observationSubjectsInBounded(definitionId: $definitionId, topLeftX: $topLeftX, topLeftY: $topLeftY, bottomRightX: $bottomRightX, bottomRightY: $bottomRightY) {
          id
          definitionId
          title
          description
          gpsLocation
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
    return runGqlQuery<List<ObservationSubjectRecord>>(
      query: query,
      variables: {
        "definitionId": definitionId,
        "topLeftX": topLeftX,
        "topLeftY": topLeftY,
        "bottomRightX": bottomRightX,
        "bottomRightY": bottomRightY,
      },
      fetchPolicy: FetchPolicy.networkOnly,
      typeConverter: (resp) {
        return (resp["observationSubjectsInBounded"] as List)
            .map((e) => ObservationSubjectRecord.fromJson(e))
            .toList();
      },
    );
  }
}
