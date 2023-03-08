import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/models/fcm_register_result.dart';
import 'package:podd_app/models/user_message_query_result.dart';
import 'package:podd_app/services/api/graph_ql_base_api.dart';

class NotificationApi extends GraphQlBaseApi {
  NotificationApi(ResolveGraphqlClient client) : super(client);

  Future<FcmTokenRegisterResult> registerFcmToken(
      String userId, String token) async {
    const mutation = r'''
      mutation registerFcm($userId: String!, $token: String!) {
        registerFcmToken(userId: $userId, token: $token) {
          success
        }
      }  
    ''';

    try {
      final result = await runGqlMutation<bool>(
          mutation: mutation,
          parseData: (json) => json!["success"],
          variables: {
            "userId": userId,
            "token": token,
          });
      return FcmTokenRegisterSuccess(result);
    } on OperationException catch (e) {
      return FcmTokenRegisterFailure(e);
    }
  }

  Future<UserMessageQueryResult> fetchMyMessages({
    limit = 20,
    offset = 0,
  }) async {
    const query = r'''
      query MyMessages($limit: Int, $offset: Int) {
        myMessages(limit: $limit, offset: $offset) {
          pageInfo {
            hasNextPage
          }
          results {
            id
            message {
              id
              title
              body
              image              
            }
            user {
              id
              username
              firstName
              lastName
            }
            isSeen
            createdAt
          }                
        }
      }
    ''';
    return runGqlQuery<UserMessageQueryResult>(
      query: query,
      variables: {
        "limit": limit,
        "offset": offset,
      },
      fetchPolicy: FetchPolicy.cacheAndNetwork,
      typeConverter: (resp) => UserMessageQueryResult.fromJson(resp),
    );
  }

  Future<UserMessageGetResult> getMyMessage(String id) async {
    const query = r'''
      query MyMessage($id: String!) {
        myMessage(id: $id) {
          id
          message {
            id
            title
            body
            image
          }
          isSeen
          createdAt
        }                
      }
    ''';
    return runGqlQuery<UserMessageGetResult>(
      query: query,
      variables: {
        "id": id,
      },
      typeConverter: (resp) => UserMessageGetResult.fromJson(resp),
    );
  }
}
