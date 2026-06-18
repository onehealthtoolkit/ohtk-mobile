#!/usr/bin/env bash
set -euo pipefail

# ══════════════════════════════════════════════════════════════════════════════
# run_patrol_validation.sh
# ══════════════════════════════════════════════════════════════════════════════
#
# Runs the form validation integration test (validation_test.dart) using Patrol.
# This test verifies:
# - Required field validation triggers when submitting empty fields
# - Validation snackbar appears with "Invalid form value" message
# - Field-level error messages appear below invalid fields
# - Form does not navigate when validation fails
# - Form successfully navigates when all required fields are filled
#
# Usage:
#   ./scripts/run_patrol_validation.sh <username> <password> [expect_welcome] [extra_args...]
#
# Arguments:
#   username           - BON server username
#   password           - BON server password
#   expect_welcome     - (Optional) "true" or "false". Default: true
#   extra_args...      - (Optional) Additional arguments passed to patrol test
#
# Examples:
#   ./scripts/run_patrol_validation.sh myuser mypass
#   ./scripts/run_patrol_validation.sh myuser mypass false
#   ./scripts/run_patrol_validation.sh myuser mypass true --verbose
#
# ══════════════════════════════════════════════════════════════════════════════

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  sed -n '3,24 p' "$0"
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/patrol_common.sh"

parse_patrol_args "$@"
set_bon_defaults

# Run the validation test
run_patrol_test "integration_test/validation_test.dart"
