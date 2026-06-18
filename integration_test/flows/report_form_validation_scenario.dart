import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base_test_scenario.dart';

/// Patrol scenario that tests form validation on the report form.
///
/// Steps
/// -----
/// 1. Wait for report form Page 1 to appear
/// 2. Try to tap "ถัดไป" (Next) WITHOUT filling required fields
/// 3. Verify validation snackbar appears: "Invalid form value"
/// 4. Verify field-level error messages appear
/// 5. Fill in one required field (age)
/// 6. Try to proceed - should still fail (other required fields missing)
/// 7. Fill all required fields
/// 8. Successfully navigate to Page 2
///
/// Chain this after `ReportTypeScenario`:
/// ```dart
/// ReportTypeScenario($, next: ReportFormValidationScenario($))
///   ..startFlow();
/// ```
final class ReportFormValidationScenario extends BaseTestScenario {
  ReportFormValidationScenario(
    super.$, {
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
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    // ═══════════════════════════════════════════════════════════════════════
    // PAGE 1: Verify we're on the form page
    // ═══════════════════════════════════════════════════════════════════════

    // Verify we're on page 1 — the Thai page indicator "ขั้นตอนที่ 1 จาก 3"
    expect(
      $(find.text('ขั้นตอนที่ 1 จาก 3')).exists,
      isTrue,
      reason: 'Page 1 indicator not found',
    );

    // ═══════════════════════════════════════════════════════════════════════
    // TEST 1: Try to proceed WITHOUT filling required fields
    // ═══════════════════════════════════════════════════════════════════════

    // Find the next button (ถัดไป)
    final nextButton = find.text('ถัดไป');
    
    // Scroll to the next button to ensure it's visible
    await $.scrollUntilVisible(
      finder: nextButton,
      view: find.byType(SingleChildScrollView).first,
      scrollDirection: AxisDirection.down,
      maxScrolls: 30,
    );

    await $.pumpAndSettle();

    expect(
      $(nextButton).exists,
      isTrue,
      reason: 'Next button (ถัดไป) not found on Page 1',
    );

    // Tap the next button WITHOUT filling any fields
    await $(nextButton).tap();
    
    // Wait for validation to trigger and snackbar to appear
    // Important: The snackbar only shows for 1000ms, so we need to check quickly
    await $.pumpAndSettle(duration: const Duration(milliseconds: 300));

    // ── Verify validation snackbar appears ───────────────────────────────────
    // The Thai validation message is "ค่าที่ป้อนไม่ถูกต้อง" (Invalid form value)
    // The snackbar duration is only 1000ms, so we must check immediately
    final validationSnackbar = find.text('ค่าที่ป้อนไม่ถูกต้อง');
    
    expect(
      $(validationSnackbar).exists,
      isTrue,
      reason: 'Validation snackbar "ค่าที่ป้อนไม่ถูกต้อง" not shown when '
          'submitting empty required fields',
    );

    // Wait for snackbar to auto-dismiss
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    // ── Verify field-level error messages appear ─────────────────────────────
    // The Thai error message is "กรุณาระบุค่า" (Please specify a value)
    final requiredErrorMessage = find.textContaining('กรุณาระบุค่า');
    
    expect(
      $(requiredErrorMessage).exists,
      isTrue,
      reason: 'Required field error message "กรุณาระบุค่า" not shown on '
          'empty required fields',
    );

    // Verify we're still on Page 1 (navigation should NOT have occurred)
    expect(
      $(find.text('ขั้นตอนที่ 1 จาก 3')).exists,
      isTrue,
      reason: 'Should still be on Page 1 after validation failure, but page '
          'indicator not found',
    );

    // ═══════════════════════════════════════════════════════════════════════
    // TEST 2: Fill ONE required field and try again (should still fail)
    // ═══════════════════════════════════════════════════════════════════════

    // Scroll back to top to access the age field
    await $.scrollUntilVisible(
      finder: find.text('ขั้นตอนที่ 1 จาก 3'),
      view: find.byType(SingleChildScrollView).first,
      scrollDirection: AxisDirection.up,
      maxScrolls: 30,
    );

    await $.pumpAndSettle();

    // Fill in the age field only
    final ageFieldFinder = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.keyboardType == TextInputType.number,
    );

    await $.waitUntilVisible(
      ageFieldFinder,
      timeout: const Duration(seconds: 3),
    );

    if ($(ageFieldFinder).exists) {
      await $(ageFieldFinder).tap();
      await $.pumpAndSettle();
      await $(ageFieldFinder).enterText('18');
      await $.pumpAndSettle();
    }

    // Scroll to next button again
    await $.scrollUntilVisible(
      finder: nextButton,
      view: find.byType(SingleChildScrollView).first,
      scrollDirection: AxisDirection.down,
      maxScrolls: 30,
    );

    await $.pumpAndSettle();

    // Try to proceed (should still fail - gender and animal type still missing)
    await $(nextButton).tap();
    // Wait for validation to trigger (snackbar shows for only 1000ms, so check quickly)
    await $.pumpAndSettle(duration: const Duration(milliseconds: 300));

    // Verify validation snackbar appears again
    expect(
      $(validationSnackbar).exists,
      isTrue,
      reason: 'Validation snackbar should still appear when some required '
          'fields are missing',
    );

    // Wait for snackbar to dismiss
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    // Verify still on Page 1
    expect(
      $(find.text('ขั้นตอนที่ 1 จาก 3')).exists,
      isTrue,
      reason: 'Should still be on Page 1 after partial validation failure',
    );

    // ═══════════════════════════════════════════════════════════════════════
    // TEST 3: Fill ALL required fields and verify successful navigation
    // ═══════════════════════════════════════════════════════════════════════

    // Scroll back up to access gender field
    await $.scrollUntilVisible(
      finder: find.text('ขั้นตอนที่ 1 จาก 3'),
      view: find.byType(SingleChildScrollView).first,
      scrollDirection: AxisDirection.up,
      maxScrolls: 30,
    );

    await $.pumpAndSettle();

    // Select gender radio button (หญิง - Female)
    // Try with prefix first (เพศหญิง), then without prefix (หญิง)
    final genderOptionFinder = find.text('เพศหญิง');
    
    if ($(genderOptionFinder).exists) {
      await $(genderOptionFinder).tap();
      await $.pumpAndSettle();
    } else {
      // Try without prefix
      final genderTextFinder = find.text('หญิง');
      if ($(genderTextFinder).exists) {
        await $(genderTextFinder).tap();
        await $.pumpAndSettle();
      }
    }

    // Select animal type checkbox (แมว - Cat)
    final animalTypeFinder = find.text('แมว');
    
    if ($(animalTypeFinder).exists) {
      await $(animalTypeFinder).tap();
      await $.pumpAndSettle();
    }

    // Scroll to next button
    await $.scrollUntilVisible(
      finder: nextButton,
      view: find.byType(SingleChildScrollView).first,
      scrollDirection: AxisDirection.down,
      maxScrolls: 30,
    );

    await $.pumpAndSettle();

    // Now try to proceed with all required fields filled
    await $(nextButton).tap();

    // Wait for page 2 to appear
    final page2Indicator = find.text('ขั้นตอนที่ 2 จาก 3');
    await $.waitUntilVisible(
      page2Indicator,
      timeout: const Duration(seconds: 3),
    );

    // ── Verify successful navigation to Page 2 ───────────────────────────────
    expect(
      $(page2Indicator).exists,
      isTrue,
      reason: 'After filling all required fields, should navigate to Page 2, '
          'but page 2 indicator not found',
    );

    // Verify validation snackbar did NOT appear on successful validation
    expect(
      $(validationSnackbar).exists,
      isFalse,
      reason: 'Validation snackbar should NOT appear when all required '
          'fields are filled correctly',
    );

    return true;
  }
}
