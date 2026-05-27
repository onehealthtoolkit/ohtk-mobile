import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/keys/application_keys.dart';

import 'base_test_scenario.dart';

typedef K = ApplicationKeys;

/// Patrol scenario that completes the Welcome / first-launch setup screen.
///
/// Steps
/// -----
/// 1. Wait for the welcome screen to appear.
/// 2. Select Thai ("ภาษาไทย") as the language.
/// 3. Wait for the tenant server list to load and tap the server whose label
///    or domain contains "bon".
/// 4. Tap Continue.  The app restarts and lands on the login screen.
final class WelcomeScenario extends BaseTestScenario {
  /// The language code to select (default: Thai / "th").
  final String languageCode;

  /// Substring to match against a server's label or domain (default: "bon").
  final String serverMatch;

  WelcomeScenario(
    super.$, {
    super.next,
    this.languageCode = 'th',
    this.serverMatch = 'bon',
  });

  @override
  Future<bool> waitAndCheckValid() async => true;

  @override
  Future<bool> run() async {
    // ── 1. Verify the welcome screen is showing ───────────────────────────
    expect(
      $(K.welcomeKeys.view).exists,
      isTrue,
      reason: 'Welcome screen not found.',
    );

    // ── 2. Select Thai language ───────────────────────────────────────────
    // The language grid uses raw text labels from supportedLanguages.
    const thaiLabel = 'ภาษาไทย';
    await $.waitUntilVisible(find.text(thaiLabel));
    await $(find.text(thaiLabel)).tap();

    // Give the UI a moment to update the radio selection.
    await $.pumpAndSettle();

    // ── 3. Wait for the server list to load and pick 'bon' ───────────────
    // The server cards show a label + domain. Match on the given substring.
    await $.waitUntilVisible(find.textContaining(serverMatch));
    await $(find.textContaining(serverMatch)).tap();

    await $.pumpAndSettle();

    // ── 4. Tap Continue ──────────────────────────────────────────────────
    // The Continue button is only enabled when both language and server are
    // selected and the view model is not busy.
    await $(K.welcomeKeys.continueButton).tap();

    // After tapping Continue the app calls RestartWidget.restartApp(),
    // which re-runs setupLocator and remounts OhtkApp.  The app should now
    // show the login screen (setupComplete == true).
    await $.pumpAndSettle();

    return true;
  }
}
