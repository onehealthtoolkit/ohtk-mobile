import 'package:podd_app/locator.dart';
import 'package:podd_app/models/submission_problem.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/queue_ownership_service.dart';

Future<void> bindSubmissionOwner() async {
  if (!locator.isRegistered<QueueOwnershipService>()) return;
  final profile = locator<IAuthService>().userProfile;
  if (profile == null) {
    throw const SubmissionProblem(SubmissionProblemKind.authentication,
        'Sign in again with the same account to send your saved items.');
  }
  await locator<QueueOwnershipService>().bind(profile);
}

Future<void> ensureSubmissionSession() async {
  // Services are also used with standalone APIs in tests/tools. The app always
  // registers auth and ownership before exposing submission screens.
  if (!locator.isRegistered<IAuthService>()) return;
  final auth = locator<IAuthService>();
  final result = await auth.ensureValidAccessToken();
  if (result != EnsureAccessTokenResult.valid) {
    throw SubmissionProblem(
        result == EnsureAccessTokenResult.unauthenticated
            ? SubmissionProblemKind.authentication
            : SubmissionProblemKind.connection,
        result == EnsureAccessTokenResult.unauthenticated
            ? 'Sign in again with the same account to send your saved items.'
            : 'Your session could not be checked. Try again when the server is reachable.',
        retryable: result == EnsureAccessTokenResult.transientFailure);
  }
  await bindSubmissionOwner();
}
