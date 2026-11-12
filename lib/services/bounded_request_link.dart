import 'dart:async';

import 'package:dio/dio.dart' as dio;
import 'package:gql_dio_link/gql_dio_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

/// End the link after one result/error. GraphQL 5.2's stream timeout otherwise
/// keeps listening and completes its completer twice when a late reply arrives.
class BoundedRequestLink extends Link {
  final Duration timeout;
  BoundedRequestLink(this.timeout);

  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    final cancel = dio.CancelToken();
    final scoped = request.updateContextEntry<DioLinkCancelTokenContextEntry>(
        (_) => DioLinkCancelTokenContextEntry(cancel));
    try {
      yield await forward!(scoped).first.timeout(timeout);
    } on TimeoutException {
      cancel.cancel('Submission deadline exceeded');
      rethrow;
    }
  }
}
