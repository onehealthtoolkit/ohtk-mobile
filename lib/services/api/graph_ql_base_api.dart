import 'package:flutter/foundation.dart';
import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';

abstract class GraphQlBaseApi {
  GraphQLClient client;
  Logger? baseLogger = locator<Logger>();
  late GraphQLResponseParser responseParser;

  Future<bool> ensureAuthCookieIsSet() {
    return Future.value(true);
  }

  GraphQlBaseApi(this.client) : responseParser = const GraphQLResponseParser();

  /// Runs a GqlQuery and parses the response with the assumption of it being a single
  /// result and NOT a collection. For fetching and parsing a collection use [runGqlListQuery]
  Future<RT> runGqlQuery<RT>({
    required String query,
    String? actionName,
    bool logResponseData = false,
    Map<String, dynamic> variables = const {},
    Function(QueryResult response)? onRawResponse,
    TypeConverter<RT>? typeConverter,
    FetchPolicy fetchPolicy = FetchPolicy.networkOnly,
  }) async {
    return _runGQLRequest<RT>(
      query: query,
      parseData: (data) =>
          responseParser.parseSingleResponse<RT>(data, typeConverter),
      actionName: actionName,
      variables: variables,
      logResponseData: logResponseData,
      onRawResponse: onRawResponse,
      fetchPolicy: fetchPolicy,
    );
  }

  /// Runs a gql query and parses the response with the assumption that it will return a
  /// list of information.
  ///
  /// The list can be in 1 of two forms:
  /// - [GqlResultType.PaginatedQuery]: This provides you with a response structure contains edges
  /// with the nodes being the actual objects
  /// - [GqlResultType.PlainQueryList]: This is a response where the first entry in the data object
  /// is the list of results.
  Future<List<RT>> runGqlListQuery<RT>({
    required String query,
    String? actionName,
    bool logResponseData = false,
    Map<String, dynamic> variables = const {},
    Function(QueryResult response)? onRawResponse,
    TypeConverter<RT>? typeConverter,
    FetchPolicy fetchPolicy = FetchPolicy.networkOnly,
  }) async {
    return _runGQLRequest<List<RT>>(
      query: query,
      parseData: (data) =>
          responseParser.parseListResponse<RT>(data, typeConverter),
      actionName: actionName,
      logResponseData: logResponseData,
      variables: variables,
      onRawResponse: onRawResponse,
      fetchPolicy: fetchPolicy,
    );
  }

  Future<T> _runGQLRequest<T>(
      {required String query,
      required T Function(Map<String, dynamic>?) parseData,
      String? actionName,
      bool logResponseData = false,
      Map<String, dynamic> variables = const {},
      Function(QueryResult response)? onRawResponse,
      fetchPolicy = FetchPolicy.networkOnly}) async {
    final functionIdentity = actionName ?? query;
    if (await (ensureAuthCookieIsSet())) {
      baseLogger?.v('REQUEST:$actionName - query:$query');
      var response = await client.query(
        QueryOptions(
          document: gql(query),
          variables: variables,
          fetchPolicy: fetchPolicy,
          cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
        ),
      );
      onRawResponse?.call(response);
      baseLogger?.v(
          'RESPONSE:$actionName - hasData: ${response.data != null} ${logResponseData ? "data:${response.data}" : ''}');

      if (!response.hasException) {
        try {
          return parseData(response.data);
        } catch (e, stacktrace) {
          baseLogger?.e('$functionIdentity failed: $e');

          throw GraphQlException(
            message: e.toString(),
            query: query,
            queryName: functionIdentity,
            stackTrace: stacktrace,
          );
        }
      } else {
        if (response.exception?.linkException != null) {
          throw response.exception!.linkException!;
        } else {
          throw response.exception!;
        }
      }
    } else {
      var error = 'Cookies are invalid';
      baseLogger?.e(error);
      throw GraphQlException(
        message: error,
        query: query,
        queryName: functionIdentity,
      );
    }
  }

  Future<T> runGqlMutation<T>({
    required String mutation,
    required T Function(Map<String, dynamic>?) parseData,
    Map<String, dynamic> variables = const {},
    String? actionName,
    bool logResponseData = false,
    Function(QueryResult response)? onRawResponse,
    CacheRereadPolicy cacheRereadPolicy = CacheRereadPolicy.ignoreAll,
  }) async {
    final functionIdentity = actionName ?? mutation;
    if (await (ensureAuthCookieIsSet())) {
      final MutationOptions options = MutationOptions(
        document: gql(mutation),
        variables: variables,
        cacheRereadPolicy: cacheRereadPolicy,
      );

      final QueryResult response = await client.mutate(options);
      onRawResponse?.call(response);

      baseLogger?.v(
          'RESPONSE:$actionName - hasData: ${response.data != null} ${logResponseData ? "data:${response.data}" : ''}');

      /*
       *  if operation is success, response.data will contain response data from server
       *  but if validation did not go well, response.data will contain null and response.exception
       *  will contain validation error.
       * 
       *  response.exception could be happen from network or cache error,
       *  In those cases, reponse.exception.linkException will 
       */
      if (!response.hasException) {
        final data = responseParser.parseMutationResponse(response.data!);
        return parseData(data);
      } else {
        // network or cache error
        if (response.exception?.linkException != null) {
          throw response.exception!.linkException!;
        } else {
          throw response.exception!;
        }
      }
    } else {
      var error = 'Cookies are invalid';
      baseLogger?.e(error);
      throw GraphQlException(
        message: error,
        query: mutation,
        queryName: functionIdentity,
      );
    }
  }
}

