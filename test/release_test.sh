#!/usr/bin/env bash

# shellcheck source=/dev/null
source "${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh"
# shellcheck source=test/stdlib_stubs.sh
source "${BUILDPACK_HOME}/test/stdlib_stubs.sh"

testRelease() {
	expected_release_output=$(
		cat <<EOF
---
EOF
	)

	release

	assertCapturedSuccess
	assertCapturedEquals "${expected_release_output}"
}
