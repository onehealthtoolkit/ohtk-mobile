import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/login_result.dart';
import 'package:podd_app/models/user_profile.dart';
import 'package:podd_app/services/api/auth_api.dart';

class QueueLink extends Link {
  final List<Map<String, dynamic>> responses;
  final requests = <Request>[];

  QueueLink(this.responses);

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    requests.add(request);
    final data = responses.removeAt(0);
    return Stream.value(Response(data: data, response: {'data': data}));
  }
}

GraphQLClient clientFor(QueueLink link) {
  return GraphQLClient(link: link, cache: GraphQLCache());
}

AuthApi authApiFor(QueueLink link) {
  final api = AuthApi(() => clientFor(link));
  api.baseLogger = null;
  return api;
}

void main() {
  setUpAll(() {
    if (!locator.isRegistered<Logger>()) {
      locator.registerSingleton<Logger>(Logger());
    }
  });

  group('AuthApi GraphQL contract', () {
    test('tokenAuth sends credentials and parses token tuple', () async {
      final link = QueueLink([
        {
          'tokenAuth': {
            'token': 'access-token',
            'refreshToken': 'refresh-token',
            'refreshExpiresIn': 123,
          }
        }
      ]);
      final api = authApiFor(link);

      final result = await api.tokenAuth('alice', 'secret');

      expect(result, isA<AuthSuccess>());
      final success = result as AuthSuccess;
      expect(success.token, 'access-token');
      expect(success.refreshToken, 'refresh-token');
      expect(success.refreshExpiresIn, 123);
      expect(link.requests.single.variables, {
        'username': 'alice',
        'password': 'secret',
      });
    });

    test('refreshToken parses rotated token tuple', () async {
      final link = QueueLink([
        {
          'refreshToken': {
            'token': 'new-access-token',
            'refreshToken': 'new-refresh-token',
            'refreshExpiresIn': 456,
          }
        }
      ]);
      final api = authApiFor(link);

      final result = await api.refreshToken('old-refresh-token');

      expect(result, isA<AuthSuccess>());
      final success = result as AuthSuccess;
      expect(success.token, 'new-access-token');
      expect(success.refreshToken, 'new-refresh-token');
      expect(success.refreshExpiresIn, 456);
      expect(link.requests.single.variables, {
        'refreshToken': 'old-refresh-token',
      });
    });

    test('getUserProfile parses me query response', () async {
      final link = QueueLink([
        {
          '__typename': 'Query',
          'me': {
            '__typename': 'UserNode',
            'id': 42,
            'username': 'alice',
            'firstName': 'Alice',
            'lastName': 'Reporter',
            'telephone': '123',
            'email': 'alice@example.test',
            'address': 'HQ',
            'authorityId': 7,
            'authorityName': 'Authority',
            'role': 'reporter',
            'consent': true,
            'features': <String>[],
            'avatarUrl': null,
          }
        }
      ]);
      final api = authApiFor(link);

      final profile = await api.getUserProfile();

      expect(profile, isA<UserProfile>());
      expect(profile.username, 'alice');
      expect(profile.authorityId, 7);
      expect(profile.assignedVillages, isEmpty);
      expect(
        link.requests.single.operation.document.toString(),
        isNot(contains('assignedVillages')),
      );
    });

    test('getAssignedVillages parses separate village query response',
        () async {
      final link = QueueLink([
        {
          '__typename': 'Query',
          'me': {
            '__typename': 'UserNode',
            'assignedVillages': [
              {
                '__typename': 'VillageType',
                'id': 11,
                'code': 'V001',
                'name': 'Village One',
              }
            ],
          }
        }
      ]);
      final api = authApiFor(link);

      final villages = await api.getAssignedVillages();

      expect(villages, hasLength(1));
      expect(villages.single.displayName, 'V001 - Village One');
    });
  });
}
