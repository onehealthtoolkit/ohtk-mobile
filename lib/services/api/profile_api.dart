import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/models/profile_result.dart';
import 'package:podd_app/services/api/graph_ql_base_api.dart';

class ProfileApi extends GraphQlBaseApi {
  ProfileApi(ResolveGraphqlClient client) : super(client);

  Future<ProfileResult> updateProfile({
    required String firstName,
    required String lastName,
    String? telephone,
  }) async {
    String mutation = r'''
    mutation UserUpdate(
      $firstName: String!,
      $lastName: String!,
      $telephone: String
    ) {
      adminUserUpdateProfile(
        firstName: $firstName,
        lastName: $lastName,
        telephone: $telephone,
      ) {
        success
      }
    }
    ''';

    try {
      final result = await runGqlMutation(
          mutation: mutation,
          variables: {
            "firstName": firstName,
            "lastName": lastName,
            "telephone": telephone,
          },
          parseData: (resp) => ProfileSuccess(success: resp?["success"]));
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
