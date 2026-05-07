#!/usr/bin/env bash
set -euo pipefail

DEVICE_ID="${DEVICE_ID:-emulator-5554}"
SDK_ROOT="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-/Users/pphetra/Library/Android/sdk}}"
ADB="${ADB:-$SDK_ROOT/platform-tools/adb}"

cd "$(dirname "$0")/.."

command -v maestro >/dev/null
command -v flutter >/dev/null

"$ADB" -s "$DEVICE_ID" get-state >/dev/null

python3 .maestro/tenant_proxy.py &
PROXY_PID="$!"
cleanup() {
  kill "$PROXY_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

flutter build apk --debug \
  --dart-define=TENANT_API_ENDPOINT=http://10.0.2.2:18080/api/servers/ \
  --dart-define=GRAPHQL_ENDPOINT=https://10.0.2.2/graphql/

"$ADB" -s "$DEVICE_ID" install -r build/app/outputs/flutter-apk/app-debug.apk

"$ADB" -s "$DEVICE_ID" shell pm clear org.poddtoolkit.poddMobile >/dev/null
"$ADB" -s "$DEVICE_ID" shell monkey -p org.poddtoolkit.poddMobile 1 >/dev/null
sleep "${WARMUP_SECONDS:-15}"
"$ADB" -s "$DEVICE_ID" shell am force-stop org.poddtoolkit.poddMobile

maestro check-syntax .maestro/fao_census_smoke.yaml

MAESTRO_CLI_NO_ANALYTICS=1 \
MAESTRO_CLI_ANALYSIS_NOTIFICATION_DISABLED=true \
maestro test --device "$DEVICE_ID" .maestro/fao_census_smoke.yaml
