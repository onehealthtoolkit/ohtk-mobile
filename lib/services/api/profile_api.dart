import "package:dio/dio.dart" as dio;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:podd_app/models/consent_result.dart';
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

  Future<ConsentSubmitResult> confirmConsent() async {
    const mutation = r'''
      mutation ConfirmConsent {
        confirmConsent {
          ok
        }
      }
    ''';

    try {
      var result = await runGqlMutation<ConsentSubmitResult>(
        mutation: mutation,
        variables: {},
        parseData: (json) {
          return ConsentSubmitSuccess();
        },
      );
      return result;
    } on OperationException catch (e) {
      return ConsentSubmitFailure(e);
    }
  }

  Future<ProfileResult> uploadAvatar(XFile image) async {
    String mutation = r'''
    mutation userUploadAvatar($image: Upload!) {
      adminUserUploadAvatar(image: $image) {
        success
        avatarUrl
      }
    }
    ''';

    var bytes = await image.readAsBytes();
    var file = dio.MultipartFile.fromBytes(
      bytes,
      filename: "test",
    );

    try {
      final result = await runGqlMutation(
          mutation: mutation,
          variables: {
            "image": file,
          },
          parseData: (resp) => ProfileUploadSuccess(
              success: resp?["success"], avatarUrl: resp?["avatarUrl"]));
      return result;
    } on OperationException catch (e) {
      return ProfileFailure(e);
    }
  }
}
