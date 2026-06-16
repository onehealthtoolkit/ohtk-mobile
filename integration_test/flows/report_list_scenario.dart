import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base_test_scenario.dart';

/// Patrol scenario that covers the report list screen flow.
///
/// Steps
/// -----
/// 1. Wait for the report list/home screen to appear (after successful login).
/// 2. Verify the new report button is present.
/// 3. Tap the new report button (with Thai label "รายงานใหม่").
/// 4. Wait for navigation to the report types screen.
///
/// Chain this after `LoginSuccessScenario`:
/// ```dart
/// LoginSuccessScenario($, username: 'u', password: 'p', 
///   next: ReportListScenario($))
///   ..startFlow();
/// ```
final class ReportListScenario extends BaseTestScenario {
  ReportListScenario(
    super.$, {
    super.next,
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
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    // ── 1. Wait for the report list screen to appear ────────────────────────
    // The report home view should be showing after successful login
    // We'll look for common indicators like the tab labels or the FAB
    
    // Wait for either the Thai "รายงานทั้งหมด" (All Reports) text or the 
    // new report button to appear
    final allReportsText = find.text('รายงานทั้งหมด');
    final myReportsText = find.text('รายงานของฉัน');
    
    // Wait for one of the tab texts to appear
    await $.waitUntilVisible(
      allReportsText,
      timeout: const Duration(seconds: 1),
    );

    expect(
      $(allReportsText).exists || $(myReportsText).exists,
      isTrue,
      reason: 'Report list screen not found after login',
    );

    // ── 2. Find and verify the new report button ────────────────────────────
    // The button has the Thai text "รายงานใหม่" (New Report)
    final newReportButtonFinder = find.byWidgetPredicate(
      (widget) =>
          widget is FloatingActionButton &&
          widget.child != null &&
          _containsNewReportText(widget.child!),
    );

    // Also try finding by text directly
    final newReportTextFinder = find.text('รายงานใหม่');

    await $.pumpAndSettle();

    // Verify at least one of the finders can locate the button
    expect(
      $(newReportTextFinder).exists || $(newReportButtonFinder).exists,
      isTrue,
      reason: 'New report button (รายงานใหม่) not found on the report list screen',
    );

    // ── 3. Tap the new report button ────────────────────────────────────────
    // Try to tap using the text finder first, fall back to widget finder
    if ($(newReportTextFinder).exists) {
      await $(newReportTextFinder).tap();
    } else {
      await $(newReportButtonFinder).tap();
    }

    // ── 4. Verify navigation to report types screen ─────────────────────────
    // After tapping the new report button, the app should navigate to the
    // report type selection screen which shows "โหมดทดสอบ" toggle button.
    // Give the navigation time to complete
    await $.pumpAndSettle(duration: const Duration(seconds: 3));

    // The report type screen should now be showing with the test mode toggle
    final testModeText = find.text('โหมดทดสอบ');

    expect(
      $(testModeText).exists,
      isTrue,
      reason: "After tapping the new report button, expected to navigate to "
          "the report type selection screen, but the test mode toggle "
          "(\\""โหมดทดสอบ\\"") was not found.",
    );

    return true;
  }

  /// Helper to check if a widget tree contains the new report text
  bool _containsNewReportText(Widget widget) {
    if (widget is Text) {
      final data = widget.data;
      if (data != null && data.contains('รายงานใหม่')) {
        return true;
      }
    }
    
    // Check for widgets that might wrap the text
    if (widget is Row || widget is Column) {
      // We can't easily traverse children here, so we'll rely on the direct text finder
      return false;
    }
    
    return false;
  }
}
