#!/usr/bin/env bash
set -euo pipefail

# Run Patrol integration tests against BON tenant defaults.
#
# Usage:
#   ./scripts/run_patrol_bon.sh <username> <password> [expect_welcome=true] [extra patrol args...]
#
# Examples:
#   ./scripts/run_patrol_bon.sh myuser mypass
#   ./scripts/run_patrol_bon.sh myuser mypass false --verbose
#
# Notes:
# - Username/password are required.
# - EXPECT_WELCOME_SCREEN defaults to true.
# - TENANT_API_ENDPOINT defaults to https://admin.ohtk.org/api/servers/
# - TEST_SERVER_MATCH defaults to bon.
# - TEST_SERVER_DOMAIN defaults to bon.backend.ohtk.org (override via env var if needed).

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  sed -n '3,19p' "$0"
  exit 0
fi

if [[ $# -lt 2 ]]; then
  echo "Error: username and password are required." >&2
  echo "Usage: $0 <username> <password> [expect_welcome=true] [extra patrol args...]" >&2
  exit 1
fi

TEST_USERNAME="$1"
TEST_PASSWORD="$2"
EXPECT_WELCOME_SCREEN="${3:-true}"

# Allow additional patrol args after the first 3 positional args.
if [[ $# -ge 3 ]]; then
  shift 3
else
  shift 2
fi
EXTRA_PATROL_ARGS=("$@")

TENANT_API_ENDPOINT="${TENANT_API_ENDPOINT:-https://admin.ohtk.org/api/servers/}"
TEST_SERVER_MATCH="${TEST_SERVER_MATCH:-bon}"
TEST_SERVER_DOMAIN="${TEST_SERVER_DOMAIN:-bon.backend.ohtk.org}"

HAS_DEVICE_ARG=false
for arg in "${EXTRA_PATROL_ARGS[@]}"; do
  if [[ "$arg" == "-d" || "$arg" == --device || "$arg" == --device=* ]]; then
    HAS_DEVICE_ARG=true
    break
  fi
done

DEFAULT_DEVICE_ID=""
if [[ "$HAS_DEVICE_ARG" == false ]]; then
  # Use flutter devices which has a stable, parseable output:
  #   Device Name • device-id • platform • sdk
  DEVICES_OUTPUT="$(flutter devices 2>/dev/null || true)"
  DEFAULT_DEVICE_ID="$(printf '%s\n' "$DEVICES_OUTPUT" | grep '•' | grep -v 'web\|macOS\|chrome\|Mac ' | head -1 | awk -F '•' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}')"

  if [[ -z "$DEFAULT_DEVICE_ID" ]]; then
    echo "Error: no Patrol device found. Connect/start a device, or pass --device <id>." >&2
    exit 1
  fi
fi

PATROL_ARGS=(
  test
  --target integration_test/start_test.dart
  --dart-define=TEST_USERNAME="${TEST_USERNAME}"
  --dart-define=TEST_PASSWORD="${TEST_PASSWORD}"
  --dart-define=TENANT_API_ENDPOINT="${TENANT_API_ENDPOINT}"
  --dart-define=TEST_SERVER_MATCH="${TEST_SERVER_MATCH}"
  --dart-define=TEST_SERVER_DOMAIN="${TEST_SERVER_DOMAIN}"
  --dart-define=EXPECT_WELCOME_SCREEN="${EXPECT_WELCOME_SCREEN}"
)

if [[ -n "$DEFAULT_DEVICE_ID" ]]; then
  PATROL_ARGS+=(--device "$DEFAULT_DEVICE_ID")
fi

PATROL_ARGS+=("${EXTRA_PATROL_ARGS[@]}")

patrol "${PATROL_ARGS[@]}"
