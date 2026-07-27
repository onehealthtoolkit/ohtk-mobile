import 'dart:io';

import 'package:dio/io.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/services/api/graph_ql_base_api.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/config_service.dart';
import 'package:podd_app/services/jwt.dart';
import "package:gql_dio_link/gql_dio_link.dart";
import 'package:dio/dio.dart' as http;
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvalidRefreshTokenError extends http.DioException {
  InvalidRefreshTokenError(requestOptions)
      : super(requestOptions: requestOptions);
}

class GqlService {
  final backendUrlKey = "backendUrl";

  static const _authRetriedExtraKey = 'authRetried';

  final _configService = locator<ConfigService>();
  final _dio = http.Dio();
  final _cache = GraphQLCache(store: HiveStore());

  PersistCookieJar? _cookieJar;

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
    IOHttpClientAdapter httpClient =
        _dio.httpClientAdapter as IOHttpClientAdapter;
    httpClient.createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
      return client;
    };
  }

  init() async {
    overrideDioSelfSignCertificateHandling();
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    _cookieJar =
        PersistCookieJar(storage: FileStorage("$appDocPath/.cookies/"));

    _dio.interceptors.add(CookieManager(_cookieJar!));
    _dio.interceptors.add(
      http.InterceptorsWrapper(
        onResponse: (response, handler) async {
          final data = response.data;
          if (data is! Map) {
            return handler.resolve(response);
          }
          final errors = data['errors'];
          if (errors is List && errors.isNotEmpty) {
            if (_isInvalidRefreshToken(errors)) {
              var authService = locator<IAuthService>();
              await authService.logout();

              return handler.reject(
                InvalidRefreshTokenError(response.requestOptions),
              );
            } else if (_isJWTExpire(errors)) {
              // S5: no refresh-on-refresh / no second retry / skip auth bootstrap ops.
              if (_alreadyRetried(response.requestOptions) ||
                  _isAuthBootstrapOperation(response.requestOptions)) {
                return handler.next(response);
              }

              final authService = locator<IAuthService>();
              final current = authService.accessToken;
              // If another refresh already produced a still-valid access token
              // (wall-clock, no skew), just retry — avoid a redundant rotation.
              if (current != null &&
                  !Jwt.isExpired(current, delta: Duration.zero)) {
                final cloneReq = await _retry(response.requestOptions);
                return handler.resolve(cloneReq);
              }

              final result = await authService.ensureValidAccessToken(
                force: true,
                failedAccessToken: current,
              );
              if (result == EnsureAccessTokenResult.valid) {
                final cloneReq = await _retry(response.requestOptions);
                return handler.resolve(cloneReq);
              }
              return handler.next(response);
            }
          }
          return handler.resolve(response);
        },
        onError: (error, handler) async {
          return handler.reject(error);
        },
      ),
    );
    await renewClient();
  }

  Future<void> clearCookies() async {
    _cookieJar?.deleteAll();
  }

  Future<void> clearGraphqlCache() async {
    _client?.cache.store.reset();
  }

  Future<http.Response<dynamic>> _retry(http.RequestOptions requestOptions) {
    final options = http.Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
      extra: {
        ...requestOptions.extra,
        _authRetriedExtraKey: true,
      },
    );
    return _dio.request<dynamic>(requestOptions.path,
        data: requestOptions.data,
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

  _isJWTExpire(errors) {
    for (var element in errors) {
      final err = element['message'] as String;
      final m = _jwtExpiredMessages.firstWhere(
        (element) => err.contains(element),
        orElse: () => '',
      );
      if (m != '') {
        return true;
      }
    }
    return false;
  }

  _isInvalidRefreshToken(errors) {
    for (var element in errors) {
      final err = element['message'] as String?;
      if (err != null && AuthTokenFailureMessages.isHardRefreshFailure(err)) {
        return true;
      }
    }
    return false;
  }

  setBackendSubDomain(String subDomain) async {
    final prefs = await SharedPreferences.getInstance();
    if (subDomain == "") {
      prefs.remove(backendUrlKey);
    } else {
      prefs.setString(backendUrlKey, subDomain);
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
    _client = GraphQLClient(link: dioLink, cache: _cache);
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
