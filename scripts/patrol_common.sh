#!/usr/bin/env bash
# Common functions for Patrol integration test scripts.
#
# This file should be sourced by other scripts, not executed directly.

# Parse common command-line arguments for Patrol tests.
#
# Sets the following variables:
#   TEST_USERNAME - from $1
#   TEST_PASSWORD - from $2
#   EXPECT_WELCOME_SCREEN - from $3 (default: true)
#   EXTRA_PATROL_ARGS - array of remaining args after first 3
#
# Usage:
#   source scripts/patrol_common.sh
#   parse_patrol_args "$@"
parse_patrol_args() {
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
}

# Set default BON tenant environment variables if not already set.
#
# Sets:
#   TENANT_API_ENDPOINT
#   TEST_SERVER_MATCH
#   TEST_SERVER_DOMAIN
set_bon_defaults() {
  TENANT_API_ENDPOINT="${TENANT_API_ENDPOINT:-https://admin.ohtk.org/api/servers/}"
  TEST_SERVER_MATCH="${TEST_SERVER_MATCH:-bon}"
  TEST_SERVER_DOMAIN="${TEST_SERVER_DOMAIN:-bon.backend.ohtk.org}"
}

# Detect if --device argument was provided in EXTRA_PATROL_ARGS.
#
# Returns:
#   0 if device arg found, 1 otherwise
has_device_arg() {
  for arg in "${EXTRA_PATROL_ARGS[@]}"; do
    if [[ "$arg" == "-d" || "$arg" == --device || "$arg" == --device=* ]]; then
      return 0
    fi
  done
  return 1
}

# Auto-detect a suitable Flutter device for testing.
#
# Outputs the device ID to stdout.
# Exits with error if no suitable device found.
#
# Excludes: web, macOS, chrome desktop browsers
# Prefers: wireless/physical devices over emulators
detect_flutter_device() {
  local devices_output
  local device_id
  
  devices_output="$(flutter devices 2>/dev/null || true)"
  
  # First, try to find a wireless device (physical device connected wirelessly)
  device_id="$(printf '%s\n' "$devices_output" | grep '•' | grep 'wireless' | head -1 | awk -F '•' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}')"
  
  # If no wireless device, try any mobile device that's not an emulator
  if [[ -z "$device_id" ]]; then
    device_id="$(printf '%s\n' "$devices_output" | grep '•' | grep 'mobile' | grep -v 'emulator' | grep -v 'web\|macOS\|chrome\|Mac ' | head -1 | awk -F '•' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}')"
  fi
  
  # Finally, fall back to any device (including emulator) that's not web/desktop
  if [[ -z "$device_id" ]]; then
    device_id="$(printf '%s\n' "$devices_output" | grep '•' | grep -v 'web\|macOS\|chrome\|Mac ' | head -1 | awk -F '•' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}')"
  fi

  if [[ -z "$device_id" ]]; then
    echo "Error: no Patrol device found. Connect/start a device, or pass --device <id>." >&2
    exit 1
  fi

  echo "$device_id"
}

# Build and execute a Patrol test command.
#
# Args:
#   $1 - test target file path (e.g., integration_test/start_test.dart)
#
# Uses globals:
#   TEST_USERNAME
#   TEST_PASSWORD
#   TENANT_API_ENDPOINT
#   TEST_SERVER_MATCH
#   TEST_SERVER_DOMAIN
#   EXPECT_WELCOME_SCREEN
#   EXTRA_PATROL_ARGS
run_patrol_test() {
  local test_target="$1"
  
  local patrol_args=(
    test
    --target "$test_target"
    --dart-define=TEST_USERNAME="${TEST_USERNAME}"
    --dart-define=TEST_PASSWORD="${TEST_PASSWORD}"
    --dart-define=TENANT_API_ENDPOINT="${TENANT_API_ENDPOINT}"
    --dart-define=TEST_SERVER_MATCH="${TEST_SERVER_MATCH}"
    --dart-define=TEST_SERVER_DOMAIN="${TEST_SERVER_DOMAIN}"
    --dart-define=EXPECT_WELCOME_SCREEN="${EXPECT_WELCOME_SCREEN}"
  )

  # Auto-detect device if not provided in extra args
  if ! has_device_arg; then
    local device_id
    device_id="$(detect_flutter_device)"
    echo "Auto-detected device: $device_id" >&2
    patrol_args+=(--device "$device_id")
  else
    echo "Using device from command-line arguments" >&2
  fi

  patrol_args+=("${EXTRA_PATROL_ARGS[@]}")

  echo "Running: patrol ${patrol_args[*]}" >&2
  patrol "${patrol_args[@]}"
}
