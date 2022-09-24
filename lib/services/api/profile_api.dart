import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/models/profile_result.dart';
import 'package:podd_app/services/api/graph_ql_base_api.dart';

class ProfileApi extends GraphQlBaseApi {
  ProfileApi(GraphQLClient client) : super(client);

  Future<ProfileResult> updateProfile(
      {required String id,
      required int authorityId,
      required String email,
      required String firstName,
      required String lastName,
      required String username,
      String? telephone,
      String? role}) async {
    String mutation = r'''
    mutation UserUpdate(
      $id: ID!
      $authorityId: Int!
      $email: String!
      $firstName: String!
      $lastName: String!
      $username: String!
      $telephone: String = null
      $role: String
    ) {
      adminAuthorityUserUpdate(
        id: $id
        authorityId: $authorityId
        email: $email
        firstName: $firstName
        lastName: $lastName
        telephone: $telephone
        username: $username
        role: $role
      ) {
        result {
          __typename
          ... on AdminAuthorityUserUpdateSuccess {
            authorityUser {
              id
              username
              firstName
              lastName
              email
              telephone
              role
              authority {
                id
              }
            }
          }
          ... on AdminAuthorityUserUpdateProblem {
            fields {
              name
              message
            }
            message
          }
        }
      }
    }
    ''';

    try {
      final result = await runGqlMutation(
          mutation: mutation,
          variables: {
            "id": id,
            "authorityId": authorityId,
            "email": email,
            "firstName": firstName,
            "lastName": lastName,
            "username": username,
            "telephone": telephone,
            "role": role,
          },
          parseData: (resp) {
            switch (resp?['result']['__typename']) {
              case "AdminAuthorityUserUpdateSuccess":
                return ProfileSuccess(success: true);
              case "AdminAuthorityUserUpdateProblem":
                {
                  var messages = [];
                  for (final f in resp?['result']['fields']) {
                    messages.add(f["message"]);
                  }
                  return ProfileSuccess(
                      success: false, message: messages.join("\n"));
                }
              default:
                return ProfileSuccess(
                    success: false, message: "Exception unknown.");
            }
          });
      return result;
    } on OperationException catch (e) {
      return ProfileFailure(e);
    }
  }

  Future<ProfileResult> changePassword(
    String newPassword,
  ) async {
    String mutation = r'''
    mutation adminUserChangePassword($newPassword: String!) {
      adminUserChangePassword(newPassword: $newPassword) {
        success
      }
    }
    ''';

    try {
      final result = await runGqlMutation(
          mutation: mutation,
          variables: {
            "newPassword": newPassword,
          },
          parseData: (resp) {
            return ProfileSuccess(
                success: resp?["success"], message: resp?["message"]);
          });
      return result;
    } on OperationException catch (e) {
      return ProfileFailure(e);
    }
  }
}
