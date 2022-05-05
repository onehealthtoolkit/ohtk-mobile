import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/models/inviation_code_result.dart';
import 'package:podd_app/models/login_result.dart';
import 'package:podd_app/models/register_result.dart';
import 'package:podd_app/services/api/graph_ql_base_api.dart';

class RegisterApi extends GraphQlBaseApi {
  RegisterApi(GraphQLClient client) : super(client);

  Future<InvitationCodeResult> checkInvitationCode(String code) async {
    const query = r'''
        query CheckCode($code: String!) {
          checkInvitationCode(code: $code) {
            code
            authority {
              code
              name
            }
          }
        }
    ''';
    try {
      final result = await runGqlQuery<InvitationCodeSuccess>(
        query: query,
        variables: {'code': code},
        typeConverter: (resp) {
          return InvitationCodeSuccess(resp['authority']['name']);
        },
      );
      return result;
    } on OperationException catch (e) {
      return InvitationCodeFailure(e);
    }
  }

  Future<RegisterResult> registerUser({
    required String invitationCode,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) async {
    String mutation = r'''
      mutation UserRegister(
        $email: String!,
        $firstName: String!,
        $invitationCode: String!,
        $lastName: String!,
        $telephone: String = null,
        $username: String!      
      ) {
        authorityUserRegister(
          email: $email, 
          firstName: $firstName,
          invitationCode: $invitationCode,
          lastName: $lastName,
          telephone: $telephone,
          username: $username
        ) {
          me {
            id
            username
            firstName
            lastName
            authorityName
          },
          refreshToken,
          token
        }
      }
    ''';

    final result = await runGqlMutation(
      mutation: mutation,
      variables: {
        "email": email,
        "firstName": firstName,
        "invitationCode": invitationCode,
        "lastName": lastName,
        "telephone": phone,
        "username": username
      },
      parseData: (resp) => RegisterSuccess(
        loginSuccess: LoginSuccess(
          token: resp?['token'],
          refreshToken: resp?['refreshToken'],
          // save in seconds
          refreshExpiresIn:
              (DateTime.now().millisecondsSinceEpoch / 1000).round() +
                  (14 * 24 * 60 * 60),
        ),
      ),
    );

    return result;
  }
}
