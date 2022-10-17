import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/models/entities/followup_report.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/models/entities/report.dart';
import 'package:podd_app/models/followup_result.dart';
import 'package:podd_app/models/followup_submit_result.dart';
import 'package:podd_app/models/incident_report_query_result.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:podd_app/services/api/graph_ql_base_api.dart';
import 'package:intl/intl.dart';

class ReportApi extends GraphQlBaseApi {
  ReportApi(ResolveGraphqlClient client) : super(client);

  Future<ReportSubmitResult> submit(Report report) async {
    const mutation = r'''
      mutation submitIncidentReport(
        $data: GenericScalar!,
        $reportId: UUID!,
        $reportTypeId: UUID!,
        $incidentDate: Date!,
        $gpsLocation: String,
        $incidentInAuthority: Boolean
      ){
        submitIncidentReport(data: $data, reportId: $reportId, 
          reportTypeId: $reportTypeId, incidentDate: $incidentDate, 
          gpsLocation: $gpsLocation, incidentInAuthority: $incidentInAuthority) {
          result {
            id
            incidentDate
            gpsLocation
            rendererData
            createdAt
            updatedAt
            reportType {
              id
              name
            }
            reportedBy {
              id
              username        
            }
          }
        }
      }
    ''';
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    try {
      var result = await runGqlMutation<IncidentReport>(
        mutation: mutation,
        parseData: (json) => IncidentReport.fromJson(json!["result"]),
        variables: {
          "reportId": report.id,
          "reportTypeId": report.reportTypeId,
          "data": report.data,
          "incidentDate": formatter.format(report.incidentDate),
          "gpsLocation": report.gpsLocation,
          "incidentInAuthority": report.incidentInAuthority,
        },
      );

      return ReportSubmitSuccess(result);
    } on OperationException catch (e) {
      return ReportSubmitFailure(e);
    }
  }

  Future<ReportSubmitResult> submitZeroReport() async {
    const mutation = r'''
      mutation submitZeroReport {
        submitZeroReport {
          id
        }
      }
    ''';
    try {
      var result = await runGqlMutation<String>(
        mutation: mutation,
        parseData: (json) => json!["id"],
        variables: {},
      );

      return ZeroReportSubmitSuccess(result);
    } on OperationException catch (e) {
      return ZeroReportSubmitFailure(e);
    }
  }

  Future<IncidentReportQueryResult> fetchIncidentReports({
    limit = 20,
    offset = 0,
  }) async {
    const query = r'''
      query incidentReports($limit: Int, $offset: Int) {
        incidentReports(limit: $limit, offset: $offset) {
          pageInfo {
            hasNextPage
          }
          results {
            id
            incidentDate
            gpsLocation
            rendererData
            createdAt
            updatedAt
            reportType {
              id
              name
            }
            reportedBy {
              id
              username        
            } 
            images {
              id
              file 
              imageUrl
              thumbnail
            }    
            caseId  
          }          
        }
      }
    ''';
    return runGqlQuery<IncidentReportQueryResult>(
      query: query,
      variables: {
        "limit": limit,
        "offset": offset,
      },
      fetchPolicy: FetchPolicy.cacheAndNetwork,
      typeConverter: (resp) => IncidentReportQueryResult.fromJson(resp),
    );
  }

  Future<IncidentReportGetResult> getIncidentReport(String id) {
    const query = r'''
      query incidentReport($id: ID!) {
        incidentReport(id: $id) {
          id
          incidentDate
          gpsLocation
          rendererData
          createdAt
          updatedAt
          authorities {
            name
          }
          reportType {
            id
            name
          }
          reportedBy {
            id
            username        
          } 
          images {
            id
            file
            imageUrl 
            thumbnail
          }      
          caseId
          threadId
        }
      }
    ''';
    return runGqlQuery(
        query: query,
        variables: {"id": id},
        typeConverter: (resp) => IncidentReportGetResult.fromJson(resp));
  }

  Future<IncidentReportQueryResult> fetchMyIncidentReports({
    limit = 20,
    offset = 0,
  }) async {
    const query = r'''
      query myIncidentReports($limit: Int, $offset: Int) {
        myIncidentReports(limit: $limit, offset: $offset) {
          pageInfo {
            hasNextPage
          }
          results {
            id
            incidentDate
            gpsLocation
            rendererData
            createdAt
            updatedAt
            reportType {
              id
              name
            }
            reportedBy {
              id
              username        
            } 
            images {
              id
              file 
              imageUrl
              thumbnail
            }    
            caseId  
          }          
        }
      }
    ''';
    return runGqlQuery<IncidentReportQueryResult>(
      query: query,
      variables: {
        "limit": limit,
        "offset": offset,
      },
      fetchPolicy: FetchPolicy.cacheAndNetwork,
      typeConverter: (resp) => IncidentReportQueryResult.fromJson(resp),
    );
  }

  Future<FollowupQueryResult> fetchFollowupReports(String incidentId) async {
    const query = r'''
      query QueryFollowups($incidentId: ID!) {
        followups(incidentId: $incidentId) {
          id
          data
          rendererData
          testFlag
          reportType{
            id
            name
          }
          incident{
            id
          }
          images{
            id
						file
            thumbnail
          }
          reportedBy {
            id
            username
            firstName
            lastName
            avatarUrl
          }
          createdAt
        }
      }
    ''';
    final result = await runGqlListQuery(
      query: query,
      variables: {"incidentId": incidentId},
      fetchPolicy: FetchPolicy.networkOnly,
      typeConverter: (resp) => FollowupReport.fromJson(resp),
    );

    return FollowupQueryResult(result);
  }

  Future<FollowupReportGetResult> getFollowupReport(String id) {
    const query = r'''
      query followupReport($id: ID!) {
        followupReport(id: $id) {
          id
          data
          testFlag
          rendererData
          createdAt
          incident{
            id
          }
          reportType {
            id
            name
          }
          reportedBy {
            id
            username        
          } 
          images {
            id
            file 
            thumbnail
          }   
          reportedBy {
            id
            username
            firstName
            lastName
            avatarUrl
          }   
        }
      }
    ''';
    return runGqlQuery(
        query: query,
        variables: {"id": id},
        typeConverter: (resp) => FollowupReportGetResult.fromJson(resp));
  }

  Future<FollowupSubmitResult> submitFollowup(
    String incidentId,
    String? followupId,
    Map<String, dynamic>? data,
  ) async {
    const mutation = r'''
      mutation submitFollowupReport(
        $data: GenericScalar!,
        $followupId: UUID = null,
        $incidentId: UUID!
      ){
        submitFollowupReport(
          data: $data, 
          followupId: $followupId, 
          incidentId: $incidentId
        ) {
          result {
            id
            rendererData
            testFlag
            createdAt
            reportType {
              id
              name
            }
            incident {
              id
            }
          }
        }
      }
    ''';
    try {
      var result = await runGqlMutation<FollowupReport>(
        mutation: mutation,
        parseData: (json) => FollowupReport.fromJson(json!["result"]),
        variables: {
          "data": data,
          "followupId": followupId,
          "incidentId": incidentId,
        },
      );

      return FollowupSubmitSuccess(result);
    } on OperationException catch (e) {
      return FollowupSubmitFailure(e);
    }
  }
}

class ReportSubmitInputType {}
