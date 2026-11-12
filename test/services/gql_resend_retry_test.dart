import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/config_service.dart';
import 'package:podd_app/services/gql_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestAdapter implements dio.HttpClientAdapter {
  int cancellations = 0;
  final Future<dio.ResponseBody> Function(dio.RequestOptions, List<int>)
      respond;
  RequestAdapter(this.respond);
  @override
  Future<dio.ResponseBody> fetch(dio.RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    cancelFuture?.then((_) {
      cancellations++;
    });
    final bytes =
        await requestStream?.expand((chunk) => chunk).toList() ?? <int>[];
    return respond(options, bytes);
  }

  @override
  void close({bool force = false}) {}
}

class RetryAuth extends Fake implements IAuthService {
  String token = 'expired-access';
  int refreshes = 0;
  String? failedToken;
  Future<void> Function()? refresh;
  @override
  String? get accessToken => token;
  @override
  Future<EnsureAccessTokenResult> ensureValidAccessToken(
      {bool force = false, String? failedAccessToken}) async {
    refreshes++;
    failedToken = failedAccessToken;
    await refresh?.call();
    token = 'new-access';
    return EnsureAccessTokenResult.valid;
  }
}

dio.ResponseBody jsonReply(Map<String, dynamic> body) =>
    dio.ResponseBody.fromString(jsonEncode(body), 200, headers: {
      dio.Headers.contentTypeHeader: ['application/json']
    });
