#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh
. ${BUILDPACK_HOME}/bin/common

testExportEnvAppliesBlacklist() {
  echo -n "/lol"  > $ENV_DIR/GIT_DIR
  echo -n "/jars" > $ENV_DIR/MAVEN_DIR
  cat > $ENV_DIR/MULTILINE <<EOF
i'm a cool
multiline
config
var
i even have a trailing new line or two!

EOF
  echo -n ""    > $ENV_DIR/EMPTY

  export_env_dir $ENV_DIR
  
  assertNull 'GIT_DIR should not be set' "$(env | grep '^GIT_DIR=')"
  assertNotNull 'MAVEN_DIR should be set' "$(env | grep '^MAVEN_DIR=')"
  assertEquals 'MAVEN_DIR should be set with value' "/jars" "$MAVEN_DIR" 
  assertNotNull 'EMPTY should but without any value' "$(env | grep '^EMPTY=$')"
  assertTrue 'MULTILINE should be set' '[ -n "$MULTILINE" ]'
  assertEquals 'MULTILINE should have line breaks without trailing new lines' '4' "$(printf "$MULTILINE" | wc -l)"
}
