import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/models/inviation_code_result.dart';
import 'package:podd_app/models/login_result.dart';
import 'package:podd_app/models/register_result.dart';
import 'package:podd_app/models/village.dart';
import 'package:podd_app/services/api/graph_ql_base_api.dart';

class RegisterApi extends GraphQlBaseApi {
  RegisterApi(ResolveGraphqlClient client) : super(client);

  Future<InvitationCodeResult> checkInvitationCode(String code) async {
    const query = r'''
        query CheckCode($code: String!) {
          checkInvitationCode(code: $code) {
            code
            generatedUsername
            generatedEmail
            authority {
              code
              name
            }
            villages {
              id
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
        fetchPolicy: FetchPolicy.networkOnly,
        typeConverter: (resp) {
          return InvitationCodeSuccess(
            resp['authority']['name'],
            resp['generatedUsername'],
            resp['generatedEmail'],
            (resp['villages'] as List? ?? const [])
                .map((village) => Village.fromJson(village))
                .toList(),
          );
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
    String? address,
    String? gender,
    int? age,
    bool consent = false,
  }) async {
    String mutation = r'''
      mutation UserRegister(
        $email: String = "",
        $firstName: String!,
        $invitationCode: String!,
        $lastName: String!,
        $telephone: String = null,
        $address: String = null,
        $username: String!,
        $gender: String = null,
        $age: Int = null,
        $consent: Boolean = false
      ) {
        authorityUserRegister(
          email: $email, 
          firstName: $firstName,
          invitationCode: $invitationCode,
          lastName: $lastName,
          telephone: $telephone,
          address: $address,
          username: $username,
          gender: $gender,
          age: $age,
          consent: $consent
        ) {
          me {
            id
            username
            firstName
            lastName
            authorityName
            gender
            age
            consent
          },
          refreshToken,
          token
        }
      }
    ''';

    try {
      final result = await runGqlMutation(
        mutation: mutation,
        variables: {
          "email": (email == null || email.trim().isEmpty) ? "" : email.trim(),
          "firstName": firstName,
          "invitationCode": invitationCode,
          "lastName": lastName,
          "telephone": phone,
          "address": address,
          "username": username,
          "gender": gender,
          "age": age,
          "consent": consent,
        },
        parseData: (resp) => RegisterSuccess(
          loginSuccess: AuthSuccess(
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
    } on OperationException catch (e) {
      return RegisterFailure(e);
    }
  }
}
