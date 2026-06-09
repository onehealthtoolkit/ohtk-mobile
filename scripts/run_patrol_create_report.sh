#!/usr/bin/env bash
set -euo pipefail

# Run Patrol integration tests (create_report_test) against BON tenant defaults.
#
# Usage:
#   ./scripts/run_patrol_create_report.sh <username> <password> [expect_welcome=true] [extra patrol args...]
#
# Examples:
#   ./scripts/run_patrol_create_report.sh myuser mypass
#   ./scripts/run_patrol_create_report.sh myuser mypass false --verbose
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

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common Patrol test functions
# shellcheck source=scripts/patrol_common.sh
source "${SCRIPT_DIR}/patrol_common.sh"

# Parse common arguments
parse_patrol_args "$@"

# Set BON tenant defaults
set_bon_defaults

# Run the create_report_test
run_patrol_test "integration_test/create_report_test.dart"
