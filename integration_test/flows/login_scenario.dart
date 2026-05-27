import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/keys/application_keys.dart';

import 'base_test_scenario.dart';

// Shorthand for ApplicationKeys, consistent with the production-code alias.
typedef K = ApplicationKeys;

/// Patrol scenario that covers the login screen flow.
///
/// Steps
/// -----
/// 1. Wait for the login screen to appear.
/// 2. Assert all required widgets (username field, password field, sign-in
///    button) are present.
/// 3. Enter the supplied [username] and [password].
/// 4. Tap the sign-in button and wait for navigation away from the login
///    screen.
/// 5. Assert we have left the login screen successfully.
///
/// Chain this with a `HomeScenario` (or similar) via [next] to build a
/// full end-to-end flow:
/// ```dart
/// LoginScenario($, username: 'u', password: 'p', next: HomeScenario($))
///   ..startFlow();
/// ```
final class LoginScenario extends BaseTestScenario {
  /// The username to enter in the login form.
  final String username;

  /// The password to enter in the login form.
  final String password;

  LoginScenario(
    super.$, {
    super.next,
    required this.username,
    required this.password,
  });

  // ---------------------------------------------------------------------------
  // Guard
  // ---------------------------------------------------------------------------

  @override
  Future<bool> waitAndCheckValid() async {
    // The app is already settled by start_test.dart's initial pumpAndSettle.
    // Just check that the login screen's root Scaffold is present.
    return $(K.loginKeys.view).exists;
  }

  // ---------------------------------------------------------------------------
  // Test logic
  // ---------------------------------------------------------------------------

  @override
  Future<bool> run() async {
    await $.pumpAndSettle();

    // ── 1. Verify the login form is fully rendered ──────────────────────────
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

    // Allow time for auth round-trip and navigation.
    await $.pumpAndSettle(duration: const Duration(seconds: 8));

    // ── 4. Assert we navigated away from the login screen ───────────────────
    expect(
      $(K.loginKeys.view).exists,
      isFalse,
      reason: 'Still on the login screen after tapping sign in — '
          'check credentials or server selection.',
    );

    return true;
  }
}
