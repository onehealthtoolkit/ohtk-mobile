import 'package:patrol/patrol.dart';

import 'flows/login_success_scenario.dart';
import 'flows/report_form_validation_scenario.dart';
import 'flows/report_list_scenario.dart';
import 'flows/report_type_scenario.dart';
import 'flows/welcome_scenario.dart';
import 'utils/test_utility.dart';

/// Patrol test for form validation flow.
///
/// This test verifies that:
/// - Required field validation triggers when submitting empty fields
/// - Validation snackbar appears with "Invalid form value" message
/// - Field-level error messages appear below invalid fields
/// - Form does not navigate when validation fails
/// - Form successfully navigates when all required fields are filled
///
/// How It Works:
/// ─────────────
///
/// ┌─────────────────────────────────────────────────────────────┐
/// │ 1. Welcome Screen (if EXPECT_WELCOME_SCREEN=true)           │
/// │    - Select Thai + BON server                               │
/// └────────────────┬────────────────────────────────────────────┘
///                  │
///                  ▼
/// ┌─────────────────────────────────────────────────────────────┐
/// │ 2. Login                                                    │
/// │    - Enter credentials                                      │
/// │    - Tap "เข้าสู่ระบบ"                                      │
/// │    - Wait for report list to load                           │
/// └────────────────┬────────────────────────────────────────────┘
///                  │
///                  ▼
/// ┌─────────────────────────────────────────────────────────────┐
/// │ 3. Report List                                              │
/// │    - Tap "รายงานใหม่" FAB                                   │
/// └────────────────┬────────────────────────────────────────────┘
///                  │
///                  ▼
/// ┌─────────────────────────────────────────────────────────────┐
/// │ 4. Report Type Selection                                    │
/// │    - Toggle test mode ON                                    │
/// │    - Select category "สุขภาพคน"                             │
/// │    - Select type "สัตว์กัด"                                   │
/// └────────────────┬────────────────────────────────────────────┘
///                  │
///                  ▼
/// ┌─────────────────────────────────────────────────────────────┐
/// │ 5. Form Validation Tests                                    │
/// │    - Submit empty required fields → validation fails        │
/// │    - "Invalid form value" snackbar appears                 │
/// │    - Field-level errors shown below inputs                  │
/// │    - Fill ONE required field → still fails                 │
/// │    - Fill ALL required fields → succeeds                   │
/// │    - Navigates to Page 2                                    │
/// └─────────────────────────────────────────────────────────────┘
///
/// Usage:
/// ------
/// ```bash
/// patrol test \
///   --target integration_test/validation_test.dart \
///   --device <DEVICE_ID> \
///   --dart-define=TEST_USERNAME=<USERNAME> \
///   --dart-define=TEST_PASSWORD=<PASSWORD> \
///   --dart-define=TENANT_API_ENDPOINT=https://admin.ohtk.org/api/servers/
/// ```
void main() {
  patrolTest(
    'Form validation flow',
    ($) async {
      const requireWelcomeScreen =
          bool.fromEnvironment('EXPECT_WELCOME_SCREEN', defaultValue: true);
      const username = String.fromEnvironment('TEST_USERNAME');
      const password = String.fromEnvironment('TEST_PASSWORD');

      if (username.isEmpty || password.isEmpty) {
        throw Exception(
            'TEST_USERNAME and TEST_PASSWORD must be provided via --dart-define');
      }

      await TestUtility.init($);

      // Start the scenario chain
      final scenario = WelcomeScenario(
        $,
        requireOnStart: requireWelcomeScreen,
        next: LoginSuccessScenario(
          $,
          username: username,
          password: password,
          next: ReportListScenario(
            $,
            next: ReportTypeScenario(
              $,
              categoryName: 'สุขภาพคน',
              reportTypeName: 'สัตว์กัด',
              next: ReportFormValidationScenario($),
            ),
          ),
        ),
      );

      await scenario.startFlow();
    },
  );
}
