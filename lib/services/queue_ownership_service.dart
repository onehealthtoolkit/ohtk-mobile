import 'dart:convert';

import 'package:podd_app/models/submission_problem.dart';
import 'package:podd_app/models/user_profile.dart';
import 'package:podd_app/services/db_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The existing outbox is device-wide. Keep it with its original session until
/// drained, rather than exposing it to a different account after re-login.
class QueueOwnershipService {
  static const ownerKey = 'pendingSubmissionOwnerV1';
  Future<void> _binding = Future.value();
  final IDbService database;
  final String fallbackEndpoint;

  QueueOwnershipService(this.database, this.fallbackEndpoint);

  Future<bool> get hasPending async {
    for (final table in [
      'report',
      'subject_record',
      'monitoring_record',
      'report_image',
      'report_file'
    ]) {
      if ((await database.db.query(table, columns: ['id'], limit: 1))
          .isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  String _tenant(SharedPreferences prefs) {
    final domain = prefs.getString('backendUrl');
    return domain == null || domain.isEmpty
        ? Uri.parse(fallbackEndpoint).origin
        : Uri.parse('https://$domain').origin;
  }

  Future<void> bind(UserProfile profile, {bool adoptLegacyQueue = false}) {
    final next = _binding
        .then((_) => _bind(profile, adoptLegacyQueue: adoptLegacyQueue));
    _binding = next.catchError((Object _) {});
    return next;
  }

  Future<void> _bind(UserProfile profile,
      {required bool adoptLegacyQueue}) async {
    final prefs = await SharedPreferences.getInstance();
    final target = jsonEncode(
        {'version': 1, 'tenant': _tenant(prefs), 'userId': profile.id});
    final owner = prefs.getString(ownerKey);
    if (owner == target) return;
    if (await hasPending && !(owner == null && adoptLegacyQueue)) {
      throw const SubmissionProblem(SubmissionProblemKind.authentication,
          'Unsent items belong to the previous account and server. Sign in there to finish sending them.');
    }
    if (!await prefs.setString(ownerKey, target)) {
      throw StateError('Cannot save outbox owner');
    }
  }

  Future<void> checkTenantChange(String domain) async {
    final prefs = await SharedPreferences.getInstance();
    final target = domain.isEmpty
        ? Uri.parse(fallbackEndpoint).origin
        : Uri.parse('https://$domain').origin;
    if (target != _tenant(prefs) && await hasPending) {
      throw const SubmissionProblem(SubmissionProblemKind.authentication,
          'Send the pending items on the current server before choosing another server.');
    }
  }
}
