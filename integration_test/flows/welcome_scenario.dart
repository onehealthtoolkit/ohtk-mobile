import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/keys/application_keys.dart';

import 'base_test_scenario.dart';

typedef K = ApplicationKeys;

/// Patrol scenario that completes the Welcome / first-launch setup screen.
///
/// Steps
/// -----
/// 1. Optionally require the welcome screen to appear.
/// 2. Select Thai ("ภาษาไทย") as the language.
/// 3. Wait for the tenant server list and select a server (prefer exact domain
///    match when [serverDomain] is provided).
/// 4. Tap Continue, then explicitly wait for the login screen after restart.
final class WelcomeScenario extends BaseTestScenario {
  /// If true, this scenario must be shown on app start.
  ///
  /// If false and welcome isn't shown, this scenario is skipped and the chain
  /// proceeds to [next].
  final bool requireOnStart;

  /// The language code to select (default: Thai / "th").
  final String languageCode;

  /// Exact server domain to select when provided, for deterministic runs.
  final String serverDomain;

  /// Substring to match against a server's label or domain (default: "bon").
  final String serverMatch;

  WelcomeScenario(
    super.$, {
    super.next,
    this.requireOnStart = true,
    this.languageCode = 'th',
    this.serverDomain = '',
    this.serverMatch = 'bon',
  });

  @override
  Future<bool> waitAndCheckValid() async {
    if (requireOnStart) {
      return true;
    }
    return $(K.welcomeKeys.view).exists;
  }

  @override
  Future<bool> run() async {
    // ── 1. Verify the welcome screen is showing ───────────────────────────
    expect(
      $(K.welcomeKeys.view).exists,
      isTrue,
      reason: 'Welcome screen not found.',
    );

    // ── 2. Select language ────────────────────────────────────────────────
    final languageLabel = languageCode == 'th' ? 'ภาษาไทย' : languageCode;
    await $.waitUntilVisible(find.text(languageLabel));
    await $(find.text(languageLabel)).tap();

    // Give the UI a moment to update the radio selection.
    await $.pumpAndSettle();

    // ── 3. Wait for server list and pick configured server ────────────────
    if (serverDomain.isNotEmpty) {
      await $.waitUntilVisible(find.text(serverDomain));
      await $(find.text(serverDomain)).tap();
    } else {
      await $.waitUntilVisible(find.textContaining(serverMatch));
      await $(find.textContaining(serverMatch)).tap();
    }

    await $.pumpAndSettle();

    // ── 4. Tap Continue ──────────────────────────────────────────────────
    // The Continue button is only enabled when both language and server are
    // selected and the view model is not busy.
    await $(K.welcomeKeys.continueButton).tap();

    // After tapping Continue the app calls RestartWidget.restartApp(), which
    // re-runs setupLocator and remounts OhtkApp. Explicitly wait for login to
    // avoid timing flake on slower devices/CI.
    await $.waitUntilVisible(find.byKey(K.loginKeys.view));
    expect(
      $(K.loginKeys.view).exists,
      isTrue,
      reason: 'Login screen did not appear after completing welcome setup.',
    );

    return true;
  }
}
