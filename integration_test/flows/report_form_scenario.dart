import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base_test_scenario.dart';

/// Patrol scenario that fills in a multi-page report form.
///
/// Steps
/// -----
/// **Page 1:**
/// - Fill in age field
/// - Select gender radio button
/// - Select animal type checkbox
/// - Tap next button (ถัดไป)
///
/// **Page 2:**
/// - Select affected area checkboxes
/// - Select wound type radio button
/// - Select owner status radio button
/// - Tap next button (ถัดไป)
///
/// **Page 3:**
/// - (Define additional steps as needed)
///
/// Chain this after `ReportTypeScenario`:
/// ```dart
/// ReportTypeScenario($, next: ReportFormScenario($))
///   ..startFlow();
/// ```
final class ReportFormScenario extends BaseTestScenario {
  /// Configuration for form fields to fill
  final Map<String, dynamic> formData;

  ReportFormScenario(
    super.$, {
    super.next,
    this.formData = const {
      // Page 1
      'age': '18',
      'gender': 'หญิง', // or 'ชาย'
      'animalType': 'แมว', // checkbox value

      // Page 2
      'affectedAreas': ['แขน', 'มือ'], // multiple checkboxes
      'wound': 'ไม่มีเลือดออก', // radio option
      'owner': 'เป็นสัตว์ไม่มีเจ้าของ', // radio option
    },
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
    // PAGE 1: Age, Gender, Animal Type
    // ═══════════════════════════════════════════════════════════════════════

    // Verify we're on page 1 — the Thai page indicator "ขั้นตอนที่ 1 จาก 3"
    expect(
      $(find.text('ขั้นตอนที่ 1 จาก 3')).exists,
      isTrue,
      reason: 'Expected to be on Page 1 of the form (ขั้นตอนที่ 1 จาก 3)',
    );

    // ── Fill in age field ────────────────────────────────────────────────────
    final age = formData['age'] as String? ?? '18';

    // The age field is an IntegerField with a TextEditingController
    // Find it by looking for TextField widgets and entering text
    final ageFieldFinder = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.keyboardType == TextInputType.number,
    );

    // Wait a moment for the field to be ready
    await $.pumpAndSettle(duration: const Duration(milliseconds: 500));

    if ($(ageFieldFinder).exists) {
      // Tap to focus the field first
      await $(ageFieldFinder).tap();
      await $.pumpAndSettle();

      // Enter the age
      await $(ageFieldFinder).enterText(age);
      await $.pumpAndSettle();
    } else {
      // Fallback: scroll and search more broadly
      // Look for any TextField in the first question
      final anyTextField = find.byType(TextField).first;
      if ($(anyTextField).exists) {
        await $(anyTextField).tap();
        await $.pumpAndSettle();
        await $(anyTextField).enterText(age);
        await $.pumpAndSettle();
      }
    }

    // ── Select gender radio button ───────────────────────────────────────────
    final gender = formData['gender'] as String? ?? 'หญิง';

    // Find the gender radio button by text
    final genderOptionFinder = find.text('เพศ$gender'); // e.g., "เพศหญิง"

    if ($(genderOptionFinder).exists) {
      await $(genderOptionFinder).tap();
      await $.pumpAndSettle();
    } else {
      // Try without prefix
      final genderTextFinder = find.text(gender);
      if ($(genderTextFinder).exists) {
        await $(genderTextFinder).tap();
        await $.pumpAndSettle();
      }
    }

    // ── Select animal type checkbox ──────────────────────────────────────────
    final animalType = formData['animalType'] as String? ?? 'แมว';

    final animalTypeFinder = find.text(animalType);

    if ($(animalTypeFinder).exists) {
      await $(animalTypeFinder).tap();
      await $.pumpAndSettle();
    }

    // ── Tap next button (ถัดไป) ──────────────────────────────────────────────
    final nextButtonPage1 = find.text('ถัดไป');

    await $.scrollUntilVisible(
      finder: nextButtonPage1,
      view: find.byType(SingleChildScrollView).first,
      scrollDirection: AxisDirection.down,
      maxScrolls: 30,
    );

    await $.pumpAndSettle();

    expect(
      $(nextButtonPage1).exists,
      isTrue,
      reason: 'Next button (ถัดไป) not found on Page 1',
    );

    await $(nextButtonPage1).tap();
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    // ═══════════════════════════════════════════════════════════════════════
    // PAGE 2: Affected Areas, Wound Type, Owner Status
    // ═══════════════════════════════════════════════════════════════════════

    // Verify we're on page 2 — the Thai page indicator "ขั้นตอนที่ 2 จาก 3"
    expect(
      $(find.text('ขั้นตอนที่ 2 จาก 3')).exists,
      isTrue,
      reason: 'Expected to be on Page 2 of the form (ขั้นตอนที่ 2 จาก 3)',
    );

    // ── Select affected area checkboxes ──────────────────────────────────────
    final affectedAreas =
        formData['affectedAreas'] as List<String>? ?? ['แขน', 'มือ'];

    for (final area in affectedAreas) {
      final areaFinder = find.text(area);

      if ($(areaFinder).exists) {
        await $(areaFinder).tap();
        await $.pumpAndSettle();
      }
    }

    // ── Select wound type radio button ───────────────────────────────────────
    final wound = formData['wound'] as String? ?? 'ไม่มีเลือดออก';

    final woundFinder = find.text(wound);

    if ($(woundFinder).exists) {
      await $(woundFinder).tap();
      await $.pumpAndSettle();
    }

    // ── Select owner status radio button ─────────────────────────────────────
    final owner = formData['owner'] as String? ?? 'เป็นสัตว์ไม่มีเจ้าของ';

    // Scroll to make sure the option is visible
    try {
      await $.scrollUntilVisible(
        finder: find.text(owner),
        view: find.byType(SingleChildScrollView).first,
        scrollDirection: AxisDirection.down,
        maxScrolls: 10,
      );
    } catch (_) {
      print('[WARN] Owner radio "เป็นสัตว์ไม่มีเจ้าของ" not found — skipping');
    }

    final ownerFinder = find.text(owner);

    if ($(ownerFinder).exists) {
      await $(ownerFinder).tap();
      await $.pumpAndSettle();
    }

    // ── Tap next button (ถัดไป) ──────────────────────────────────────────────
    final nextButtonPage2 = find.text('ถัดไป');

    await $.scrollUntilVisible(
      finder: nextButtonPage2,
      view: find.byType(SingleChildScrollView).first,
      scrollDirection: AxisDirection.down,
      maxScrolls: 30,
    );

    await $.pumpAndSettle();

    expect(
      $(nextButtonPage2).exists,
      isTrue,
      reason: 'Next button (ถัดไป) not found on Page 2',
    );

    await $(nextButtonPage2).tap();
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    // ═══════════════════════════════════════════════════════════════════════
    // PAGE 3: Vaccination Status, Incident Cause, Animal Status, Details, Image
    // ═══════════════════════════════════════════════════════════════════════

    // Verify we're on page 3 — the Thai page indicator "ขั้นตอนที่ 3 จาก 3"
    expect(
      $(find.text('ขั้นตอนที่ 3 จาก 3')).exists,
      isTrue,
      reason: 'Expected to be on Page 3 of the form (ขั้นตอนที่ 3 จาก 3)',
    );

    await $.pumpAndSettle();

    // ── Select vaccination status radio button (สัตว์ที่กัดเคยฉีดวัคซีนป้องกันโรคพิษสุนัขบ้าหรือไม่) ──
    final vaccinated = formData['vaccinated'] as String? ?? 'ไม่ทราบ/ไม่แน่ใจ';

    final vaccinatedFinder = find.text(vaccinated);

    if ($(vaccinatedFinder).exists) {
      await $(vaccinatedFinder).tap();
      await $.pumpAndSettle();
    }

    // ── Select incident cause checkbox (สาเหตุที่ถูกกัด) ──────────────────
    final incidentCause =
        formData['incidentCause'] as String? ?? 'เข้าไปกวนตอนกินข้าว';

    // Scroll to make the option visible
    await $.scrollUntilVisible(
      finder: find.text(incidentCause),
      view: find.byType(SingleChildScrollView).first,
      scrollDirection: AxisDirection.down,
      maxScrolls: 30,
    );

    final incidentCauseFinder = find.text(incidentCause);

    if ($(incidentCauseFinder).exists) {
      await $(incidentCauseFinder).tap();
      await $.pumpAndSettle();
    }

    // ── Select animal alive status radio button (สัตว์ที่กัดยังมีชีวิตอยู่หรือไม่) ──
    final stillAlive = formData['stillAlive'] as String? ?? 'ยังมีชีวิตอยู่';

    // Scroll to ensure visibility
    await $.scrollUntilVisible(
      finder: find.text(stillAlive),
      view: find.byType(SingleChildScrollView).first,
      scrollDirection: AxisDirection.down,
      maxScrolls: 30,
    );

    final stillAliveFinder = find.text(stillAlive);

    if ($(stillAliveFinder).exists) {
      await $(stillAliveFinder).tap();
      await $.pumpAndSettle();
    }

    // ── Fill in more details textarea (รายละเอียดเพิ่มเติม) ─────────────────
    final moreDetail =
        formData['moreDetail'] as String? ?? 'ทดสอบรายละเอียดเพิ่มเติม';

    // Find the textarea field — it's a multiline TextField with:
    //   - keyboardType: TextInputType.multiline
    //   - maxLines: null (unlimited)
    final textareaFinder =
        find.byWidgetPredicate((widget) => widget is TextField);

    try {
      await $.scrollUntilVisible(
        finder: textareaFinder,
        scrollDirection: AxisDirection.down,
      );

      await $(textareaFinder).last.tap();
      await $.pumpAndSettle();
      await $(textareaFinder).last.enterText(moreDetail);
      await $.pumpAndSettle();
    } catch (_) {
      // Textarea not found (form may not have this field, or it's unreachable
      // on a small screen). The test proceeds without filling it;
      // the review/submit flow accepts partial data.
      print(
          '[WARN] Textarea field not found on Page 3 — skipping moreDetail fill');
    }

    // ── Upload image (ภาพถ่ายสัตว์ที่กัด/แผลที่ถูกกัด) ─────────────────────
    // Look for the ADD button for images
    final addImageButton = find.text('ADD');
    var addWasTapped = false;

    try {
      await $.scrollUntilVisible(
        finder: addImageButton,
        view: find.byType(SingleChildScrollView).first,
        scrollDirection: AxisDirection.down,
      );

      if ($(addImageButton).exists) {
        await $(addImageButton).tap();
        addWasTapped = true;
        await $.pumpAndSettle(duration: const Duration(seconds: 2));

        // A modal bottom sheet should appear with camera/gallery options.
        // On the real device the options are "- Pick from gallery" / "- Take a photo".
        // Attempt to tap one if found.
        var imageOption = find.textContaining('Pick from gallery');
        if (!$(imageOption).exists) {
          imageOption = find.textContaining('เลือกรูปภาพ');
        }
        if (!$(imageOption).exists) {
          imageOption = find.textContaining('Take a photo');
        }
        if (!$(imageOption).exists) {
          imageOption = find.textContaining('ถ่ายรูป');
        }

        if ($(imageOption).exists) {
          await $(imageOption).tap();
          await $.pumpAndSettle(duration: const Duration(seconds: 3));
        }
      }
    } catch (_) {
      print(
          '[WARN] ADD image button interaction failed — skipping image upload');
    }

    // If ADD was tapped and a bottom sheet modal is still open (no image
    // option was tapped or gallery/camera didn't open), dismiss it via
    // system back button so it doesn't block the review button below.
    if (addWasTapped) {
      try {
        await $.native.pressBack();
        await $.pumpAndSettle();
      } catch (_) {
        print('[WARN] Could not dismiss bottom sheet — continuing');
      }
    }

    // ── Tap review/done button (ตรวจสอบ) ─────────────────────────────────────
    final reviewButton = find.text('ตรวจสอบ');

    try {
      await $.scrollUntilVisible(
        finder: reviewButton,
        view: find.byType(SingleChildScrollView).first,
        scrollDirection: AxisDirection.down,
      );
    } catch (_) {
      print('[WARN] Review button (ตรวจสอบ) not found — cannot proceed');
      rethrow;
    }

    await $.pumpAndSettle();

    expect(
      $(reviewButton).exists,
      isTrue,
      reason: 'Review button (ตรวจสอบ) not found on Page 3',
    );

    await $(reviewButton).tap();
    await $.pumpAndSettle(duration: const Duration(seconds: 3));

    // ═══════════════════════════════════════════════════════════════════════
    // CONFIRMATION PAGE: Review and Submit
    // ═══════════════════════════════════════════════════════════════════════

    // Wait for the confirmation page to load
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    // Look for the submit button (ส่งรายงาน)
    final submitButton = find.text('ส่งรายงาน');

    // Scroll to ensure the submit button is visible
    // try {
    //   await $.scrollUntilVisible(
    //     finder: submitButton,
    //     view: find.byType(SingleChildScrollView).first,
    //     scrollDirection: AxisDirection.down,
    //   );
    // } catch (_) {
    //   print('[WARN] Submit button (ส่งรายงาน) not found — cannot proceed');
    //   rethrow;
    // }

    // await $.pumpAndSettle();

    expect(
      $(submitButton).exists,
      isTrue,
      reason: 'Submit button (ส่งรายงาน) not found on confirmation page',
    );

    // Tap the submit button
    await $(submitButton).tap();

    // ═══════════════════════════════════════════════════════════════════════
    // POST-SUBMISSION: Wait for success overlay, then verify navigation back
    // to the report list screen.
    //
    // The app flow:
    //   1. SubmitSuccessOverlay appears (~200ms animation)
    //   2. Shows "ส่งรายงานสำเร็จ" with check icon
    //   3. Auto-dismisses after ~1080ms (280ms card + 800ms hold)
    //   4. Navigator.pop() fires → back to report list (/reports)
    // ═══════════════════════════════════════════════════════════════════════

    // Wait for the success overlay dialog to appear.
    // Using waitUntilVisible instead of pumpAndSettle+expect because the
    // submission involves an async network request that pumpAndSettle cannot
    // wait for — waitUntilVisible actively pumps frames until the widget
    // becomes visible.
    await $.waitUntilVisible(
      find.text('ส่งรายงานสำเร็จ'),
      timeout: const Duration(seconds: 10),
    );

    // Allow time for the overlay to auto-dismiss and Navigator.pop to fire
    await $.pumpAndSettle(duration: const Duration(seconds: 4));

    // Verify we navigated back to the report list screen
    // The report list shows tab labels "รายงานทั้งหมด" and "รายงานของฉัน"
    final allReportsText = find.text('รายงานทั้งหมด');
    final myReportsText = find.text('รายงานของฉัน');
    await $.waitUntilVisible(
      allReportsText,
      timeout: const Duration(seconds: 5),
    );

    expect(
      $(allReportsText).exists || $(myReportsText).exists,
      isTrue,
      reason: 'After successful submission, expected to navigate back to the '
          'report list screen, but neither "รายงานทั้งหมด" nor '
          '"รายงานของฉัน" tab labels were found.',
    );

    return true;
  }
}
