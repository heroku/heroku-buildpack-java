#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh
. ${BUILDPACK_HOME}/test/stdlib_stubs.sh

capture_test()
{
  HOME=$BUILD_DIR . $BUILD_DIR/.profile.d/maven.sh
  HOME=$BUILD_DIR . $BUILD_DIR/.profile.d/jvmcommon.sh
  capture ${BUILDPACK_HOME}/bin/test ${BUILD_DIR} ${ENV_DIR}
}

capture_test_compile()
{
  capture ${BUILDPACK_HOME}/bin/test-compile ${BUILD_DIR} ${CACHE_DIR} ${ENV_DIR}
}

# Helpers

createTestPom()
{
  cat > ${BUILD_DIR}/pom.xml <<EOF
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.mycompany.app</groupId>
  <artifactId>my-app</artifactId>
  <version>1.0-SNAPSHOT</version>
  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>
  <dependencies>
$1
  </dependencies>
</project>
EOF
}

# Tests

test_test_compile() {
  createTestPom

  capture_test_compile
  assertEquals "Expected captured exit code to be 0; was <${RETURN}>" "0" "${RETURN}"
  assertCaptured "Build was not successful" "BUILD SUCCESS"
  assertTrue "mvn should be executable" "[ -x ${BUILD_DIR}/.maven/bin/mvn ]"
  assertTrue "mvn profile should exist" "[ -f ${BUILD_DIR}/.profile.d/maven.sh ]"

  capture_test
  assertEquals "Expected captured exit code to be 0; was <${RETURN}>" "0" "${RETURN}"
  assertCaptured "Build was not successful" "BUILD SUCCESS"
}
