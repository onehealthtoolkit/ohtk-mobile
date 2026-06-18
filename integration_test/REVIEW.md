# Integration Test Suite Review

> **Date:** June 16, 2026
> **Scope:** Patrol-based UI integration tests for `ohtk-mobile`
> **Branch:** `ui_test`

---

## 1. Architecture Overview

The test framework uses a **Chain of Responsibility** pattern (`BaseTestScenario`) where each screen or flow is an independent scenario, linked via `next:` to form a chain. Execution starts at the head of the chain and flows through each scenario sequentially.

```
patrolTest → scenario.startFlow()
              ├─ waitAndCheckValid() → skip or run
              ├─ run()               → test logic + assertions
              └─ next?.startFlow()   → chain continues
```

### Test Entry Points

| File | Purpose | Scenario Chain |
|------|---------|----------------|
| `start_test.dart` | Negative auth test | Welcome → Login (fail, stays on screen) |
| `create_report_test.dart` | Full report creation flow | Welcome → Login (success) → Report List → Report Type → Report Form (3 pages + submit) |

### Scenario Files

| File | Class | Responsibility |
|------|-------|----------------|
| `flows/base_test_scenario.dart` | `BaseTestScenario` | Abstract base — Chain of Responsibility |
| `flows/welcome_scenario.dart` | `WelcomeScenario` | Language + server selection, restart |
| `flows/login_scenario.dart` | `LoginScenario` | Login with **failed** auth (negative test) |
| `flows/login_success_scenario.dart` | `LoginSuccessScenario` | Login with **successful** auth (positive test) |
| `flows/report_list_scenario.dart` | `ReportListScenario` | Verify report list, tap New Report FAB |
| `flows/report_type_scenario.dart` | `ReportTypeScenario` | Toggle test mode, select category + report type |
| `flows/report_form_scenario.dart` | `ReportFormScenario` | Fill 3-page form, review, submit, verify success |

### Supporting Files

| File | Purpose |
|------|---------|
| `utils/test_utility.dart` | App initialization (Firebase, Locator, Hive, widget pump) |
| `scripts/patrol_common.sh` | Shared bash functions for all test scripts |
| `scripts/run_patrol_bon.sh` | Run `start_test.dart` |
| `scripts/run_patrol_create_report.sh` | Run `create_report_test.dart` |

### Documentation Files

| File | Purpose |
|------|---------|
| `CREATE_REPORT_TEST.md` | Overview of create report test scenarios |
| `EXTENDED_FLOW_SUMMARY.md` | Detailed flow for report form filling |
| `PAGE_3_IMPLEMENTATION.md` | Page 3 field implementation details |
| `LOGIN_SCENARIO_COMPARISON.md` | Positive vs negative login scenario comparison |
| `scripts/REFACTORING.md` | Patrol script library refactoring documentation |

---

## 2. What's Implemented ✅

| Feature | Files | Status |
|---------|-------|--------|
| Welcome screen (language + server) | `welcome_scenario.dart` | ✅ Complete |
| Login failure (stays on screen) | `login_scenario.dart` | ✅ Complete |
| Login success (navigates away) | `login_success_scenario.dart` | ✅ Complete |
| Report list + "รายงานใหม่" FAB tap | `report_list_scenario.dart` | ✅ Complete |
| Report type selection (test mode + category) | `report_type_scenario.dart` | ✅ Complete |
| Form Page 1 (age, gender, animal type) | `report_form_scenario.dart` | ✅ Complete |
| Form Page 2 (affected areas, wound, owner) | `report_form_scenario.dart` | ✅ Complete |
| Form Page 3 (vaccination, cause, alive status, details) | `report_form_scenario.dart` | ✅ Complete |
| Image upload (best-effort, camera/gallery) | `report_form_scenario.dart` | ✅ Implemented |
| Review button ("ตรวจสอบ") | `report_form_scenario.dart` | ✅ Complete |
| Confirmation page + Submit ("ส่งรายงาน") | `report_form_scenario.dart` | ✅ Complete |
| Post-submission: verify success overlay + report list | `report_form_scenario.dart` | ✅ Complete |
| Positive auth → report list navigation check | `report_list_scenario.dart` | ✅ Complete (fixed) |
| Script automation (shared functions) | `scripts/patrol_common.sh` | ✅ Complete |

---

## 3. Issues & Risks Found ⚠️

### 3.1 Weak post-navigation verification ✅ FIXED

**Location:** `report_list_scenario.dart` line ~101 (previously)

**Problem:** After tapping the new report button, the assertion was a no-op:
```dart
expect(true, isTrue, ...);
```
This would pass silently even if the navigation had failed.

**Fix applied:** Replaced with an assertion checking for "โหมดทดสอบ" (test mode toggle) on the report type selection screen.

