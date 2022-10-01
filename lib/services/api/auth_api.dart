import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/models/login_result.dart';
import 'package:podd_app/models/user_profile.dart';
import 'package:podd_app/services/api/graph_ql_base_api.dart';

class AuthApi extends GraphQlBaseApi {
  AuthApi(GraphQLClient client) : super(client);

  Future<AuthResult> tokenAuth(String username, String password) async {
    const mutation = r'''
          mutation Login($username: String!, $password: String!) {
            tokenAuth(username: $username, password: $password ) {
              token,
              refreshExpiresIn,
              refreshToken
            }
          }
    ''';
    try {
      final result = await runGqlMutation(
        mutation: mutation,
        variables: {'username': username, 'password': password},
        parseData: (resp) => AuthSuccess(
          token: resp?['token'],
          refreshToken: resp?['refreshToken'],
          refreshExpiresIn: resp?['refreshExpiresIn'],
        ),
      );
      return result;
    } on OperationException catch (e) {
      return AuthFailure(e);
    }
  }

  Future<AuthResult> refreshToken() async {
    const mutation = r'''
          mutation RefreshToken {
            refreshToken {
              token,
              refreshExpiresIn,
              refreshToken
            }
          }
    ''';
    try {
      final result = await runGqlMutation(
        mutation: mutation,
        parseData: (resp) => AuthSuccess(
          token: resp?['token'],
          refreshToken: resp?['refreshToken'],
          refreshExpiresIn: resp?['refreshExpiresIn'],
        ),
      );
      return result;
    } on OperationException catch (e) {
      return AuthFailure(e);
    }
  }

  Future<UserProfile> getUserProfile() async {
    const query = r'''
      query {
        me {
          id
          username
          firstName
          lastName
          telephone
          email
          authorityId
          authorityName
          role
        }
      }
    ''';
    return runGqlQuery(
      query: query,
      typeConverter: (resp) => UserProfile.fromJson(resp),
    );
  }

  Future<AuthResult> verifyLoginQrToken(String token) async {
    const mutation = r'''
      mutation VerifyLoginQrToken($token: String!) {
        verifyLoginQrToken(token: $token) {
          me {
            id
            username
            firstName
            lastName
            authorityId
            authorityName
            role
          }
          token,
          refreshToken
        }
      }
    ''';
    try {
      final result = await runGqlMutation(
        mutation: mutation,
        variables: {"token": token},
        parseData: (resp) => AuthSuccess(
          token: resp?['token'],
          refreshToken: resp?['refreshToken'],
          // save in seconds
          refreshExpiresIn:
              (DateTime.now().millisecondsSinceEpoch / 1000).round() +
                  (14 * 24 * 60 * 60),
        ),
      );
      return result;
    } on OperationException catch (e) {
      return AuthFailure(e);
    }
  }
}
