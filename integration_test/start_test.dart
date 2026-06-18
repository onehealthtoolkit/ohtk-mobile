// Patrol integration test entry point.
//
// Run with:
//   patrol test --target integration_test/start_test.dart
//
// Pass test credentials via --dart-define:
//   patrol test \
//     --target integration_test/start_test.dart \
//     --dart-define=TEST_USERNAME=myuser \
//     --dart-define=TEST_PASSWORD=mypass \
//     --dart-define=TENANT_API_ENDPOINT=https://admin.ohtk.org/api/servers/ \
//     --dart-define=TEST_SERVER_DOMAIN=bon.backend.ohtk.org \
//     --dart-define=EXPECT_WELCOME_SCREEN=true
//
// How It Works:
// ─────────────
//
// ┌─────────────────────────────────────────────────────────────┐
// │ 1. Welcome Screen (if EXPECT_WELCOME_SCREEN=true)           │
// │    - Select Thai + BON server                               │
// └────────────────┬────────────────────────────────────────────┘
//                  │
//                  ▼
// ┌─────────────────────────────────────────────────────────────┐
// │ 2. Login Screen                                             │
// │    - Enter credentials                                      │
// │    - Tap "เข้าสู่ระบบ"                                      │
// │    - Assert still on login screen (error persists)          │
// └─────────────────────────────────────────────────────────────┘
import 'package:patrol/patrol.dart';

import 'flows/login_scenario.dart';
import 'flows/welcome_scenario.dart';
import 'utils/test_utility.dart';

void main() {
  // Do NOT call IntegrationTestWidgetsFlutterBinding.ensureInitialized() here.
  // Patrol's PatrolBinding initializes the binding itself when patrolTest() is
  // declared.  Calling ensureInitialized() before patrolTest() replaces
  // PatrolBinding with the vanilla Flutter test binding, which causes Patrol's
  // test runner to find 0 tests.

  patrolTest(
    'Startup setup + negative auth: welcome gate then invalid login stays on login screen',
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
      // Extend the chain here as the app grows, e.g.:
      //   next: HomeScenario($, next: null)
      // NOTE: When EXPECT_WELCOME_SCREEN=false, welcome is skipped entirely.
      if (expectWelcomeScreen) {
        final chain = WelcomeScenario(
          $,
          requireOnStart: true,
          serverDomain: testServerDomain,
          serverMatch: testServerMatch,
          next: LoginScenario(
            $,
            username: testUsername,
            password: testPassword,
            next: null,
          ),
        );

        await chain.startFlow();
      } else {
        final chain = LoginScenario(
          $,
          username: testUsername,
          password: testPassword,
          next: null,
        );

        await chain.startFlow();
      }
    },
  );
}