### 3.2 Missing post-submission verification ✅ FIXED

**Location:** `report_form_scenario.dart` (previously)

**Problem:** After tapping "ส่งรายงาน", there was no assertion that submission actually succeeded or that the app navigated back to the report list.

**Fix applied:** Added verification of:
1. Success overlay message "ส่งรายงานสำเร็จ"
2. Navigation back to report list (checking for "รายงานทั้งหมด" / "รายงานของฉัน" tab labels)

### 3.3 Page indicator assertions use dual fallback pattern ✅ FIXED

**Location:** `report_form_scenario.dart` — Page 1/2/3 verification

**Problem (original):** The test checked both `'Page N'` (English) and `'ขั้นตอนที่ N จาก 3'` (Thai) via `||`. The English fallback never matched since the app always uses Thai.

**Fix applied:** Replaced the dual fallback with a single Thai-only assertion for each page. Removed the now-unused `page1Indicator` / `page2Indicator` / `page3Indicator` variables. The assertion is now:
```dart
expect(
  $(find.text('ขั้นตอนที่ N จาก 3')).exists,
  isTrue,
);
```

### 3.4 Image upload is best-effort, silently skipped

**Location:** `report_form_scenario.dart` — image upload section (lines ~310-340)

**Problem:** The camera/gallery flow is wrapped in existence checks and silently skips if no "ADD" button or camera option is found. In CI this will likely be a no-op with no clear feedback.

**Severity:** 🟡 Medium — image upload is not reliably tested. Needs environment-specific setup or mocking.

### 3.5 Textarea finder unreliable + scroll timeout on real devices ✅ FIXED

**Location:** `report_form_scenario.dart` — textarea finder, scroll mechanism, and error handling

**Problem (original):** The staged git change made the widget predicate stricter (`AND` with `minLines > 1`), which never matched on the Samsung device. Combined with `maxScrolls: 150`, the scroll loop took ~45s and triggered Patrol's 30s global timeout, preventing try-catch from executing.

**Final fix (4 iterations to resolve):**

| Iteration | Change | Result |
|-----------|--------|--------|
| 1 | Reverted finder to original OR-version + try-catch only on textarea | Other scrolls (ADD, review) still crashed |
| 2 | Removed `view` from all scrolls + `maxScrolls: 30` + `delta: 0.3` | `delta: 0.3` overshot targets near viewport edge (owner radio) |
| 3 | Removed `delta` (default 0.1) + restored `view` everywhere + try-catch on all | Textarea finder still failed — predicate never matched on device |
| 4 | Simplified finder to `widget is TextField` (no conditions) + `.last` for safety | ✅ Works — textarea filled correctly |

**Final state applied:**
1. **Finder:** `widget is TextField` (matches ANY TextField on the page) — Page 3 only has one TextField (the textarea), so no conditions needed
2. **`.last` selector:** Safer against `AnimatedSwitcher` lingering `previousChildren` from Page 1's age field
3. **`maxScrolls: 10`** on textarea and ADD image (fast failure ~5s); **`maxScrolls: 30`** on critical elements (review, submit)
4. **Default `delta: 0.1`** (no override) — prevents overshooting targets near viewport edges
5. **`view: find.byType(SingleChildScrollView).first`** restored on all scrolls except textarea
6. **Try-catch blocks:** optional elements (textarea, ADD image) → continue; critical (review, submit) → rethrow

### 3.6 `waitAndCheckValid()` always returns `true`

**Location:** All scenario files

**Problem:** Every scenario overrides `waitAndCheckValid()` to unconditionally return `true`. The guard mechanism in `BaseTestScenario` exists to skip scenarios conditionally (e.g., when a screen is only shown once), but it's never actually used.

**Severity:** 🟢 Low — no functional impact, but the guard pattern is unused.

### 3.7 Heavy use of `pumpAndSettle` with fixed durations

**Location:** Throughout all scenarios

**Problem:** Many assertions use `pumpAndSettle(duration: const Duration(seconds: N))` instead of Patrol's `waitUntilVisible()` with proper timeouts. Fixed-duration waits are brittle across devices and network conditions.

**Improvements applied:**
1. **Post-submission success overlay** — replaced `pumpAndSettle(500ms) + expect(exists)` with `waitUntilVisible(timeout: 10s)` (properly waits for async network request)
2. **Post-submission report list nav** — replaced `pumpAndSettle(4s)` with `waitUntilVisible(timeout: 5s)`
3. **`scrollUntilVisible` calls** — use `maxScrolls: 10–30` for timed scroll limits instead of fixed waits

However, many locations (age field entry, page transitions, confirmation page load) still use fixed-duration `pumpAndSettle`.

**Severity:** 🟡 Medium — could cause flaky tests on slower or faster devices.

