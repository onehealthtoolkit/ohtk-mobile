import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base_test_scenario.dart';

/// Patrol scenario that covers the report type selection screen.
///
/// Steps
/// -----
/// 1. Wait for the report type screen to appear.
/// 2. Tap the test mode toggle button (โหมดทดสอบ).
/// 3. Find and tap the specified report type item under the specified category.
/// 4. Verify navigation to the report form screen.
///
/// Chain this after `ReportListScenario`:
/// ```dart
/// ReportListScenario($, next: ReportTypeScenario($, category: 'สุขภาพคน', reportType: 'สัตว์กัด'))
///   ..startFlow();
/// ```
final class ReportTypeScenario extends BaseTestScenario {
  /// The category name to look for (e.g., "สุขภาพคน")
  final String categoryName;

  /// The report type name to select (e.g., "สัตว์กัด")
  final String reportTypeName;

  ReportTypeScenario(
    super.$, {
    super.next,
    required this.categoryName,
    required this.reportTypeName,
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
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    // ── 1. Wait for the report type screen to appear ────────────────────────
    // Look for the "ประเภทรายงาน" title or test mode toggle
    final testModeText = find.text('โหมดทดสอบ');
    
    await $.waitUntilVisible(
      testModeText,
      timeout: const Duration(seconds: 10),
    );

    expect(
      $(testModeText).exists,
      isTrue,
      reason: 'Report type screen not found - expected to see "โหมดทดสอบ"',
    );

    await $.pumpAndSettle();

    // ── 2. Tap the test mode toggle button ──────────────────────────────────
    // The toggle is a button with text "โหมดทดสอบ"
    await $(testModeText).tap();
    
    await $.pumpAndSettle(duration: const Duration(seconds: 1));

    // Verify test mode is now active by checking if the toggle changed appearance
    // (In the UI, it should show a different color/style when active)

    // ── 3. Find and tap the category and report type ────────────────────────
    // First, ensure the category is visible
    final categoryFinder = find.text(categoryName);
    
    await $.waitUntilVisible(
      categoryFinder,
      timeout: const Duration(seconds: 5),
    );

    expect(
      $(categoryFinder).exists,
      isTrue,
      reason: 'Category "$categoryName" not found on report type screen',
    );

    // Scroll to make sure the report type is visible
    await $.scrollUntilVisible(
      finder: find.text(reportTypeName),
      view: find.byType(ListView),
      scrollDirection: AxisDirection.down,
    );

    await $.pumpAndSettle();

    // Find and tap the report type item
    final reportTypeFinder = find.text(reportTypeName);
    
    expect(
      $(reportTypeFinder).exists,
      isTrue,
      reason: 'Report type "$reportTypeName" not found under category "$categoryName"',
    );

    await $(reportTypeFinder).tap();

    await $.pumpAndSettle(duration: const Duration(seconds: 3));

    // ── 4. Verify navigation to report form screen ──────────────────────────
    // Look for form page indicators or form title
    final pageIndicator = find.textContaining('Page');
    
    // Give the form time to load
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    expect(
      $(pageIndicator).exists || $(find.textContaining('ขั้นตอนที่')).exists,
      isTrue,
      reason: 'Did not navigate to report form screen after tapping report type',
    );

    return true;
  }
}
