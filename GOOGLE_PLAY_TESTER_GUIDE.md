# LAHIS Google Play tester guide

Use this guide after the coordinator has invited you to a LAHIS Google Play
test. Do not submit real patient, animal-owner, incident, location, photo, or
other sensitive data during this test.

## Test parameters

The coordinator fills this block before sending the guide to testers. Do not
replace a missing value with a different tenant.

| Parameter | What the tester needs | Current staging example |
| --- | --- | --- |
| `DASHBOARD_URL` | Public dashboard URL for coordinator verification | `https://lahis.ohtk.org` |
| `API_URL` | Parent API URL (coordinator-only reference) | `https://api.lahis.ohtk.org` |
| `SERVER_LIST_ENDPOINT` | Endpoint compiled into the test AAB | `https://api.lahis.ohtk.org/api/servers/` |
| `DEMO_TENANT` | Intended demo tenant slug | `demo` |
| `TEST_TENANT_LABEL` | Exact item to choose under **Server** | `LAHIS Demo` |

## What the coordinator gives each tester

- The Google Play testing/opt-in link and the Google account email that was
  added as a tester. Use that same Google account in the Play Store.
- The exact `TEST_TENANT_LABEL` to select on first launch (for current staging,
  this is the label for `DEMO_TENANT=demo`).
- A valid **seven-digit invitation code**, its expiry date, and the test
  village/authority. Treat the code as test access; do not post it in public
  chat or screenshots.
- A short test-data convention, such as `PLAYTEST-<initials>-<date>`, so test
  reports can be found and removed after the test.
- A contact for blocked registration, missing report types, or a failed submit.

The coordinator creates invitation codes in the dashboard at
**Admin → Invitation codes**, scoped to the test authority/village and valid
for the testing window. Use a reporter role and separate codes per tester or
per small test cohort; do not reuse an operational invitation code.

## Install from Google Play

1. Open the opt-in link while signed in to the agreed Google account.
2. Join the test, then use its Play Store link to install or update **LAHIS**.
3. Open LAHIS. On the welcome screen, choose a language and select the tenant
   label provided by the coordinator under **Server**. Tap **Continue**.

If the intended server is missing or the app says it cannot load servers, stop
and report the screen and time to the coordinator. Do not select another
tenant as a workaround.

## Register a tester account

1. On the sign-in screen, tap **Register as reporter**.
2. Enter the coordinator’s seven-digit invitation code. The app checks it and
   shows **Code accepted** before continuing.
3. Complete the reporter details. Use synthetic test values where possible:
   - a clearly test-only username;
   - a test mailbox that the tester can access if email verification or support
     follow-up is needed; and
   - non-real phone, address, age, gender, and report content unless the
     coordinator has expressly approved a different test protocol.
4. If a privacy notice is shown, open it, read it, and confirm the consent
   checkbox. Some tenants may require age and/or gender.
5. Tap **Create account & sign in**. Record only the outcome—not the invitation
   code or personal values—in the test feedback.

If registration fails, capture the exact visible error, app version, device
model/Android version, selected tenant label, and approximate time. Do not send
screenshots containing the invitation code or personal data.

## Submit one safe test report

1. Open the **Reports** tab and tap **New report**.
2. On **Report type**, turn on **Test mode**. The app displays a banner that
   test submissions land in the sandbox. If the banner does not appear, stop
   and ask the coordinator before submitting anything.
3. Select the report type named by the coordinator. If there are no report
   types, pull to refresh once; then report the issue rather than choosing an
   unrelated workflow.
4. Complete only the fields requested by the coordinator, using the agreed
   synthetic test-data convention. Do not attach a real photo, file, audio,
   video, address, or location.
5. If the test covers attachments or location, use an approved non-sensitive
   sample and grant the permission only for that test. Declining the permission
   is also valid feedback; note which feature then becomes unavailable.
6. Continue to the confirmation screen, review the summary, select the
   authority response if prompted, and tap **Submit report**.
7. Wait for the **Report submitted** confirmation and send the coordinator the
   approximate submission time and test-data convention. The normal **My
   reports** list shows non-test reports, so the coordinator—not the tester—
   verifies the sandbox report in the dashboard.

## Report results back

Send the coordinator:

| Check | Result to provide |
| --- | --- |
| Play install/update | pass/fail and app version |
| Tenant selection | selected label only |
| Registration | pass/fail; no invitation code |
| Test-mode banner | visible/not visible |
| Report submission | pass/fail and approximate time |
| Sandbox verification | coordinator confirms dashboard result |
| Optional permissions | allowed/denied and observed behaviour |
| Defects | steps, expected/actual result, device/Android version, redacted screenshot if useful |

The coordinator checks the submitted test report in the dashboard and cleans
up test accounts/reports according to the agreed staging-test procedure. A
tester must not delete a report, change another user’s data, or leave test mode
to submit a real-world report.
