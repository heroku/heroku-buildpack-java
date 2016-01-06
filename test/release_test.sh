#!/bin/sh

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

testRelease()
{
  expected_release_output=`cat <<EOF
---
addons:
  - heroku-postgresql
EOF`

  release

  assertCapturedSuccess
  assertCapturedEquals "${expected_release_output}"
}
