import 'dart:async';
import 'dart:io';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/l10n/app_localizations.dart';

enum SubmissionProblemKind {
  connection,
  authentication,
  validation,
  localFile,
  unexpected,
  storage
}

/// Small, safe failure details retained with a queued attempt (never its payload).
class SubmissionProblem implements Exception {
  final SubmissionProblemKind kind;
  final String message;
  final bool retryable;

  const SubmissionProblem(this.kind, this.message, {this.retryable = false});

  factory SubmissionProblem.from(Object error) {
    if (error is SubmissionProblem) return error;
    if (error is FileSystemException) {
      return const SubmissionProblem(SubmissionProblemKind.localFile,
          'The attachment cannot be read. Keep this item and check the original file.');
    }
    if (error is OperationException) {
      if (error.linkException != null) {
        return SubmissionProblem.from(error.linkException!);
      }
      final messages = error.graphqlErrors.map((e) => e.message).join('\n');
      final lower = messages.toLowerCase();
      final auth =
          lower.contains('signature has expired') || lower.contains('login');
      return SubmissionProblem(
          auth
              ? SubmissionProblemKind.authentication
              : SubmissionProblemKind.validation,
          messages.isEmpty
              ? 'The server could not accept this item.'
              : messages);
    }
    if (error is UnexpectedResponseStructureException) {
      return const SubmissionProblem(SubmissionProblemKind.unexpected,
          'The server returned an incomplete response. The saved item can be retried.');
    }
    if (error is LinkException ||
        error is TimeoutException ||
        error is SocketException) {
      return const SubmissionProblem(SubmissionProblemKind.connection,
          'The server did not confirm this attempt. Check your connection and try again.',
          retryable: true);
    }
    return const SubmissionProblem(SubmissionProblemKind.unexpected,
        'This item could not be completed. It has been kept for another attempt.');
  }

  String localizedMessage(AppLocalizations localize) {
    switch (kind) {
      case SubmissionProblemKind.connection:
        return localize.pendingConnectionError;
      case SubmissionProblemKind.authentication:
        return localize.pendingAuthenticationError;
      case SubmissionProblemKind.localFile:
        return localize.pendingLocalFileError;
      case SubmissionProblemKind.unexpected:
        return localize.pendingUnexpectedError;
      case SubmissionProblemKind.storage:
        return localize.pendingStorageError;
      case SubmissionProblemKind.validation:
        return message;
    }
  }

  @override
  String toString() => message;
}
