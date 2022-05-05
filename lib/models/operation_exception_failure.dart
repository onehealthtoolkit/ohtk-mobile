import 'package:graphql_flutter/graphql_flutter.dart';

class OperationExceptionFailure {
  OperationException exception;

  OperationExceptionFailure(this.exception);

  List<String> get messages {
    return exception.graphqlErrors.fold<List<String>>([], (acc, element) {
      acc.add(element.message);
      return acc;
    });
  }
}
