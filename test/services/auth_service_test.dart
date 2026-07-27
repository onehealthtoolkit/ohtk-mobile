import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/login_result.dart';
import 'package:podd_app/models/user_profile.dart';
import 'package:podd_app/services/api/auth_api.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/feature_capability_service.dart';
import 'package:podd_app/services/gql_service.dart';
import 'package:podd_app/services/observation_definition_service.dart';
import 'package:podd_app/services/observation_record_service.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:podd_app/services/report_type_service.dart';
import 'package:podd_app/services/secure_storage_service.dart';
import 'package:stacked/stacked.dart';

/// Minimal unsigned JWT with unix [expSeconds].
String jwtWithExp(int expSeconds) {
  String b64(Map<String, dynamic> map) {
    return base64Url
        .encode(utf8.encode(jsonEncode(map)))
        .replaceAll('=', '');
  }

  return '${b64({'alg': 'none', 'typ': 'JWT'})}.${b64({'exp': expSeconds})}.sig';
}

int _expIn(Duration d) =>
    DateTime.now().toUtc().add(d).millisecondsSinceEpoch ~/ 1000;

int _expAgo(Duration d) =>
    DateTime.now().toUtc().subtract(d).millisecondsSinceEpoch ~/ 1000;

class MemorySecureStorage implements ISecureStorageService {
  final map = <String, String>{};
  Completer<void>? setLoginGate;
  int setLoginSuccessCalls = 0;
  int deleteAllCalls = 0;

  @override
  Future<void> deleteAll() async {
    deleteAllCalls++;
    map.clear();
  }

  @override
  Future<String?> get(String key) async => map[key];

  @override
  Future<void> set(String key, String value) async => map[key] = value;

  @override
  Future<void> setLoginSuccess(AuthSuccess authResult) async {
    setLoginSuccessCalls++;
    if (setLoginGate != null) {
      await setLoginGate!.future;
    }
    await set('token', authResult.token);
    await set('refreshToken', authResult.refreshToken);
    await set('refreshExpiresIn', authResult.refreshExpiresIn.toString());
  }

  @override
  Future<void> setUserProfile(UserProfile profile) async {
    await set('profile', jsonEncode(profile.toJson()));
  }

  @override
  Future<UserProfile?> getUserProfile() async {
    final raw = map['profile'];
    if (raw == null) return null;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}

class FakeAuthApi extends AuthApi {
  FakeAuthApi()
      : super(() => GraphQLClient(
            link: _NoopLink(),
            cache: GraphQLCache(),
          ));

  int refreshCalls = 0;
  final refreshTokensSeen = <String>[];
  AuthResult? refreshResult;
  Object? refreshError;
  Completer<AuthResult>? refreshGate;

  @override
  Future<AuthResult> refreshToken(String refreshToken) async {
    refreshCalls++;
    refreshTokensSeen.add(refreshToken);
    if (refreshGate != null) {
      return refreshGate!.future;
    }
    if (refreshError != null) {
      throw refreshError!;
    }
    return refreshResult ??
        AuthSuccess(
          token: jwtWithExp(_expIn(const Duration(minutes: 30))),
          refreshToken: 'new-refresh',
          refreshExpiresIn: _expIn(const Duration(days: 14)),
        );
  }
}

class _NoopLink extends Link {
  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    return const Stream.empty();
  }
}

class StubFeatureCapabilityService extends Fake
    with ListenableServiceMixin
    implements IFeatureCapabilityService {
  @override
  bool get villageEnabled => false;

  @override
  bool get villageCapabilityKnown => true;

  @override
  Future<void> refresh() async {}

  @override
  void reset() {}
}

class StubReportTypeService extends Fake
    with ListenableServiceMixin
    implements IReportTypeService {
  @override
  Future<void> removeAll() async {}

  @override
  Future<void> sync() async {}

  @override
  bool get isReportTypeSynced => true;

  @override
  resetReportTypeSynced() {}
}

