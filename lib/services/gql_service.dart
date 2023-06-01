import 'dart:io';

import 'package:dio/io.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/services/api/graph_ql_base_api.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/config_service.dart';
import 'package:podd_app/services/secure_storage_service.dart';
import "package:gql_dio_link/gql_dio_link.dart";
import 'package:dio/dio.dart' as http;
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvalidRefreshTokenError extends http.DioError {
  InvalidRefreshTokenError(requestOptions)
      : super(requestOptions: requestOptions);
}

class GqlService {
  final backendUrlKey = "backendUrl";

  final _configService = locator<ConfigService>();
  final _secureStorage = locator<ISecureStorageService>();
  final _dio = http.Dio();
  final _cache = GraphQLCache(store: HiveStore());

  PersistCookieJar? _cookieJar;

  GraphQLClient? _client;

  ResolveGraphqlClient get resolveClientFunction => () => _client!;

  final _jwtExpiredMessages = [
    'Signature has expired',
  ];

  overrideDioSelfSignCertificateHandling() {
    DefaultHttpClientAdapter httpClient =
        _dio.httpClientAdapter as DefaultHttpClientAdapter;
    httpClient.onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
      return null;
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
          final errors = response.data['errors'];
          if (errors is List && errors.isNotEmpty) {
            if (_isInvalidRefreshToken(errors)) {
              var authService = locator<IAuthService>();
              await authService.logout();

              return handler.reject(
                InvalidRefreshTokenError(response.requestOptions),
              );
            } else if (_isJWTExpire(errors)) {
              bool success = await _refreshToken();
              if (success) {
                final cloneReq = await _retry(response.requestOptions);
                return handler.resolve(cloneReq);
              } else {
                return handler.next(response);
              }
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

  Future<bool> _refreshToken() async {
    final refreshToken = await _secureStorage.get('refreshToken');
    if (refreshToken == null) {
      return false;
    }

    const mutation = r'''
          mutation RefreshToken($refreshToken: String!) {
            refreshToken(refreshToken: $refreshToken) {
              token,
              refreshExpiresIn,
              refreshToken
            }
          }
    ''';

    try {
      final endpoint = await _endpoint();
      final response = await _dio.post(endpoint, data: {
        'query': mutation,
        'variables': {'refreshToken': refreshToken}
      });

      await _secureStorage.set(
        'token',
        response.data['data']['refreshToken']['token'],
      );
      return true;
    } on InvalidRefreshTokenError {
      return false;
    }
  }

  Future<http.Response<dynamic>> _retry(http.RequestOptions requestOptions) {
    final options = http.Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options);
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
      final err = element['message'] as String;
      final m = ["Refresh has expired"].firstWhere(
        (element) => err.contains(element),
        orElse: () => '',
      );
      if (m != '') {
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
    final Link _dioLink = DioLink(
      await _endpoint(),
      client: _dio,
    );
    _client = GraphQLClient(link: _dioLink, cache: _cache);
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
