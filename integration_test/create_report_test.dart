// Patrol integration test entry point.
//
// Run with:
//   patrol test --target integration_test/create_report_test.dart
//
// Pass test credentials via --dart-define:
//   patrol test \
//     --target integration_test/create_report_test.dart \
//     --dart-define=TEST_USERNAME=myuser \
//     --dart-define=TEST_PASSWORD=mypass \
//     --dart-define=TENANT_API_ENDPOINT=https://admin.ohtk.org/api/servers/ \
//     --dart-define=TEST_SERVER_DOMAIN=bon.backend.ohtk.org \
//     --dart-define=EXPECT_WELCOME_SCREEN=true
//
// Scenario chain:
//   EXPECT_WELCOME_SCREEN=true  => WelcomeScenario → LoginSuccessScenario → ReportListScenario
//   EXPECT_WELCOME_SCREEN=false => LoginSuccessScenario → ReportListScenario
import 'package:patrol/patrol.dart';

import 'flows/login_success_scenario.dart';
import 'flows/report_list_scenario.dart';
import 'flows/welcome_scenario.dart';
import 'utils/test_utility.dart';

void main() {
  // Do NOT call IntegrationTestWidgetsFlutterBinding.ensureInitialized() here.
  // Patrol's PatrolBinding initializes the binding itself when patrolTest() is
  // declared.  Calling ensureInitialized() before patrolTest() replaces
  // PatrolBinding with the vanilla Flutter test binding, which causes Patrol's
  // test runner to find 0 tests.

  patrolTest(
    'Create report flow: welcome → login → report list → tap new report',
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
      const testServerDomain = String.fromEnvironment(
        'TEST_SERVER_DOMAIN',
        defaultValue: '',
      );
      const testServerMatch = String.fromEnvironment(
        'TEST_SERVER_MATCH',
        defaultValue: 'bon',
      );
      const expectWelcomeScreen = bool.fromEnvironment(
        'EXPECT_WELCOME_SCREEN',
        defaultValue: true,
      );

      // ── 3. Build the scenario chain and kick it off ─────────────────────────
      // The chain: Welcome (optional) → Login (successful) → Report List → Tap New Report
      if (expectWelcomeScreen) {
        final chain = WelcomeScenario(
          $,
          requireOnStart: true,
          serverDomain: testServerDomain,
          serverMatch: testServerMatch,
          next: LoginSuccessScenario(
            $,
            username: testUsername,
            password: testPassword,
            next: ReportListScenario(
              $,
              next: null, // Stop here after tapping new report button
            ),
          ),
        );

        await chain.startFlow();
      } else {
        final chain = LoginSuccessScenario(
          $,
          username: testUsername,
          password: testPassword,
          next: ReportListScenario(
            $,
            next: null, // Stop here after tapping new report button
          ),
        );

        await chain.startFlow();
      }
    },
  );
}
