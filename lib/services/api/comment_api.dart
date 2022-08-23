import 'dart:typed_data';

import "package:dio/dio.dart" as dio;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/models/comment_result.dart';
import 'package:podd_app/models/entities/comment.dart';
import 'package:podd_app/services/api/graph_ql_base_api.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class CommentApi extends GraphQlBaseApi {
  CommentApi(GraphQLClient client) : super(client);

  Future<CommentQueryResult> fetchComments(int threadId) async {
    const query = r'''
      query QueryComments($threadId: ID!) {
        comments(threadId: $threadId) {
          id
          body
          threadId
          attachments {
            id
            file
            thumbnail
            createdAt
          }
          createdAt
          createdBy {
            id
            username
            firstName
            lastName
            avatarUrl
          }
        }
      }
    ''';
    final result = await runGqlListQuery(
      query: query,
      variables: {"threadId": threadId},
      fetchPolicy: FetchPolicy.networkOnly,
      typeConverter: (resp) => Comment.fromJson(resp),
    );

    return CommentQueryResult(result);
  }

  Future<CommentSubmitResult> submit(
    String body,
    int threadId,
    List<Uint8List> attachments,
  ) async {
    const mutation = r'''
      mutation MutationCommentCreate(
        $body: String!
        $threadId: Int!
        $files: [Upload]
      ) {
        commentCreate(body: $body, threadId: $threadId, files: $files) {
          result {
            __typename
            ... on CommentCreateSuccess {
              id
              body
              threadId
              attachments {
                id
                file
                thumbnail
                createdAt
              }
              createdAt
              createdBy {
                id
                username
                firstName
                lastName
                avatarUrl
              }
            }
            ... on CommentCreateProblem {
              message
              fields {
                name
                message
              }
            }
          }
        }
      }
    ''';

    var files = [];
    for (var attachment in attachments) {
      var file = dio.MultipartFile.fromBytes(
        attachment,
        filename: _uuid.v4(),
      );
      files.add(file);
    }

    try {
      var result = await runGqlMutation<CommentSubmitResult>(
        mutation: mutation,
        variables: {
          "body": body,
          "threadId": threadId,
          "files": files,
        },
        parseData: (json) {
          if (json!["result"]["__typename"] == "CommentCreateSuccess") {
            var comment = Comment.fromJson(json['result']);
            return CommentSubmitSuccess(comment: comment);
          }
          return CommentSubmitProblem(message: "invalid");
        },
      );
      return result;
    } on OperationException catch (e) {
      return CommentSubmitFailure(e);
    }
  }
}