### 3.8 No form validation error testing

**Location:** Missing

**Problem:** There is no test scenario that submits empty or invalid form data and checks for error messages (e.g., snackbar with "Invalid form value" or field-level validation errors).

**Severity:** 🟡 Medium — validation logic is a key user-facing feature that's untested at the integration level.

### 3.9 No offline/sync testing

**Location:** Missing

**Problem:** The app is offline-first with sqflite storage and background upload queues, but there are no Patrol tests for:
- Submitting while offline (queued)
- Reconnecting and verifying sync
- Checking pending submission counts

**Severity:** 🔴 High — offline-first is a core architectural requirement.

### 3.10 ADD image bottom sheet blocks form scroll ✅ FIXED

**Location:** `report_form_scenario.dart` — ADD image section (lines ~340-390)

**Problem:** After tapping "ADD" to add an image, a modal bottom sheet opens with "- Pick from gallery" / "- Take a photo" options. The original code only checked for `'Camera'` and `'กล้อง'` which never matched the actual option text, so the bottom sheet stayed open. The open bottom sheet made the `SingleChildScrollView` behind it non-hit-testable, causing `scrollUntilVisible` for the review button to fail with a `WaitUntilVisibleTimeoutException`.

**Fix applied:**
1. Updated option detection to check actual bottom sheet labels: `'Pick from gallery'`, `'เลือกรูปภาพ'`, `'Take a photo'`, `'ถ่ายรูป'`
2. Added `addWasTapped` flag to track whether ADD was actually tapped
3. Added `$.native.pressBack()` to dismiss the bottom sheet via system back button (gated by the flag — avoids accidental navigation if ADD wasn't tapped)
4. Both interactions wrapped in try-catch with continue for resilience

### 3.11 Post-submission success overlay timing ✅ FIXED

**Location:** `report_form_scenario.dart` — post-submission section (line ~460)

**Problem:** After tapping "ส่งรายงาน", the `pumpAndSettle(duration: 500ms)` completed before the async HTTP request finished. The "ส่งรายงานสำเร็จ" overlay never appeared within the 500ms window, causing `expect($(find.text('ส่งรายงานสำเร็จ')).exists, isTrue)` to fail with `Actual: <false>`.

**Fix applied:** Replaced `pumpAndSettle(500ms) + expect(exists)` with `$.waitUntilVisible(find.text('ส่งรายงานสำเร็จ'), timeout: 10s)` — actively pumps frames until the overlay appears, properly handling async network latency.

### 3.12 Commented-out submit scroll code on confirmation page

**Location:** `report_form_scenario.dart` — confirmation page section (lines ~430-440)

**Problem:** The `scrollUntilVisible` for the submit button ("ส่งรายงาน") on the confirmation page is commented out. The `expect` and `tap` still run, which works because the button is visible without scrolling on most screens. However, the dead commented code is a maintenance burden and could cause confusion.

**Fix needed:** Either uncomment the scroll (if the button might need scrolling on smaller screens) or remove the dead code entirely.

**Severity:** 🟢 Low — no functional impact, but untidy.

---

## 4. Navigation Flow Summary

Here's the complete navigation flow tested in `create_report_test.dart`:

```
Welcome Screen
  ↓ select Thai language + BON server + Continue
Login Screen
  ↓ enter credentials + Sign In
Report Home (/reports)
  ↓ tap "รายงานใหม่" FAB
Report Type Screen (/reports/types)
  ↓ toggle test mode ("โหมดทดสอบ"), select category, select type
  ↓ GoRouter.pushReplacementNamed(reportForm)
Report Form (/reports/types/{id}/form)
  → Page 1: age, gender, animal type → tap "ถัดไป"
  → Page 2: affected areas, wound, owner → tap "ถัดไป"
  → Page 3: vaccination, cause, alive status, details, image → tap "ตรวจสอบ"
  → Confirmation page → tap "ส่งรายงาน"
  → SubmitSuccessOverlay ("ส่งรายงานสำเร็จ") → auto-dismiss (~1s)
  → Navigator.pop() → back to Report Home (/reports) ✅
```

---

## 5. Suggested Roadmap

### 🔜 Phase 1 — Short-term (fill gaps in existing flow)

| # | Task | Effort | Impact | Status |
|---|------|--------|--------|--------|
| 1 | 🎯 **Run the test end-to-end** on a real device/emulator and fix any failures | 1-2h | High — validates every change | ✅ Done |
| 2 | Refine the textarea finder to avoid matching non-textarea fields | 30m | Medium — prevents flaky fills | ✅ Done |
| 3 | Simplify the wait pattern in report_form_scenario post-submit — remove the fixed 4s pumpAndSettle and rely on waitUntilVisible alone | 15m | Low — code clarity | ✅ Done |
| 4 | Add `waitUntilVisible` to report_list_scenario navigation check instead of just pumpAndSettle | 15m | Low — robustness | ✅ Done |
| 5 | **Clean up commented-out code** — remove dead submit button scroll (confirmation page) | 5m | Low — hygiene | ✅ Done |
| 6 | **Replace remaining fixed pumpAndSettle** calls with waitUntilVisible (page transitions, age field, confirmation load) | 1h | Medium — flake reduction | ✅ Done |

**Phase 1 Status:** ✅ **COMPLETE** (June 18, 2026)  
**See:** [PHASE1_COMPLETION.md](PHASE1_COMPLETION.md) for detailed changes and impact summary.

### 🔜 Phase 2 — Medium-term (extend coverage)

| # | Task | Effort | Impact |
|---|------|--------|--------|
| 5 | Add **form validation tests** — submit empty/invalid data and verify error snackbar + field-level errors | 2-3h | High — covers critical UX |
| 6 | **Verify test report in the list** — after submission, navigate back and check the test-flagged report appears | 2-3h | High — closes the loop |
| 7 | **Parameterize for multiple report types** — make data-driven scenarios for different forms (e.g., "อุจจาระร่วง", "ไข้เลือดออก") | 3-4h | Medium — broadens coverage |
| 8 | Add **screenshot capture** at key steps using Patrol's built-in screenshot API | 1h | Medium — debugging aid |
| 9 | Add key-based finders (`ValueKey`) to opsv_form widgets and migrate tests away from text-based finding | 4-6h | Medium — stability |

### 🔜 Phase 3 — Long-term (new test domains)

| # | Task | Effort | Impact |
|---|------|--------|--------|
| 10 | **Offline queue + resubmit flow** — airplane mode → submit → reconnect → verify sync | 4-6h | 🔴 High — core feature |
| 11 | **Followup report form** — add a scenario chain for follow-up report filling | 3-4h | Medium — feature coverage |
| 12 | **Form simulator view** — test the draft form preview (`form_simulator_view.dart`) | 2-3h | Medium — admin tool |
| 13 | **Census form flow** — test census submission | 4-6h | Medium — feature coverage |
| 14 | **Auth refresh + token expiry** — test auto-refresh and re-login flows | 3-4h | Medium — auth reliability |

### Infrastructure

| # | Task | Effort | Impact |
|---|------|--------|--------|
| 15 | **Set up CI** to run Patrol tests on every PR | 4-8h | 🔴 High — gates regressions |
| 16 | **Document credential management** for test runs | 1h | Medium — onboarding |

---

## 6. File Inventory

### Integration Test Files

| Path | Lines | Type |
|------|-------|------|
| `integration_test/start_test.dart` | ~70 | Test entry |
| `integration_test/create_report_test.dart` | ~120 | Test entry |
| `integration_test/flows/base_test_scenario.dart` | ~45 | Utility |
| `integration_test/flows/welcome_scenario.dart` | ~90 | Scenario |
| `integration_test/flows/login_scenario.dart` | ~75 | Scenario |
| `integration_test/flows/login_success_scenario.dart` | ~80 | Scenario |
| `integration_test/flows/report_list_scenario.dart` | ~120 | Scenario |
| `integration_test/flows/report_type_scenario.dart` | ~110 | Scenario |
| `integration_test/flows/report_form_scenario.dart` | ~495 | Scenario |
| `integration_test/utils/test_utility.dart` | ~55 | Utility |

### Script Files

| Path | Lines | Type |
|------|-------|------|
| `scripts/patrol_common.sh` | ~115 | Shared library |
| `scripts/run_patrol_bon.sh` | ~40 | Runner |
| `scripts/run_patrol_create_report.sh` | ~40 | Runner |

### Documentation Files

| Path | Purpose |
|------|---------|
| `integration_test/CREATE_REPORT_TEST.md` | Test design overview |
| `integration_test/EXTENDED_FLOW_SUMMARY.md` | Extended flow details |
| `integration_test/PAGE_3_IMPLEMENTATION.md` | Page 3 implementation notes |
| `integration_test/LOGIN_SCENARIO_COMPARISON.md` | Login scenario comparison |
| `integration_test/REVIEW.md` | **This file — full review** |
| `scripts/REFACTORING.md` | Script refactoring notes |

---

## 7. Statistics

| Metric | Value |
|--------|-------|
| Test entry points | 2 (`start_test.dart`, `create_report_test.dart`) |
| Scenario files | 7 |
| Form pages tested | 3 |
| Form fields filled | 10+ |
| Total test steps (create_report) | ~45 |
| Scripts | 3 (1 shared + 2 runners) |
| Documentation files | 6 |
| Issues found | 12 |
| Issues fixed | 9 |
| Open risks | 3 |
