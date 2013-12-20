#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh
. ${BUILDPACK_HOME}/bin/common

testExportEnvAppliesBlacklist() {
  cat >$ENV_FILE<<EOF
GIT_DIR=/lol
MAVEN_PATH=/jars
EOF

  export_env_file $ENV_FILE
  
  assertTrue "GIT_DIR should not be set" "[ -z $GIT_DIR ]" # -z is a zero-length string test
  assertTrue "MAVEN_PATH should be set" "[ -n $MAVEN_PATH ]" # -n is a non-zero-length string test
}
