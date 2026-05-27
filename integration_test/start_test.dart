/// Patrol integration test entry point.
///
/// Run with:
///   patrol test --target integration_test/start_test.dart
///
/// Pass test credentials via --dart-define:
///   patrol test \
///     --target integration_test/start_test.dart \
///     --dart-define=TEST_USERNAME=myuser \
///     --dart-define=TEST_PASSWORD=mypass \
///     --dart-define=TENANT_API_ENDPOINT=https://admin.ohtk.org/api/servers/
///
/// Scenario chain:  LoginScenario  (extend here with next: HomeScenario, etc.)
library;

import 'package:patrol/patrol.dart';

import 'flows/login_scenario.dart';
import 'utils/test_utility.dart';

void main() {
  // Do NOT call IntegrationTestWidgetsFlutterBinding.ensureInitialized() here.
  // Patrol's PatrolBinding initializes the binding itself when patrolTest() is
  // declared.  Calling ensureInitialized() before patrolTest() replaces
  // PatrolBinding with the vanilla Flutter test binding, which causes Patrol's
  // test runner to find 0 tests.

  patrolTest(
    'Login flow: user authenticates and leaves the login screen',
    ($) async {
      // ── 1. Boot the app via shared utility ─────────────────────────────────
      await TestUtility.init($);

      // ── 2. Credentials supplied at build-time via --dart-define ────────────
      const testUsername = String.fromEnvironment(
        'TEST_USERNAME',
        defaultValue: 'test_user',
      );
      const testPassword = String.fromEnvironment(
        'TEST_PASSWORD',
        defaultValue: 'test_password',
      );

      // ── 3. Build the scenario chain and kick it off ─────────────────────────
      // Extend the chain here as the app grows, e.g.:
      //   next: HomeScenario($, next: null)
      final chain = LoginScenario(
        $,
        username: testUsername,
        password: testPassword,
        next: null,
      );

      await chain.startFlow();
    },
  );
}
