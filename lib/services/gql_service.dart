import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/services/config_service.dart';
import 'package:podd_app/services/secure_storage_service.dart';
import "package:gql_dio_link/gql_dio_link.dart";
import 'package:dio/dio.dart' as http;
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class GqlService {
  final _configService = locator<ConfigService>();
  final _secureStorage = locator<ISecureStorageService>();
  final _dio = http.Dio();
  final _cookieJar = CookieJar();

  late GraphQLClient _client;

  GraphQLClient get client => _client;

  final _jwtExpiredMessages = [
    'You do not have permission to perform this action',
    'JWTExpired',
  ];

  GqlService() {
    _dio.interceptors.add(CookieManager(_cookieJar));
    _dio.interceptors.add(
      http.InterceptorsWrapper(
        onResponse: (response, handler) async {
          final errors = response.data['errors'];
          if (errors is List && errors.isNotEmpty) {
            if (_isJWTExpire(errors)) {
              await _refreshToken();
              final cloneReq = await _retry(response.requestOptions);
              return handler.resolve(cloneReq);
            }
          }
          return handler.resolve(response);
        },
        onError: (error, handler) async {
          return handler.reject(error);
        },
      ),
    );
    final Link _dioLink = DioLink(
      _configService.graphqlEndpoint,
      client: _dio,
    );
    final cache = GraphQLCache(store: HiveStore());
    _client = GraphQLClient(link: _dioLink, cache: cache);
  }

  Future<void> _refreshToken() async {
    final refreshToken = await _secureStorage.get('refreshToken');
    const mutation = r'''
          mutation RefreshToken($refreshToken: String!) {
            refreshToken(refreshToken: $refreshToken) {
              token,
              refreshExpiresIn,
              refreshToken
            }
          }
    ''';
    final response = await _dio.post(_configService.graphqlEndpoint, data: {
      'query': mutation,
      'variables': {'refreshToken': refreshToken}
    });

    if (response.statusCode == 200) {
      await _secureStorage.set(
        'token',
        response.data['data']['refreshToken']['token'],
      );
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
}
