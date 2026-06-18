import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base_test_scenario.dart';

/// Patrol scenario that verifies the test report appears in the report list
/// after submission, and checks that the test flag is visible in the detail view.
///
/// Steps
/// -----
/// 1. Wait for report list to appear (should already be there after submission)
/// 2. Find the newly created test report in the list (by report type name)
/// 3. Tap on the report to open detail view
/// 4. Verify the test flag pill ("ทดสอบ") is visible in the detail view
/// 5. Navigate back to the report list
///
/// Chain this after `ReportFormScenario`:
/// ```dart
/// ReportFormScenario($, ..., next: VerifyTestReportScenario($))
///   ..startFlow();
/// ```
final class VerifyTestReportScenario extends BaseTestScenario {
  /// The report type name to look for in the list.
  /// This should match the report type selected in ReportTypeScenario.
  final String reportTypeName;

  VerifyTestReportScenario(
    super.$, {
    required this.reportTypeName,
    super.next,
  });

  // ---------------------------------------------------------------------------
  // Guard — always run the scenario
  // ---------------------------------------------------------------------------

  @override
  Future<bool> waitAndCheckValid() async => true;

  // ---------------------------------------------------------------------------
  // Test logic
  // ---------------------------------------------------------------------------

  @override
  Future<bool> run() async {
    // Wait a moment for the list to refresh with the new report
    await $.pumpAndSettle(duration: const Duration(seconds: 1));

    // ═══════════════════════════════════════════════════════════════════════
    // STEP 1: Verify we're on the report list screen
    // ═══════════════════════════════════════════════════════════════════════

    // The report list shows tab labels "รายงานทั้งหมด" and "รายงานของฉัน"
    final allReportsText = find.text('รายงานทั้งหมด');
    final myReportsText = find.text('รายงานของฉัน');

    await $.waitUntilVisible(
      allReportsText,
      timeout: const Duration(seconds: 3),
    );

    expect(
      $(allReportsText).exists || $(myReportsText).exists,
      isTrue,
      reason: 'Expected to be on the report list screen, but neither '
          '"รายงานทั้งหมด" nor "รายงานของฉัน" tab labels were found.',
    );

    // ═══════════════════════════════════════════════════════════════════════
    // STEP 2: Find the newly created test report in the list
    // ═══════════════════════════════════════════════════════════════════════

    // Look for the report type name in the list
    // The report card shows the report type name as the title
    final reportCardFinder = find.text(reportTypeName);

    // The report should appear at the top of the list (most recent)
    // If it's not immediately visible, scroll down to find it
    if (!$(reportCardFinder).exists) {
      try {
        await $.scrollUntilVisible(
          finder: reportCardFinder,
          view: find.byType(ListView).first,
          scrollDirection: AxisDirection.down,
          maxScrolls: 10,
        );
      } catch (e) {
        // If scrolling fails, the report might not have been created
        // This is acceptable for now - we'll fail the assertion below
        print('[WARN] Could not find report "$reportTypeName" in the list');
      }
    }

    expect(
      $(reportCardFinder).exists,
      isTrue,
      reason: 'Expected to find the newly created test report "$reportTypeName" '
          'in the report list, but it was not found.',
    );

    // ═══════════════════════════════════════════════════════════════════════
    // STEP 3: Tap on the report to open detail view
    // ═══════════════════════════════════════════════════════════════════════

    await $(reportCardFinder).tap();

    // Wait for the detail view to load
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    // ═══════════════════════════════════════════════════════════════════════
    // STEP 4: Verify the test flag pill is visible in the detail view
    // ═══════════════════════════════════════════════════════════════════════

    // The test flag pill shows the Thai text "ทดสอบ" (testTag)
    final testFlagPill = find.text('ทดสอบ');

    // Scroll to find the test flag if it's not immediately visible
    // (it should be near the top of the detail view)
    if (!$(testFlagPill).exists) {
      try {
        await $.scrollUntilVisible(
          finder: testFlagPill,
          view: find.byType(SingleChildScrollView).first,
          scrollDirection: AxisDirection.down,
          maxScrolls: 5,
        );
      } catch (e) {
        // If scrolling fails, the pill might not be rendered
        print('[WARN] Could not find test flag pill "ทดสอบ" in detail view');
      }
    }

    expect(
      $(testFlagPill).exists,
      isTrue,
      reason: 'Expected to find the test flag pill "ทดสอบ" in the report '
          'detail view, but it was not found. This indicates the test flag '
          'was not properly set on the submitted report.',
    );

    // ═══════════════════════════════════════════════════════════════════════
    // STEP 5: Navigate back to the report list
    // ═══════════════════════════════════════════════════════════════════════

    // Use the native back button to navigate back
    await $.native.pressBack();

    // Wait for navigation to complete
    await $.pumpAndSettle(duration: const Duration(seconds: 1));

    // Verify we're back on the report list
    await $.waitUntilVisible(
      allReportsText,
      timeout: const Duration(seconds: 3),
    );

    expect(
      $(allReportsText).exists || $(myReportsText).exists,
      isTrue,
      reason: 'Expected to navigate back to the report list screen after '
          'viewing the test report detail, but tab labels were not found.',
    );

    return true;
  }
}
