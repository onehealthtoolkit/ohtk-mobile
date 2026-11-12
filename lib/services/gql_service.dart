import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart' as http;
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/services/api/graph_ql_base_api.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/bounded_request_link.dart';
import 'package:podd_app/services/config_service.dart';
import 'package:podd_app/services/queue_ownership_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import "package:gql_dio_link/gql_dio_link.dart";

class InvalidRefreshTokenError extends http.DioException {
  InvalidRefreshTokenError(requestOptions)
      : super(requestOptions: requestOptions);
}

class GqlService {
  final backendUrlKey = "backendUrl";

  static const _authRetriedExtraKey = 'authRetried';

  static const _failedAccessTokenKey = 'failedAccessToken';
  final ConfigService _configService;
  final http.Dio _dio;
  final GraphQLCache _cache;
  final Duration requestTimeout;
  CookieJar? _cookieJar;

  GqlService(
      {http.Dio? dio,
      GraphQLCache? cache,
      CookieJar? cookieJar,
      ConfigService? configService,
      this.requestTimeout = const Duration(seconds: 90)})
      : _dio = dio ?? http.Dio(),
        _cache = cache ?? GraphQLCache(store: HiveStore()),
        _cookieJar = cookieJar,
        _configService = configService ?? locator<ConfigService>();

  GraphQLClient? _client;

  ResolveGraphqlClient get resolveClientFunction => () => _client!;

  final _jwtExpiredMessages = [
    'Signature has expired',
  ];

  final _authBootstrapOperationMarkers = [
    'refreshToken',
    'tokenAuth',
    'verifyLoginQrToken',
  ];

  overrideDioSelfSignCertificateHandling() {
    final adapter = _dio.httpClientAdapter;
    if (adapter is! IOHttpClientAdapter) return;
    final httpClient = adapter;
    httpClient.createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
      return client;
    };
  }

  IAuthService? _readyAuth() {
    if (!locator.isRegistered<IAuthService>()) return null;
    try {
      return locator<IAuthService>();
    } on StateError {
      // Auth.init itself makes GraphQL requests before its async singleton is
      // ready. Those bootstrap responses are classified by AuthService.
      return null;
    }
  }

  init() async {
    overrideDioSelfSignCertificateHandling();
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.sendTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    if (_cookieJar == null) {
      final appDocDir = await getApplicationDocumentsDirectory();
      _cookieJar =
          PersistCookieJar(storage: FileStorage("${appDocDir.path}/.cookies/"));
    }

    _dio.interceptors.add(CookieManager(_cookieJar!));
    _dio.interceptors.add(
      http.InterceptorsWrapper(
        onRequest: (options, handler) {
          options.extra[_failedAccessTokenKey] = _readyAuth()?.accessToken;
          handler.next(options);
        },
        onResponse: (response, handler) async {
          final data = response.data;
          final errors = data is Map ? data['errors'] : null;
          final options = response.requestOptions;
          final auth = _readyAuth();
          if (errors is! List ||
              !_isJWTExpire(errors) ||
              _alreadyRetried(options) ||
              _isAuthBootstrapOperation(options) ||
              auth == null) {
            return handler.next(response);
          }
          try {
            final result = await auth.ensureValidAccessToken(
                force: true,
                failedAccessToken:
                    options.extra[_failedAccessTokenKey] as String?);
            if (result == EnsureAccessTokenResult.valid) {
              return handler.resolve(await _retry(options));
            }
            handler.next(response);
          } catch (e, stack) {
            handler.reject(e is http.DioException
                ? e
                : http.DioException(
                    requestOptions: options, error: e, stackTrace: stack));
          }
        },
        onError: (error, handler) async {
          return handler.reject(error);
        },
      ),
    );
    await renewClient();
  }

  Future<void> clearCookies() async {
    await _cookieJar?.deleteAll();
  }

  Future<void> clearGraphqlCache() async {
    _client?.cache.store.reset();
  }

  Future<http.Response<dynamic>> _retry(http.RequestOptions requestOptions) {
    // CookieManager will load the newly refreshed cookies. Do not merge the
    // expired Cookie header from the original request into the retry.
    final headers = Map<String, dynamic>.from(requestOptions.headers)
      ..removeWhere((key, _) => key.toLowerCase() == 'cookie');
    final data = requestOptions.data;
    final options = http.Options(
      method: requestOptions.method,
      headers: headers,
      extra: {
        ...requestOptions.extra,
        _authRetriedExtraKey: true,
      },
    );
    return _dio.request<dynamic>(requestOptions.path,
        data: data is http.FormData ? data.clone() : data,
        cancelToken: requestOptions.cancelToken,
        queryParameters: requestOptions.queryParameters,
        options: options);
  }

  bool _alreadyRetried(http.RequestOptions requestOptions) {
    return requestOptions.extra[_authRetriedExtraKey] == true;
  }

  bool _isAuthBootstrapOperation(http.RequestOptions requestOptions) {
    final data = requestOptions.data;
    String query = '';
    if (data is Map) {
      query = data['query']?.toString() ?? '';
    } else if (data is String) {
      query = data;
    } else if (data is http.FormData) {
      for (final field in data.fields) {
        if (field.key == 'operations') {
          try {
            final operations = jsonDecode(field.value);
            if (operations is Map) {
              query = operations['query']?.toString() ?? '';
            }
          } on FormatException {
            return false;
          }
        }
      }
    }
    if (query.isEmpty) {
      return false;
    }
    final normalized = query.toLowerCase();
    for (final marker in _authBootstrapOperationMarkers) {
      if (normalized.contains(marker.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  bool _isJWTExpire(List errors) => errors.whereType<Map>().any((error) {
        final message = error['message'];
        return message is String && _jwtExpiredMessages.any(message.contains);
      });

  setBackendSubDomain(String subDomain) async {
    if (locator.isRegistered<QueueOwnershipService>()) {
      await locator<QueueOwnershipService>().checkTenantChange(subDomain);
    }
    final prefs = await SharedPreferences.getInstance();
    if (subDomain == "") {
      await prefs.remove(backendUrlKey);
    } else {
      await prefs.setString(backendUrlKey, subDomain);
    }

    // const String environment = String.fromEnvironment(
    //   'ENVIRONMENT',
    //   defaultValue: Environment.dev,
    // );
    // setupLocator(environment);
  }

  Future<void> renewClient() async {
    final Link dioLink = DioLink(
      await _endpoint(),
      client: _dio,
    );
    _client = GraphQLClient(
      link: BoundedRequestLink(requestTimeout).concat(dioLink),
      cache: _cache,
      // The outer link owns cancellation and ignores late responses.
      queryRequestTimeout: null,
    );
  }

  _endpoint() async {
    final prefs = await SharedPreferences.getInstance();
    final subDomain = prefs.getString(backendUrlKey);
    if (subDomain != null && subDomain != "") {
      return "https://$subDomain/graphql/";
    }
    return _configService.graphqlEndpoint;
  }
}
