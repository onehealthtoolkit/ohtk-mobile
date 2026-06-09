import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/keys/application_keys.dart';

import 'base_test_scenario.dart';

// Shorthand for ApplicationKeys, consistent with the production-code alias.
typedef K = ApplicationKeys;

/// Patrol scenario that covers a successful login screen flow.
///
/// Steps
/// -----
/// 1. Wait for the login screen to appear.
/// 2. Assert all required widgets (username field, password field, sign-in
///    button) are present.
/// 3. Enter the supplied [username] and [password].
/// 4. Tap the sign-in button and wait for navigation away from the login
///    screen.
/// 5. Assert we have left the login screen successfully (authentication succeeded).
///
/// Chain this with a `ReportListScenario` (or similar) via [next] to build a
/// full end-to-end flow:
/// ```dart
/// LoginSuccessScenario($, username: 'u', password: 'p', next: ReportListScenario($))
///   ..startFlow();
/// ```
final class LoginSuccessScenario extends BaseTestScenario {
  /// The username to enter in the login form.
  final String username;

  /// The password to enter in the login form.
  final String password;

  LoginSuccessScenario(
    super.$, {
    super.next,
    required this.username,
    required this.password,
  });

  // ---------------------------------------------------------------------------
  // Guard — always run the scenario; let `run()` fail hard if screen is missing.
  // ---------------------------------------------------------------------------

  @override
  Future<bool> waitAndCheckValid() async => true;

  // ---------------------------------------------------------------------------
  // Test logic
  // ---------------------------------------------------------------------------

  @override
  Future<bool> run() async {
    await $.pumpAndSettle();

    // ── 1. Verify the login screen and form are fully rendered ──────────────
    expect(
      $(K.loginKeys.view).exists,
      isTrue,
      reason: 'Login screen not found — app may have shown a different '
          'initial screen (WelcomeView, tenant picker, etc.).',
    );
    expect(
      $(K.loginKeys.usernameField).exists,
      isTrue,
      reason: 'Username field is not visible on the login screen',
    );
    expect(
      $(K.loginKeys.passwordField).exists,
      isTrue,
      reason: 'Password field is not visible on the login screen',
    );
    expect(
      $(K.loginKeys.signInButton).exists,
      isTrue,
      reason: 'Sign-in button is not visible on the login screen',
    );

    // ── 2. Fill in credentials ───────────────────────────────────────────────
    await $(K.loginKeys.usernameField).enterText(username);
    await $(K.loginKeys.passwordField).enterText(password);

    // Dismiss the soft keyboard so the sign-in button is always visible.
    await $.pumpAndSettle();

    // ── 3. Tap sign in ───────────────────────────────────────────────────────
    await $(K.loginKeys.signInButton).tap();

    // Allow time for the auth round-trip.
    await $.pumpAndSettle(duration: const Duration(seconds: 8));

    // ── 4. Assert we left the login screen (authentication succeeded) ───────
    expect(
      $(K.loginKeys.view).exists,
      isFalse,
      reason: 'Still on the login screen — expected successful authentication '
          'to navigate away from the login screen.',
    );

    return true;
  }
}
