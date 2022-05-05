import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/models/login_result.dart';
import 'package:podd_app/models/user_profile.dart';
import 'package:podd_app/services/api/graph_ql_base_api.dart';

class AuthApi extends GraphQlBaseApi {
  AuthApi(GraphQLClient client) : super(client);

  Future<LoginResult> tokenAuth(String username, String password) async {
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
        parseData: (resp) => LoginSuccess(
          token: resp?['token'],
          refreshToken: resp?['refreshToken'],
          refreshExpiresIn: resp?['refreshExpiresIn'],
        ),
      );
      return result;
    } on OperationException catch (e) {
      return LoginFailure(e);
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
          authorityId
          authorityName
        }
      }
    ''';
    return runGqlQuery(
      query: query,
      typeConverter: (resp) => UserProfile.fromJson(resp),
    );
  }
}