final expired = {
  'errors': [
    {'message': 'Signature has expired'}
  ]
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    await locator.reset();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() async {
    await locator.reset();
  });

  Future<GqlService> service(RequestAdapter adapter,
      {Duration? deadline}) async {
    final transport = dio.Dio()..httpClientAdapter = adapter;
    final gqlService = GqlService(
        dio: transport,
        cache: GraphQLCache(),
        cookieJar: CookieJar(),
        configService: ConfigService(),
        requestTimeout: deadline ?? const Duration(seconds: 90));
    await gqlService.init();
    return gqlService;
  }

  test(
      'real interceptor refreshes once and clones finalized multipart with fresh cookies',
      () async {
    final jar = CookieJar();
    final uri = Uri.parse(ConfigService().graphqlEndpoint);
    await jar.saveFromResponse(uri, [Cookie('JWT', 'old-cookie')..path = '/']);
    final auth = RetryAuth()
      ..refresh = () async {
        await jar
            .saveFromResponse(uri, [Cookie('JWT', 'new-cookie')..path = '/']);
      };
    locator.registerSingleton<IAuthService>(auth);
    final bodies = <String>[];
    final cookies = <String>[];
    final options = <dio.RequestOptions>[];
    final transport = dio.Dio()
      ..httpClientAdapter = RequestAdapter((request, bytes) async {
        bodies.add(utf8.decode(bytes));
        cookies.add(request.headers['cookie'].toString());
        options.add(request);
        return jsonReply(bodies.length == 1
            ? expired
            : {
                'data': {
                  'submitImage': {'id': 'image-1'}
                }
              });
      });
    final gqlService = GqlService(
        dio: transport,
        cache: GraphQLCache(),
        cookieJar: jar,
        configService: ConfigService());
    await gqlService.init();
    final result =
        await gqlService.resolveClientFunction().mutate(MutationOptions(
              fetchPolicy: FetchPolicy.noCache,
              document: gql(
                  r'mutation upload($image: Upload!) { submitImage(image: $image) { id } }'),
              variables: {
                'image': dio.MultipartFile.fromBytes(
                    utf8.encode('attachment-payload'),
                    filename: 'photo.jpg')
              },
            ));
    expect(result.hasException, false, reason: result.exception?.toString());
    expect(result.data!['submitImage']['id'], 'image-1');
    expect(bodies, hasLength(2));
    for (final body in bodies) {
      expect(body, contains('attachment-payload'));
    }
    expect(identical(options[0].data, options[1].data), false);
    expect(cookies[0], contains('old-cookie'));
    expect(cookies[1], contains('new-cookie'));
    expect(cookies[1], isNot(contains('old-cookie')));
    expect(auth.refreshes, 1);
    expect(auth.failedToken, 'expired-access');
  });

  test('second expiry cannot cause an unbounded refresh loop', () async {
    final auth = RetryAuth();
    locator.registerSingleton<IAuthService>(auth);
    int requests = 0;
    final gqlService = await service(RequestAdapter((_, __) async {
      requests++;
      return jsonReply(expired);
    }));
    final result = await gqlService.resolveClientFunction().mutate(
        MutationOptions(
            fetchPolicy: FetchPolicy.noCache,
            document: gql('mutation send { submit { id } }')));
    expect(result.hasException, true);
    expect(requests, 2);
    expect(auth.refreshes, 1);
  });

  test('refresh exceptions complete the interceptor with an error', () async {
    locator.registerSingleton<IAuthService>(RetryAuth()
      ..refresh = () async {
        throw const SocketException('offline');
      });
    final gqlService =
        await service(RequestAdapter((_, __) async => jsonReply(expired)));
    final result = await gqlService
        .resolveClientFunction()
        .mutate(MutationOptions(
            fetchPolicy: FetchPolicy.noCache,
            document: gql('mutation send { submit { id } }')))
        .timeout(const Duration(seconds: 2));
    expect(result.hasException, true);
  });

  test('bootstrap expiry is returned to auth without recursive refresh',
      () async {
    final auth = RetryAuth();
    locator.registerSingleton<IAuthService>(auth);
    int calls = 0;
    final gqlService = await service(RequestAdapter((_, __) async {
      calls++;
      return jsonReply(expired);
    }));
    await gqlService.resolveClientFunction().mutate(MutationOptions(
        fetchPolicy: FetchPolicy.noCache,
        document: gql('mutation refreshToken { refreshToken { token } }')));
    expect(calls, 1);
    expect(auth.refreshes, 0);
  });

  test(
      'a real Dio reply after five seconds succeeds within the configured deadline',
      () async {
    final gqlService = await service(RequestAdapter((_, __) async {
      await Future<void>.delayed(const Duration(milliseconds: 5200));
      return jsonReply({
        'data': {
          'submit': {'id': 'confirmed'}
        }
      });
    }));
    final result = await gqlService.resolveClientFunction().mutate(
        MutationOptions(
            fetchPolicy: FetchPolicy.noCache,
            document: gql('mutation send { submit { id } }')));
    expect(result.hasException, false, reason: result.exception?.toString());
    expect(result.data!['submit']['id'], 'confirmed');
  });
  test(
      'auth bootstrap can complete while the auth singleton is still initializing',
      () async {
    final gate = Completer<IAuthService>();
    locator.registerSingletonAsync<IAuthService>(() => gate.future);
    final gqlService = await service(RequestAdapter((_, __) async => jsonReply({
          'errors': [
            {'message': 'Refresh token is expired'}
          ]
        })));
    final result = await gqlService
        .resolveClientFunction()
        .mutate(MutationOptions(
            fetchPolicy: FetchPolicy.noCache,
            document: gql('mutation refreshToken { refreshToken { token } }')))
        .timeout(const Duration(seconds: 2));
    expect(result.exception!.graphqlErrors.single.message,
        'Refresh token is expired');
    gate.complete(RetryAuth());
    await locator.allReady();
  });
  test('malformed GraphQL errors cannot leave a response interceptor hanging',
      () async {
    locator.registerSingleton<IAuthService>(RetryAuth());
    final gqlService = await service(RequestAdapter((_, __) async => jsonReply({
          'errors': [
            {'message': null},
            'unexpected'
          ]
        })));
    final result = await gqlService
        .resolveClientFunction()
        .mutate(MutationOptions(
            fetchPolicy: FetchPolicy.noCache,
            document: gql('mutation send { submit { id } }')))
        .timeout(const Duration(seconds: 2));
    expect(result.hasException, true);
  });
  test(
      'real Dio deadline cancels transport and ignores a late adapter response',
      () async {
    final adapter = RequestAdapter((_, __) async {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      return jsonReply({
        'data': {
          'submit': {'id': 'late'}
        }
      });
    });
    final gqlService =
        await service(adapter, deadline: const Duration(milliseconds: 30));
    final lateErrors = <Object>[];
    final done = Completer<void>();
    runZonedGuarded(() async {
      try {
        final result = await gqlService.resolveClientFunction().mutate(
            MutationOptions(
                fetchPolicy: FetchPolicy.noCache,
                document: gql('mutation send { submit { id } }')));
        expect(result.hasException, true);
        await Future<void>.delayed(const Duration(milliseconds: 180));
        done.complete();
      } catch (e, stack) {
        done.completeError(e, stack);
      }
    }, (error, _) {
      lateErrors.add(error);
    });
    await done.future;
    expect(adapter.cancellations, 1);
    expect(lateErrors, isEmpty);
  });
}
