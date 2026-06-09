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

    // Verify we're on page 1
    final page1Indicator = find.textContaining('Page 1');
    expect(
      $(page1Indicator).exists || $(find.text('ขั้นตอนที่ 1 จาก 3')).exists,
      isTrue,
      reason: 'Expected to be on Page 1 of the form',
    );

    // ── Fill in age field ────────────────────────────────────────────────────
    final age = formData['age'] as String? ?? '18';
    
    // The age field is an IntegerField with a TextEditingController
    // Find it by looking for TextField widgets and entering text
    final ageFieldFinder = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.keyboardType == TextInputType.number,
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

    // Verify we're on page 2
    final page2Indicator = find.textContaining('Page 2');
    expect(
      $(page2Indicator).exists || $(find.text('ขั้นตอนที่ 2 จาก 3')).exists,
      isTrue,
      reason: 'Expected to be on Page 2 of the form after tapping next',
    );

    // ── Select affected area checkboxes ──────────────────────────────────────
    final affectedAreas = formData['affectedAreas'] as List<String>? ?? ['แขน', 'มือ'];
    
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
    await $.scrollUntilVisible(
      finder: find.text(owner),
      view: find.byType(SingleChildScrollView).first,
      scrollDirection: AxisDirection.down,
    );

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

    // Verify we're on page 3
    final page3Indicator = find.textContaining('Page 3');
    expect(
      $(page3Indicator).exists || $(find.text('ขั้นตอนที่ 3 จาก 3')).exists,
      isTrue,
      reason: 'Expected to be on Page 3 of the form after tapping next',
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
    final incidentCause = formData['incidentCause'] as String? ?? 'เข้าไปกวนตอนกินข้าว';
    
    // Scroll to make the option visible
    await $.scrollUntilVisible(
      finder: find.text(incidentCause),
      view: find.byType(SingleChildScrollView).first,
      scrollDirection: AxisDirection.down,
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
    );

    final stillAliveFinder = find.text(stillAlive);
    
    if ($(stillAliveFinder).exists) {
      await $(stillAliveFinder).tap();
      await $.pumpAndSettle();
    }

    // ── Fill in more details textarea (รายละเอียดเพิ่มเติม) ─────────────────
    final moreDetail = formData['moreDetail'] as String? ?? 'ทดสอบรายละเอียดเพิ่มเติม';
    
    // Find the textarea field - it should be a TextField with multiline
    final textareaFinder = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          (widget.keyboardType == TextInputType.multiline ||
              widget.maxLines == null),
    );

    await $.scrollUntilVisible(
      finder: textareaFinder,
      view: find.byType(SingleChildScrollView).first,
      scrollDirection: AxisDirection.down,
    );

    if ($(textareaFinder).exists) {
      await $(textareaFinder).tap();
      await $.pumpAndSettle();
      await $(textareaFinder).enterText(moreDetail);
      await $.pumpAndSettle();
    }

    // ── Upload image (ภาพถ่ายสัตว์ที่กัด/แผลที่ถูกกัด) ─────────────────────
    // Look for the ADD button for images
    final addImageButton = find.text('ADD');
    
    await $.scrollUntilVisible(
      finder: addImageButton,
      view: find.byType(SingleChildScrollView).first,
      scrollDirection: AxisDirection.down,
    );

    if ($(addImageButton).exists) {
      await $(addImageButton).tap();
      await $.pumpAndSettle(duration: const Duration(seconds: 2));
      
      // A modal bottom sheet should appear with camera/gallery options
      // Look for camera option and tap it
      var cameraOption = find.textContaining('Camera');
      if (!$(cameraOption).exists) {
        cameraOption = find.textContaining('กล้อง');
      }
      
      if ($(cameraOption).exists) {
        await $(cameraOption).tap();
        await $.pumpAndSettle(duration: const Duration(seconds: 3));
        
        // The camera should open - in test environment, this might be simulated
        // Tap the capture button if available
        // Note: Camera interaction in integration tests is tricky
        // The test might need to handle permissions and camera UI differently
      }
    }

    // ── Tap review/done button (ตรวจสอบ) ─────────────────────────────────────
    final reviewButton = find.text('ตรวจสอบ');
    
    await $.scrollUntilVisible(
      finder: reviewButton,
      view: find.byType(SingleChildScrollView).first,
      scrollDirection: AxisDirection.down,
    );

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
    await $.scrollUntilVisible(
      finder: submitButton,
      view: find.byType(SingleChildScrollView).first,
      scrollDirection: AxisDirection.down,
    );

    await $.pumpAndSettle();

    expect(
      $(submitButton).exists,
      isTrue,
      reason: 'Submit button (ส่งรายงาน) not found on confirmation page',
    );

    // Tap the submit button
    await $(submitButton).tap();
    await $.pumpAndSettle(duration: const Duration(seconds: 5));

    // After submission, we should navigate away or see a success message
    // The test completes here after successful submission

    return true;
  }
}
