#!/bin/sh

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

testRelease()
{
  expected_release_output=`cat <<EOF
---
config_vars:
  JAVA_OPTS: -XX:+UseCompressedOops
addons:
  heroku-postgresql:hobby-dev
EOF`

  release

  assertCapturedSuccess
  assertCapturedEquals "${expected_release_output}"
}
