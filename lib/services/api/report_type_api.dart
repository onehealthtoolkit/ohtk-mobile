import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/models/entities/category.dart';
import 'package:podd_app/models/entities/report_type.dart';

import 'graph_ql_base_api.dart';

class ReportTypeApi extends GraphQlBaseApi {
  ReportTypeApi(GraphQLClient client) : super(client);

  Future<ReportTypeSyncOutputType> syncReportTypes(
      List<ReportTypeSyncInputType> data) async {
    const query = r'''
      query SyncReportTypes($data: [ReportTypeSyncInputType!]!) {
        syncReportTypes(data: $data) {
          updatedList {
            id
            name
            definition
            followupDefinition
            updatedAt
            ordering
            category {
              id
            }
          }
          removedList {
            id            
          }
          categoryList {
            id
            name
            icon
            ordering
          }
        }
      }
    ''';
    final result = await runGqlQuery<ReportTypeSyncOutputType>(
      query: query,
      fetchPolicy: FetchPolicy.noCache,
      variables: {
        'data': data
            .map((e) => {
                  'id': e.id,
                  'updatedAt': e.updatedAt.toIso8601String(),
                })
            .toList()
      },
      typeConverter: (resp) {
        return ReportTypeSyncOutputType(
          updatedList: (resp['updatedList'] as List)
              .map((e) => ReportType.fromJson(e))
              .toList(),
          removedList: (resp['removedList'] as List)
              .map((e) => ReportType.fromJson(e))
              .toList(),
          categoryList: (resp['categoryList'] as List)
              .map((e) => Category.fromJson(e))
              .toList(),
        );
      },
    );
    return result;
  }
}

class ReportTypeSyncInputType {
  final String id;
  final DateTime updatedAt;

  ReportTypeSyncInputType({
    required this.id,
    required this.updatedAt,
  });
}

class ReportTypeSyncOutputType {
  List<ReportType> updatedList;
  List<ReportType> removedList;
  List<Category> categoryList;

  ReportTypeSyncOutputType({
    required this.updatedList,
    required this.removedList,
    required this.categoryList,
  });
}
