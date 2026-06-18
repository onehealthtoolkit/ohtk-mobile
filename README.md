# OHTK Mobile

OHTK mobile application for community and official reporting.

### What you'll need

- [flutter](https://docs.flutter.dev/get-started/install)
- [android studio](https://developer.android.com/studio) or [xcode](https://docs.flutter.dev/get-started/install/macos#ios-setup)

If necessary, add the Android emulator to your path
```export PATH=$PATH:~/Library/Android/sdk/emulator/```

### Install

Get latest version of ohtk-mobile from github:

```git clone https://github.com/onehealthtoolkit/ohtk-mobile.git```

```cd ~/ohtk-mobile```

Run flutter build command

```flutter pub run build_runner build --delete-conflicting-outputs```

#### Change server to test server

Change settings to 

```opensur.test```

#### Config Android emulator to use localhost custom url endpoint

```bash
# List all available emulators
> emulator  --list-avds

# Start emulator in write mode
# [AVD_NAME] such as Pixel_4_XL_API_25
> emulator  -writable-system -netdelay none -netspeed full -avd [AVD_NAME]

# Wait until emulator is completely started
# Login as root
> adb root

# Remount emulator path /system to writable
> adb remount

# Upload hosts file to emulator
> adb push /path/to/hosts /system/etc/

# List active reverse ports
> adb reverse --list

# Reverse port from localhost server port 8000
> adb reverse tcp:80 tcp:8000

```

### Run Mobile App

Now you're ready to actually test the app. Open your IDE and run the flutter program:

- ex. Visual Studio Code: Run > Run without Debugging

Try logging in with one of the users created via the [OHTK Management System](https://github.com/onehealthtoolkit/ohtk-ms)

#### hosts file sample

```
127.0.0.1 localhost
127.0.0.1 opensur.test
127.0.0.1 laos.opensur.test
::1 ip6-localhost
```

### UI integration tests with Patrol CLI

Use Patrol to run end-to-end UI tests on a real Android device/emulator (not desktop).

All tests are run through convenience scripts located in `scripts/`, which handle
device auto-detection, BON tenant defaults, and required `--dart-define` variables
automatically.

#### 1) Install Patrol CLI

```bash
flutter pub global activate patrol_cli
```

If needed, add pub global binaries to your shell path:

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```

#### 2) Verify environment

```bash
patrol doctor
```

All Android checks should be green before running tests.

#### 3) Start an Android emulator/device

```bash
flutter emulators
flutter emulators --launch <EMULATOR_ID>
flutter devices
```

Make sure `flutter devices` lists at least one Android target.

#### 4) Test scripts

Each test scenario has its own run script that accepts username + password and
offers optional arguments. The scripts auto-detect a connected Android device,
set BON tenant environment variables, and pass all required `--dart-define` flags.

| Script | Test file | Scenario |
|--------|-----------|----------|
| `scripts/run_patrol_bon.sh` | `start_test.dart` | Welcome screen + negative auth (invalid login stays on login screen) |
| `scripts/run_patrol_create_report.sh` | `create_report_test.dart` | Full report creation flow: login → report list → type selection → form fill → submit |
| `scripts/run_patrol_validation.sh` | `validation_test.dart` | Form validation: empty/invalid fields trigger errors, valid fields navigate forward |
| `scripts/run_patrol_verify_report.sh` | `verify_report_test.dart` | After submission, verify the test report appears in the list with "ทดสอบ" flag |

**Usage:**

```bash
./scripts/run_patrol_bon.sh <username> <password> [expect_welcome] [extra args...]
./scripts/run_patrol_create_report.sh <username> <password> [expect_welcome] [extra args...]
./scripts/run_patrol_validation.sh <username> <password> [expect_welcome] [extra args...]
./scripts/run_patrol_verify_report.sh <username> <password> [expect_welcome] [extra args...]
```

**Arguments:**

- `username`, `password` — **(required)** BON server credentials
- `expect_welcome` — _(optional, default: `true`)_ set to `false` to skip the welcome screen if already onboarded
- `extra args...` — _(optional)_ additional flags forwarded to `patrol test`, e.g. `--verbose`, `--device <ID>`

**Examples:**

```bash
# Basic — auto-detects device, uses BON defaults, expects welcome screen
./scripts/run_patrol_create_report.sh myuser mypass

# Skip welcome screen (e.g. after first run)
./scripts/run_patrol_create_report.sh myuser mypass false

# Override device selection
./scripts/run_patrol_create_report.sh myuser mypass true --device emulator-5554

# Enable verbose output
./scripts/run_patrol_validation.sh myuser mypass true --verbose
```

#### 5) Override environment variables

The scripts set sensible BON tenant defaults. Override any variable by exporting
it before running the script:

```bash
export TENANT_API_ENDPOINT=https://admin.poddlaos.org/api/servers/
export TEST_SERVER_DOMAIN=test.backend.poddlaos.org
export TEST_SERVER_MATCH=bonlaos
./scripts/run_patrol_create_report.sh myuser mypass
```

#### Troubleshooting

- **`Total: 0` in summary** — Patrol likely ran on desktop/web instead of Android.
  The auto-detection in `patrol_common.sh` filters out web/macOS/chrome, but you can
  force a specific device with `--device <ID>`.
- **Patrol selects `macOS` automatically** — start an Android emulator first and
  re-run. The auto-detection prefers Android devices.
- **Test discovery fails** — clean and retry:

```bash
flutter clean
flutter pub get
./scripts/run_patrol_bon.sh <username> <password>
```



