#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh
. ${BUILDPACK_HOME}/test/stdlib_stubs.sh

testRelease()
{
  expected_release_output=`cat <<EOF
---
EOF`

  release

  assertCapturedSuccess
  assertCapturedEquals "${expected_release_output}"
}
