#!/bin/sh

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

testRelease()
{
  expected_release_output=`cat <<EOF
---
config_vars:
  PATH: /usr/local/bin:/usr/bin:/bin
  JAVA_OPTS: -Xmx384m -Xss512k -XX:+UseCompressedOops
  MAVEN_OPTS: -Xmx384m -Xss512k -XX:+UseCompressedOops 
addons:
  heroku-postgresql:dev


EOF`

  release  

  assertCapturedSuccess
  assertCaptured "${expected_release_output}"
}


testReleaseWithVendoredJDK()
{
  mkdir -p ${BUILD_DIR}/.jdk/bin
  expected_release_output=`cat <<EOF
---
config_vars:
  PATH: /app/.jdk/bin:/usr/local/bin:/usr/bin:/bin
  JAVA_OPTS: -Xmx384m -Xss512k -XX:+UseCompressedOops
  MAVEN_OPTS: -Xmx384m -Xss512k -XX:+UseCompressedOops 
addons:
  heroku-postgresql:dev


EOF`

  release  

  assertCapturedSuccess
  assertCaptured "${expected_release_output}"
}
