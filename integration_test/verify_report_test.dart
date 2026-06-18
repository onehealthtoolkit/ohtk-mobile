// Patrol integration test entry point for verifying test report appears in list.
//
// Run with:
//   patrol test --target integration_test/verify_report_test.dart
//
// Pass test credentials via --dart-define:
//   patrol test \
//     --target integration_test/verify_report_test.dart \
//     --dart-define=TEST_USERNAME=myuser \
//     --dart-define=TEST_PASSWORD=mypass \
//     --dart-define=TENANT_API_ENDPOINT=https://admin.ohtk.org/api/servers/ \
//     --dart-define=TEST_SERVER_DOMAIN=bon.backend.ohtk.org \
//     --dart-define=EXPECT_WELCOME_SCREEN=true
//
// Scenario chain:
//   Welcome → Login → ReportList → ReportType → ReportForm → VerifyTestReport
//
// How It Works:
// ─────────────
//
// ┌─────────────────────────────────────────────────────────────┐
// │ 1. Submit Test Report                                       │
// │    (via ReportFormScenario)                                 │
// └────────────────┬────────────────────────────────────────────┘
//                  │
//                  ▼
// ┌─────────────────────────────────────────────────────────────┐
// │ 2. Navigate Back to Report List                             │
// │    - Success overlay appears: "ส่งรายงานสำเร็จ"              │
// │    - Auto-dismiss and Navigator.pop()                       │
// └────────────────┬────────────────────────────────────────────┘
//                  │
//                  ▼
// ┌─────────────────────────────────────────────────────────────┐
// │ 3. Find Report in List                                      │
// │    - Search for report by type name                         │
// │    - Should be at top (most recent)                         │
// │    - Scroll if needed (max 10 scrolls)                      │
// └────────────────┬────────────────────────────────────────────┘
//                  │
//                  ▼
// ┌─────────────────────────────────────────────────────────────┐
// │ 4. Open Report Detail                                       │
// │    - Tap on report card                                     │
// │    - Wait for detail view to load                           │
// └────────────────┬────────────────────────────────────────────┘
//                  │
//                  ▼
// ┌─────────────────────────────────────────────────────────────┐
// │ 5. Verify Test Flag                                         │
// │    - Look for "ทดสอบ" pill in detail view                   │
// │    - Scroll if needed (max 5 scrolls)                       │
// │    - Assert pill exists                                     │
// └────────────────┬────────────────────────────────────────────┘
//                  │
//                  ▼
// ┌─────────────────────────────────────────────────────────────┐
// │ 6. Navigate Back                                            │
// │    - Press native back button                               │
// │    - Verify return to report list                           │
// └─────────────────────────────────────────────────────────────┘
import 'package:patrol/patrol.dart';

import 'flows/login_success_scenario.dart';
import 'flows/report_form_scenario.dart';
import 'flows/report_list_scenario.dart';
import 'flows/report_type_scenario.dart';
import 'flows/verify_test_report_scenario.dart';
import 'flows/welcome_scenario.dart';
import 'utils/test_utility.dart';

void main() {
  patrolTest(
    'Verify test report appears in list after submission',
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

      // ── 3. Build the scenario chain ─────────────────────────────────────────
      //
      // The chain will:
      // 1. Welcome screen (if EXPECT_WELCOME_SCREEN=true)
      // 2. Login with credentials
      // 3. Navigate to report list
      // 4. Select report type (with test mode enabled)
      // 5. Fill and submit the report form
      // 6. Verify the test report appears in the list with test flag
      //
      // Note: Uses the same hardcoded report type as create_report_test.dart
      // (category: "สุขภาพคน", type: "สัตว์กัด")

      final verifyReportScenario = VerifyTestReportScenario(
        $,
        reportTypeName: 'สัตว์กัด',
      );

      final reportFormScenario = ReportFormScenario(
        $,
        next: verifyReportScenario,
      );

      final reportTypeScenario = ReportTypeScenario(
        $,
        categoryName: 'สุขภาพคน',
        reportTypeName: 'สัตว์กัด',
        next: reportFormScenario,
      );
      final reportListScenario = ReportListScenario(
        $,
        next: reportTypeScenario,
      );

      final loginSuccessScenario = LoginSuccessScenario(
        $,
        username: testUsername,
        password: testPassword,
        next: reportListScenario,
      );

      // Start the chain from welcome (if present) or login
      if (expectWelcomeScreen) {
        final welcomeScenario = WelcomeScenario(
          $,
          serverDomain: testServerDomain,
          serverMatch: testServerMatch,
          next: loginSuccessScenario,
        );
        await welcomeScenario.startFlow();
      } else {
        await loginSuccessScenario.startFlow();
      }
    },
  );
}
