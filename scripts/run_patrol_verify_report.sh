#!/usr/bin/env bash
# Script to run the verify_report_test.dart Patrol test.
# This test verifies that a test report appears in the report list after submission.

set -euo pipefail

# Source the common patrol test library (environment variables, etc.)
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/patrol_common.sh"

parse_patrol_args "$@"
set_bon_defaults

# Run the test
run_patrol_test "integration_test/verify_report_test.dart"