class StubReportService extends Fake
    with ListenableServiceMixin
    implements IReportService {
  @override
  Future<void> removeAllPendingReports() async {}
}

class StubObservationDefinitionService extends Fake
    with ListenableServiceMixin
    implements IObservationDefinitionService {
  @override
  Future<void> removeAll() async {}

  @override
  Future<void> sync() async {}
}

class StubObservationRecordService extends Fake
    with ListenableServiceMixin
    implements IObservationRecordService {
  @override
  Future<void> removeAllPendingRecords() async {}
}

/// Avoids path_provider / Dio init; only clear methods are used by logout.
class StubGqlService extends Fake implements GqlService {
  int clearCookiesCalls = 0;
  int clearCacheCalls = 0;

  @override
  Future<void> clearCookies() async {
    clearCookiesCalls++;
  }

  @override
  Future<void> clearGraphqlCache() async {
    clearCacheCalls++;
  }
}

AuthService buildAuthService({
  required ISecureStorageService storage,
  required FakeAuthApi authApi,
  StubGqlService? gqlService,
}) {
  return AuthService(
    secureStorageService: storage,
    logger: Logger(level: Level.off),
    authApi: authApi,
    featureCapabilityService: StubFeatureCapabilityService(),
    reportTypeService: StubReportTypeService(),
    reportService: StubReportService(),
    gqlService: gqlService ?? StubGqlService(),
    observationDefinitionService: StubObservationDefinitionService(),
    observationRecordService: StubObservationRecordService(),
  );
}

