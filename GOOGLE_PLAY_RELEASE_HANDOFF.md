# LAHIS Android / Google Play release handoff

This runbook prepares a signed Android App Bundle (AAB) for the LAHIS mobile
app and hands it to the Google Play Console owner. It does not grant authority
to publish; the Play Console owner approves each testing or production rollout.

Give external testers the separate, credential-free
[tester registration and report guide](./GOOGLE_PLAY_TESTER_GUIDE.md). The
coordinator supplies the tenant label and invitation code out of band.

## Release parameters

Set these once in the release ticket and use the same values in the staging
deployment handoff and tester guide.

| Parameter | Meaning | Current staging example |
| --- | --- | --- |
| `DASHBOARD_URL` | Public dashboard base URL, no trailing slash | `https://lahis.ohtk.org` |
| `API_URL` | Public parent API base URL, no trailing slash | `https://api.lahis.ohtk.org` |
| `SERVER_LIST_ENDPOINT` | Endpoint compiled into the Android app | `https://api.lahis.ohtk.org/api/servers/` |
| `DEMO_TENANT` | Demo tenant schema/slug | `demo` |
| `TEST_TENANT_LABEL` | Label testers select in the mobile Server list | `LAHIS Demo` |

`SERVER_LIST_ENDPOINT` is the value passed to `TENANT_API_ENDPOINT`. It must
list `TEST_TENANT_LABEL` and resolve its tenant domain before the AAB is built.

Set the approved endpoint in the build shell before running the build command:

```bash
export SERVER_LIST_ENDPOINT='<SERVER_LIST_ENDPOINT>'
```

## Release facts to preserve

| Item | Current value / rule |
| --- | --- |
| Android application ID | `org.poddtoolkit.lahis` |
| Build artifact | `build/app/outputs/bundle/release/app-release.aab` |
| Endpoint used by the released app | `${SERVER_LIST_ENDPOINT}` |
| Public privacy policy | `${DASHBOARD_URL}/privacy-policy` |
| Public account-deletion request page | `${DASHBOARD_URL}/account-deletion` |
| Version source | `pubspec.yaml` (`version: name+buildNumber`) |

The package name is permanent once uploaded to Google Play. Every uploaded AAB
must have a higher Android `versionCode` than the currently active artifact.

## Approvals and materials required

- Approved source commit/tag and a release owner.
- A new, approved `version:` in `pubspec.yaml`; record it in the release ticket.
- The upload keystore and its `android/key.properties` values, supplied through
  the secure secrets process. Do not commit, copy, or send them in chat.
- `google.map.key` in the local Android build properties, restricted in Google
  Cloud to this Android package and the release signing certificate.
- Access to the Google Play Console app with the necessary release permission.
- Staging dashboard release containing the two public pages above. Confirm both
  URLs load without sign-in before creating a Play release.
- Legal/product owner approval of the privacy policy, support mailbox, data
  retention language, and Data safety answers.

Stop if the keystore is unavailable, the policy URLs are not public, the
support mailbox is not owned/monitored, or the desired version code is not
higher than the previous Play artifact.

## What the app handles: Data safety input worksheet

This is a source-derived checklist, not a legal declaration. The Play Console
owner must validate the final answers against the deployed API, tenant policy,
Firebase project settings, and every SDK’s current disclosure guidance.

| Likely data category | Why it is present | Likely purpose to validate in Play Console |
| --- | --- | --- |
| Name/account identifier, email, village/authority profile | registration and sign-in flows | app functionality, account management |
| Age and gender | configurable registration fields | app functionality; verify whether any tenant enables collection |
| Report, observation, census, follow-up, and comment content | surveillance workflow | app functionality |
| Photos, attachments, and audio/video files | camera, gallery, and file-picker report fields | app functionality |
| Precise/approximate location | user-initiated location/report/map functions | app functionality |
| Push-notification token | Firebase Cloud Messaging registration | app functionality |
| App interactions / diagnostics | Firebase Analytics is included | analytics; verify actual events and Firebase settings |
| Map requests | Google Maps SDK is included | app functionality; verify Google Maps SDK disclosure |

The Android manifest declares fine/coarse location, camera, internet, and an
advertising-ID permission. The code removes package-install permission and uses
location only after a user action; it states that it does not track users in the
background. Still, the Play declaration must cover every version currently
distributed and all third-party SDK behaviour.

## Build procedure

1. Start from the approved source and inspect local changes.

   ```bash
   cd /path/to/lahis-mobile
   git status --short
   git rev-parse --short HEAD
   grep '^version:' pubspec.yaml
   ```

   Stop on unexplained local changes. Confirm the new build number is greater
   than the highest number in Play Console.

2. Check the build prerequisites without displaying secret values.

   ```bash
   test -f android/key.properties
   test -f android/local.properties
   flutter --version
   ```

   The release signing configuration reads `android/key.properties`; a debug
   key is not an acceptable substitute for an update to an existing Play app.

3. Fetch locked dependencies and run focused quality checks.

   ```bash
   flutter pub get
   flutter analyze
   flutter test
   ```

   Resolve failures before building. If a full test run is not feasible, record
   the exact skipped check and the reason in the release ticket.

4. Build the AAB with the approved server-list endpoint.

   ```bash
   flutter build appbundle --release \
     --dart-define=TENANT_API_ENDPOINT="${SERVER_LIST_ENDPOINT}"
   ```

   The artifact is:

   ```text
   build/app/outputs/bundle/release/app-release.aab
   ```

   Save its SHA-256 checksum and source commit in the release ticket. Transfer
   the AAB only through the approved release-storage channel.

5. Before upload, install/test a comparable release build on an Android device
   or emulator and verify: tenant selection, registration/sign-in, report with
   optional location, image attachment, sync, map display, and notification
   permission. Use test accounts and non-sensitive data.

## Google Play Console procedure

1. In the existing app, confirm package name `org.poddtoolkit.lahis` and the
   intended track. For a first release, create the app with LAHIS as its public
   name and a monitored support email.
2. Configure Play App Signing with the account owner. Keep the upload key in
   the secrets process; do not place it in the repository.
3. Complete Store listing, App content, target audience/content rating, app
   access instructions for reviewers, and any regional declarations that apply.
4. In **App content → Data safety**, answer from the validated worksheet above.
   Include data collected or transmitted by Firebase and other third-party SDKs,
   not only LAHIS API calls. Confirm encryption in transit and the account/data
   deletion request mechanism accurately.
5. Set the privacy policy URL to:

   ```text
   ${DASHBOARD_URL}/privacy-policy
   ```

   Set the account-deletion URL to:

   ```text
   ${DASHBOARD_URL}/account-deletion
   ```

6. Upload `app-release.aab` to **Internal testing** first. Add the agreed
   testers, wait for the build to become available, and capture their smoke
   results. Do not upload the same version code twice.
7. After owner approval, promote through Closed testing or Production according
   to the release plan. Use managed publishing if the owner needs to choose the
   exact go-live time.

Google’s current guidance: every Play app needs a complete, accurate Data
Safety declaration, including third-party SDK handling; Play uses AABs and
requires an increasing version code for each update. Official references:

- [Data safety form](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en)
- [Create and set up an app](https://support.google.com/googleplay/android-developer/answer/9859152?hl=en)
- [Publishing status and permissions](https://support.google.com/googleplay/android-developer/answer/9859751?hl=en)

## Release handback

The mobile release delegate reports the source commit, version name/code, AAB
SHA-256, endpoint used, checks run, device-smoke result, policy URL result,
target track, and Play release URL/status. The Play Console owner confirms the
Data safety and policy declarations before publishing.
