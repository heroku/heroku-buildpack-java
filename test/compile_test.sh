#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh
. ${BUILDPACK_HOME}/lib/common.sh
. ${BUILDPACK_HOME}/test/helpers.sh
. ${BUILDPACK_HOME}/test/stdlib_stubs.sh

assertCapturedSuccess() {
  assertEquals 0 "${RETURN}"
  if [ "$TRAVIS" = "true" ]; then
    # Travis keeps injecting -Xmn option on JDK8 that causes a warning in STR_ERR
    assertTrue true
  else
    assertEquals "" "$(cat ${STD_ERR})"
  fi
}

setupJavaEnv() {
  # like jvmcommon but without 'ulimit -u', which doesn't work on Travis
  export JAVA_HOME="$BUILD_DIR/.jdk"
  export LD_LIBRARY_PATH="$JAVA_HOME/jre/lib/amd64/server:$LD_LIBRARY_PATH"
  export PATH="$BUILD_DIR/.heroku/bin:$JAVA_HOME/bin:$PATH"
}

# Tests

testCompileWithoutSystemProperties() {
  createPom "$(withDependency)"
  assertTrue "Precondition" "[ ! -f ${BUILD_DIR}/system.properties ]"

  compile

  assertCapturedSuccess

  _assertMavenLatest
  assertCaptured "Installing OpenJDK 1.8"
  assertTrue "Java should be present in runtime." "[ -d ${BUILD_DIR}/.jdk ]"
  assertTrue "Java version file should be present." "[ -f ${BUILD_DIR}/.jdk/version ]"
  assertTrue "system.properties was not cached" "[ -f $CACHE_DIR/system.properties ]"
}

testCompile()
{
  createPom "$(withDependency)"

  compile

  assertCapturedSuccess

  _assertMavenLatest
  assertTrue "system.properties was not cached" "[ -f $CACHE_DIR/system.properties ]"
  assertContains "system.properties contains the wrong version" "java.runtime.version=1.8" "$(cat $CACHE_DIR/system.properties)"
}

testCompilationFailure()
{
  # Don't create POM to fail build

  compile

  assertNotEquals 0 "${RETURN}"
  assertContains "Build was unexpectedly successful" "Failed to build app with Maven" "$(cat ${STD_OUT})"
}

testNewAppsRemoveM2Cache()
{
  createPom
  rm -r ${CACHE_DIR} # simulate a brand new app without a cache dir
  assertFalse "Precondition: New apps should not have a CACHE_DIR prior to running" "[ -d ${CACHE_DIR} ]"
  mkdir ${CACHE_DIR}

  compile

  assertCapturedSuccess
  assertFalse ".m2 should not be copied to build dir" "[ -d ${BUILD_DIR}/.m2/repository ]"
  assertFalse ".maven should not be copied to build dir" "[ -d ${BUILD_DIR}/.maven ]"
}

testCustomSettingsXml()
{
  createPom "$(withDependency)"
  createSettingsXml

  compile

  assertCapturedSuccess
  assertCaptured "Should download from JBoss" "Downloading from jboss-no-bees: http://repository.jboss.org/nexus/content/groups/public"
}

testCustomSettingsXmlWithPath()
{
  createPom "$(withDependency)"
  mkdir -p $BUILD_DIR/support
  createSettingsXml "${BUILD_DIR}/support/settings.xml"

  export MAVEN_SETTINGS_PATH="${BUILD_DIR}/support/settings.xml"

  compile

  assertCapturedSuccess
  assertCaptured "Should download from JBoss" "Downloading from jboss-no-bees: http://repository.jboss.org/nexus/content/groups/public"

  unset MAVEN_SETTINGS_PATH
}

testCustomSettingsXmlWithUrl()
{
  createPom "$(withDependency)"
  mkdir -p /tmp/.m2
  createSettingsXml "/tmp/.m2/settings.xml"

  export MAVEN_SETTINGS_URL="file:///tmp/.m2/settings.xml"

  compile

  assertCapturedSuccess
  assertCaptured "Should download from JBoss" "Downloading from jboss-no-bees: http://repository.jboss.org/nexus/content/groups/public"

  unset MAVEN_SETTINGS_URL
}

testCustomSettingsXmlWithInvalidUrl()
{
  createPom

  export MAVEN_SETTINGS_URL="https://example.com/ha7s8duysadfuhasjd/settings.xml"

  compile

  assertCapturedError

  unset MAVEN_SETTINGS_URL
}

testIgnoreSettingsOptConfig()
{
  createPom "$(withDependency)"
  export MAVEN_SETTINGS_OPT="-s nonexistant_file.xml"
  compile
  assertCapturedSuccess
  unset MAVEN_SETTINGS_OPT
}

testMaven325()
{
  cat > ${BUILD_DIR}/system.properties <<EOF
maven.version=3.2.5
EOF

  createPom "$(withDependency)"

  compile

  assertCapturedSuccess

  _assertMaven325
}

testMaven339()
{
  cat > ${BUILD_DIR}/system.properties <<EOF
maven.version=3.3.9
EOF

  createPom "$(withDependency)"

  compile

  assertCapturedSuccess

  _assertMaven339
}

testMaven354()
{
  cat > ${BUILD_DIR}/system.properties <<EOF
maven.version=3.5.4
EOF

  createPom "$(withDependency)"

  compile

  assertCapturedSuccess

  _assertMaven354
}

testMavenUpgrade()
{
    setupJavaEnv

    cat > ${BUILD_DIR}/system.properties <<EOF
maven.version=3.2.5
EOF

    createPom "$(withDependency)"

    compile
    assertCapturedSuccess

    _assertMaven325

    cat > ${BUILD_DIR}/system.properties <<EOF
maven.version=3.5.4
EOF

    compile

    assertCapturedSuccess
}

testMavenInvalid()
{
  cat > ${BUILD_DIR}/system.properties <<EOF
maven.version=9.9.9
EOF

  createPom "$(withDependency)"

  compile

  assertCapturedError "you have defined an unsupported Maven version"
}