void main() {
  group('AuthTokenFailureMessages', () {
    test('matches classic and long-running refresh expiry strings', () {
      expect(
        AuthTokenFailureMessages.isHardRefreshFailure('Refresh has expired'),
        isTrue,
      );
      expect(
        AuthTokenFailureMessages.isHardRefreshFailure(
            'Refresh token is expired'),
        isTrue,
      );
      expect(
        AuthTokenFailureMessages.isHardRefreshFailure('Invalid refresh token'),
        isTrue,
      );
      expect(
        AuthTokenFailureMessages.isHardRefreshFailure('Signature has expired'),
        isFalse,
      );
    });
  });

  group('AuthService.ensureValidAccessToken', () {
    late MemorySecureStorage storage;
    late FakeAuthApi authApi;
    late StubGqlService gql;
    late AuthService auth;

    setUp(() async {
      await locator.reset();
      locator.registerSingleton<Logger>(Logger(level: Level.off));
      storage = MemorySecureStorage();
      authApi = FakeAuthApi();
      authApi.baseLogger = null;
      gql = StubGqlService();
      auth = buildAuthService(
        storage: storage,
        authApi: authApi,
        gqlService: gql,
      );
    });

    test('returns unauthenticated when no tokens exist without logout side effects',
        () async {
      final result = await auth.ensureValidAccessToken();
      expect(result, EnsureAccessTokenResult.unauthenticated);
      expect(authApi.refreshCalls, 0);
      expect(gql.clearCookiesCalls, 0);
      expect(storage.deleteAllCalls, 0);
    });

    test('returns valid without refresh when access token is outside skew',
        () async {
      final token = jwtWithExp(_expIn(const Duration(minutes: 20)));
      storage.map['token'] = token;
      storage.map['refreshToken'] = 'refresh-1';

      final result = await auth.ensureValidAccessToken();

      expect(result, EnsureAccessTokenResult.valid);
      expect(authApi.refreshCalls, 0);
      expect(auth.accessToken, token);
    });

    test('refreshes when access token is within skew and updates storage',
        () async {
      final expired = jwtWithExp(_expAgo(const Duration(minutes: 1)));
      storage.map['token'] = expired;
      storage.map['refreshToken'] = 'refresh-old';

      final newAccess = jwtWithExp(_expIn(const Duration(minutes: 30)));
      authApi.refreshResult = AuthSuccess(
        token: newAccess,
        refreshToken: 'refresh-new',
        refreshExpiresIn: _expIn(const Duration(days: 14)),
      );

      final result = await auth.ensureValidAccessToken();

      expect(result, EnsureAccessTokenResult.valid);
      expect(authApi.refreshCalls, 1);
      expect(authApi.refreshTokensSeen, ['refresh-old']);
      expect(auth.accessToken, newAccess);
      expect(storage.map['token'], newAccess);
      expect(storage.map['refreshToken'], 'refresh-new');
    });

    test('S1: skips refresh when failedAccessToken is already replaced',
        () async {
      final oldToken = jwtWithExp(_expAgo(const Duration(minutes: 5)));
      final currentToken = jwtWithExp(_expIn(const Duration(minutes: 25)));
      storage.map['token'] = currentToken;
      storage.map['refreshToken'] = 'refresh-1';

      // Rehydrate current token into memory first.
      await auth.ensureValidAccessToken();
      expect(authApi.refreshCalls, 0);

      final result = await auth.ensureValidAccessToken(
        force: true,
        failedAccessToken: oldToken,
      );

      expect(result, EnsureAccessTokenResult.valid);
      expect(authApi.refreshCalls, 0);
      expect(auth.accessToken, currentToken);
    });

    test('single-flight: concurrent ensures share one refresh', () async {
      storage.map['token'] =
          jwtWithExp(_expAgo(const Duration(minutes: 1)));
      storage.map['refreshToken'] = 'refresh-1';

      final gate = Completer<AuthResult>();
      authApi.refreshGate = gate;

      final futures = [
        auth.ensureValidAccessToken(),
        auth.ensureValidAccessToken(force: true),
        auth.ensureValidAccessToken(force: true),
      ];

      // Allow the first refresh call to start and park on the gate.
      await Future<void>.delayed(Duration.zero);
      expect(authApi.refreshCalls, 1);

      final newAccess = jwtWithExp(_expIn(const Duration(minutes: 30)));
      gate.complete(AuthSuccess(
        token: newAccess,
        refreshToken: 'refresh-new',
        refreshExpiresIn: _expIn(const Duration(days: 14)),
      ));

      final results = await Future.wait(futures);

      expect(results, everyElement(EnsureAccessTokenResult.valid));
      expect(authApi.refreshCalls, 1);
      expect(auth.accessToken, newAccess);
    });

    test('S2: network errors are transient and do not clear tokens', () async {
      final expired = jwtWithExp(_expAgo(const Duration(minutes: 1)));
      storage.map['token'] = expired;
      storage.map['refreshToken'] = 'refresh-1';
      authApi.refreshError = Exception('socket hang up');

      final result = await auth.ensureValidAccessToken();

      expect(result, EnsureAccessTokenResult.transientFailure);
      expect(auth.accessToken, expired);
      expect(storage.map['token'], expired);
      expect(storage.map['refreshToken'], 'refresh-1');
      expect(await auth.requestAccessTokenIfExpired(), isFalse);
      expect(gql.clearCookiesCalls, 0);
    });

    test('S2: classic Refresh has expired performs full logout', () async {
      storage.map['token'] =
          jwtWithExp(_expAgo(const Duration(minutes: 1)));
      storage.map['refreshToken'] = 'refresh-1';
      authApi.refreshResult = AuthFailure(
        OperationException(graphqlErrors: [
          const GraphQLError(message: 'Refresh has expired'),
        ]),
      );

      final result = await auth.ensureValidAccessToken();

      expect(result, EnsureAccessTokenResult.unauthenticated);
      expect(auth.accessToken, isNull);
      expect(storage.map, isEmpty);
      expect(gql.clearCookiesCalls, 1);
      expect(gql.clearCacheCalls, 1);
      expect(await auth.requestAccessTokenIfExpired(), isTrue);
    });

    test('S2: long-running Refresh token is expired performs full logout',
        () async {
      storage.map['token'] =
          jwtWithExp(_expAgo(const Duration(minutes: 1)));
      storage.map['refreshToken'] = 'refresh-1';
      authApi.refreshResult = AuthFailure(
        OperationException(graphqlErrors: [
          const GraphQLError(message: 'Refresh token is expired'),
        ]),
      );

      final result = await auth.ensureValidAccessToken();

      expect(result, EnsureAccessTokenResult.unauthenticated);
      expect(auth.accessToken, isNull);
      expect(storage.map, isEmpty);
      expect(gql.clearCookiesCalls, 1);
    });

    test('S2: InvalidRefreshTokenError performs full logout', () async {
      storage.map['token'] =
          jwtWithExp(_expAgo(const Duration(minutes: 1)));
      storage.map['refreshToken'] = 'refresh-1';
      authApi.refreshError =
          InvalidRefreshTokenError(http.RequestOptions(path: '/graphql/'));

      final result = await auth.ensureValidAccessToken();

      expect(result, EnsureAccessTokenResult.unauthenticated);
      expect(auth.accessToken, isNull);
      expect(storage.map, isEmpty);
      expect(gql.clearCookiesCalls, 1);
    });

    test('S3: logout during in-flight refresh prevents token commit',
        () async {
      storage.map['token'] =
          jwtWithExp(_expAgo(const Duration(minutes: 1)));
      storage.map['refreshToken'] = 'refresh-1';

      final gate = Completer<AuthResult>();
      authApi.refreshGate = gate;

      final ensureFuture = auth.ensureValidAccessToken();
      await Future<void>.delayed(Duration.zero);
      expect(authApi.refreshCalls, 1);

      await auth.logout();
      expect(auth.accessToken, isNull);
      expect(storage.map, isEmpty);
      expect(gql.clearCookiesCalls, 1);
      expect(gql.clearCacheCalls, 1);

      gate.complete(AuthSuccess(
        token: jwtWithExp(_expIn(const Duration(minutes: 30))),
        refreshToken: 'should-not-commit',
        refreshExpiresIn: _expIn(const Duration(days: 14)),
      ));

      final result = await ensureFuture;

      expect(result, EnsureAccessTokenResult.transientFailure);
      expect(auth.accessToken, isNull);
      expect(storage.map['token'], isNull);
      expect(storage.map['refreshToken'], isNull);
    });

    test('S3: logout during storage write undoes stale commit', () async {
      storage.map['token'] =
          jwtWithExp(_expAgo(const Duration(minutes: 1)));
      storage.map['refreshToken'] = 'refresh-1';

      final gate = Completer<void>();
      storage.setLoginGate = gate;

      final newAccess = jwtWithExp(_expIn(const Duration(minutes: 30)));
      authApi.refreshResult = AuthSuccess(
        token: newAccess,
        refreshToken: 'stale-refresh',
        refreshExpiresIn: _expIn(const Duration(days: 14)),
      );

      final ensureFuture = auth.ensureValidAccessToken();
      // Let refresh complete and park inside setLoginSuccess.
      await Future<void>.delayed(Duration.zero);
      expect(storage.setLoginSuccessCalls, 1);

      await auth.logout();
      expect(auth.accessToken, isNull);

      gate.complete();
      final result = await ensureFuture;

      expect(result, EnsureAccessTokenResult.transientFailure);
      expect(auth.accessToken, isNull);
      // Stale commit must not resurrect tokens after logout.
      expect(storage.map['token'], isNull);
      expect(storage.map['refreshToken'], isNull);
    });

    test('force refreshes even when access token is still valid', () async {
      final valid = jwtWithExp(_expIn(const Duration(minutes: 20)));
      storage.map['token'] = valid;
      storage.map['refreshToken'] = 'refresh-1';

      final newAccess = jwtWithExp(_expIn(const Duration(minutes: 30)));
      authApi.refreshResult = AuthSuccess(
        token: newAccess,
        refreshToken: 'refresh-2',
        refreshExpiresIn: _expIn(const Duration(days: 14)),
      );

      final result = await auth.ensureValidAccessToken(force: true);

      expect(result, EnsureAccessTokenResult.valid);
      expect(authApi.refreshCalls, 1);
      expect(auth.accessToken, newAccess);
    });

    test('retains previous refresh token when response omits it', () async {
      storage.map['token'] =
          jwtWithExp(_expAgo(const Duration(minutes: 1)));
      storage.map['refreshToken'] = 'refresh-keep';

      final newAccess = jwtWithExp(_expIn(const Duration(minutes: 30)));
      authApi.refreshResult = AuthSuccess(
        token: newAccess,
        refreshToken: '',
        refreshExpiresIn: _expIn(const Duration(days: 14)),
      );

      final result = await auth.ensureValidAccessToken();

      expect(result, EnsureAccessTokenResult.valid);
      expect(storage.map['refreshToken'], 'refresh-keep');
    });

    test('missing refresh token with access token logs out fully', () async {
      storage.map['token'] =
          jwtWithExp(_expAgo(const Duration(minutes: 1)));
      // no refreshToken key

      final result = await auth.ensureValidAccessToken();

      expect(result, EnsureAccessTokenResult.unauthenticated);
      expect(authApi.refreshCalls, 0);
      expect(auth.accessToken, isNull);
      expect(storage.map, isEmpty);
      expect(gql.clearCookiesCalls, 1);
    });

    test('rehydrate does not restore tokens while logout is in progress',
        () async {
      storage.map['token'] =
          jwtWithExp(_expIn(const Duration(minutes: 20)));
      storage.map['refreshToken'] = 'refresh-1';

      // Load into memory.
      await auth.ensureValidAccessToken();
      expect(auth.accessToken, isNotNull);

      // Simulate durable tokens remaining while logout clears memory first
      // by pausing deleteAll is not needed — logout clears then deleteAll.
      // Instead: start logout and ensure concurrent ensure cannot rehydrate
      // from storage that hasn't been wiped yet by injecting a delayed delete.
      final deleteGate = Completer<void>();
      final delayedStorage = _DelayedDeleteStorage(storage, deleteGate);
      final delayedAuth = buildAuthService(
        storage: delayedStorage,
        authApi: authApi,
        gqlService: gql,
      );
      delayedStorage.map['token'] =
          jwtWithExp(_expIn(const Duration(minutes: 20)));
      delayedStorage.map['refreshToken'] = 'refresh-1';
      await delayedAuth.ensureValidAccessToken();

      final logoutFuture = delayedAuth.logout();
      // Let logout clear memory and park on delayed deleteAll.
      await Future<void>.delayed(Duration.zero);
      expect(delayedAuth.accessToken, isNull);
      expect(delayedStorage.map['token'], isNotNull); // not wiped yet

      final ensureDuringLogout = delayedAuth.ensureValidAccessToken();

      deleteGate.complete();
      await logoutFuture;
      final ensureResult = await ensureDuringLogout;

      expect(ensureResult, EnsureAccessTokenResult.unauthenticated);
      expect(delayedAuth.accessToken, isNull);
    });
  });
}

/// Delegates to [inner] but gates [deleteAll] for logout/rehydrate race tests.
class _DelayedDeleteStorage implements ISecureStorageService {
  _DelayedDeleteStorage(this.inner, this.deleteGate);

  final MemorySecureStorage inner;
  final Completer<void> deleteGate;

  Map<String, String> get map => inner.map;

  @override
  Future<void> deleteAll() async {
    await deleteGate.future;
    await inner.deleteAll();
  }

  @override
  Future<String?> get(String key) => inner.get(key);

  @override
  Future<void> set(String key, String value) => inner.set(key, value);

  @override
  Future<void> setLoginSuccess(AuthSuccess info) =>
      inner.setLoginSuccess(info);

  @override
  Future<void> setUserProfile(UserProfile profile) =>
      inner.setUserProfile(profile);

  @override
  Future<UserProfile?> getUserProfile() => inner.getUserProfile();
}
