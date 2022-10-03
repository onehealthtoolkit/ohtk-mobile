import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/models/forgot_password_result.dart';
import 'package:podd_app/services/api/graph_ql_base_api.dart';

class ForgotPasswordApi extends GraphQlBaseApi {
  ForgotPasswordApi(ResolveGraphqlClient client) : super(client);

  Future<ForgotPasswordResult> resetPasswordRequest(
    String email,
  ) async {
    String mutation = r'''
     mutation ResetPasswordRequest($email: String!) {
      resetPasswordRequest(email: $email) {
        success
      }
    }
    ''';

    try {
      final result = await runGqlMutation(
        mutation: mutation,
        variables: {
          "email": email,
        },
        parseData: (resp) => ForgotPasswordSuccess(success: resp?['success']),
      );
      return result;
    } on OperationException catch (e) {
      return ForgotPasswordFailure(e);
    }
  }
}