class GraphQlException implements Exception {
  final String message;
  final String? query;
  final String? queryName;
  final StackTrace? stackTrace;
  GraphQlException({
    required this.message,
    this.stackTrace,
    this.query,
    this.queryName,
  });

  @override
  String toString() {
    return 'GraphQlException: $message\nqueryName:$queryName\nquery:$query\n$stackTrace';
  }
}

typedef TypeConverter<T> = T Function(Map<String, dynamic>);

/// A parser that contains helper functions for turning your graphQL response into domain specific models
class GraphQLResponseParser {
  const GraphQLResponseParser();

  /// Takes in a raw GraphQL Query and seriealises it to the type passed in.
  T parseSingleResponse<T>(
      Map<String, dynamic>? data, TypeConverter? typeConverter) {
    if (typeConverter == null) {
      throw Exception(
          'No type converter defined for $T register one in GraphQLResponseParser');
    }

    if (data == null) {
      throw Exception('Data to parse cannot be null');
    }

    data = typeNameRemover(data);

    var dataType = determineQueryType(data);

    switch (dataType) {
      case GqlResultType.plainQuery:
        return typeConverter(data[data.keys.first]) as T;
      case GqlResultType.plain:
      default:
        return typeConverter(data) as T;
    }
  }

  /// Takes in a raw GraphQl ressponse and parses it into a list of results of [T]
  List<T> parseListResponse<T>(data, TypeConverter? typeConverter) {
    data = typeNameRemover(data);

    if (typeConverter == null) {
      throw Exception(
          'No type converter defined for $T register one in GraphQLResponseParser');
    }

    var dataType = determineQueryType(data);

    switch (dataType) {
      case GqlResultType.paginatedQuery:
        var edges = data[data.keys.first]['edges'];
        List<T> results = [];
        for (var edge in edges) {
          var node = edge['node'];
          results.add(typeConverter.call(node) as T);
        }
        return results;
      case GqlResultType.plainQueryList:
      default:
        var resultsAsList = data[data.keys.first] as List;
        List<T> results = [];
        for (var result in resultsAsList) {
          final convertedValue = typeConverter(result) as T;
          results.add(convertedValue);
        }
        return results;
    }
  }

  @visibleForTesting
  GqlResultType determineQueryType(Map<String, dynamic> data) {
    var isQueryResponse = _checkIfQuery(data);

    if (isQueryResponse) {
      var isPaginated =
          (data[data.keys.first] as Map<String, dynamic>).containsKey('edges');
      if (isPaginated) {
        return GqlResultType.paginatedQuery;
      }
      return GqlResultType.plainQuery;
    }

    var isListQuery = _checkIfListQuery(data);
    if (isListQuery) {
      return GqlResultType.plainQueryList;
    }

    return GqlResultType.plain;
  }

  Map<String, dynamic> typeNameRemover(Map<String, dynamic> data) {
    if (data.containsKey('__typename')) {
      data.removeWhere((key, value) => key == '__typename');
      return data;
    } else {
      return data;
    }
  }

  /// A response from a query will always have at the least the first child as the map
  /// with the actual response. If it's not a map it's most likely not a query
  bool _checkIfQuery(Map<String, dynamic> data) {
    try {
      // ignore: unnecessary_statements
      (data[data.keys.first] as Map<String, dynamic>?);
      return true;
    } catch (_) {
      return false;
    }
  }

  bool _checkIfListQuery(Map<String, dynamic> data) {
    try {
      // ignore: unnecessary_statements
      (data[data.keys.first] as List?);
      return true;
    } catch (_) {
      return false;
    }
  }

  bool _mutationResponseIsUnderMutationName(Map<String, dynamic> data) {
    try {
      // ignore: unnecessary_statements
      (data[data.keys.first] as Map?);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Parses a response from a mutation and returns a clean version of the data without
  /// __typename. We also return only the data under the mutation name key.
  Map<String, dynamic> parseMutationResponse(Map<String, dynamic> data) {
    data = typeNameRemover(data);
    if (_mutationResponseIsUnderMutationName(data)) {
      return data[data.keys.first];
    }

    return data;
  }
}

enum GqlResultType {
  /// When the results returned is at the root of the data child
  plain,

  /// when the result returned is in a child with the query as the title
  plainQuery,

  // When the result returned as the query title is a list of objects
  plainQueryList,

  /// When the result returned has edges and nodes for traversal
  paginatedQuery,
}
