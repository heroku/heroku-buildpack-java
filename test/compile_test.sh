#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

assertCapturedSuccess() {
  assertEquals 0 "${RETURN}"
  if [ "$TRAVIS" = "true" ]; then
    # Travis keeps injecting -Xmn option on JDK8 that causes a warning in STR_ERR
    assertTrue true
  else
    assertEquals "" "$(cat ${STD_ERR})"
  fi
}

createPom()
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

withDependency()
{
  cat <<EOF
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>4.0</version>
      <type>jar</type>
      <scope>test</scope>
    </dependency>
EOF
}

createSettingsXml()
{
  [ "$TRAVIS" = "true" ] && rm -rf /home/travis/.m2/repository

  if [ ! -z "$1" ]; then
    SETTINGS_FILE=$1
  else
    SETTINGS_FILE="${BUILD_DIR}/settings.xml"
  fi

  cat > $SETTINGS_FILE <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
  <profiles>
    <profile>
      <id>jboss-public-repository</id>
      <repositories>
        <repository>
          <id>jboss-no-bees</id>
          <name>JBoss Public Maven Repository Group</name>
          <url>http://repository.jboss.org/nexus/content/groups/public/</url>
        </repository>
      </repositories>
    </profile>
  </profiles>

  <activeProfiles>
    <activeProfile>jboss-public-repository</activeProfile>
  </activeProfiles>
</settings>
EOF
}

# Helpers

_assertMaven305() {
  assertCaptured "Installing Maven 3.0.5"
  assertFileMD5 "7d2bdb60388da32ba499f953389207fe" ${CACHE_DIR}/.maven/bin/mvn
  assertTrue "mvn should be executable" "[ -x ${CACHE_DIR}/.maven/bin/mvn ]"

  assertCaptured "Executing: mvn -B -DskipTests=true clean install"
  assertCaptured "BUILD SUCCESS"
}

_assertMaven311() {
  assertCaptured "Installing Maven 3.1.1"
  assertFileMD5 "08a6e3ab11f4add00d421dfa57ef4c85" ${CACHE_DIR}/.maven/bin/mvn
  assertTrue "mvn should be executable" "[ -x ${CACHE_DIR}/.maven/bin/mvn ]"

  assertCaptured "Executing: mvn -B -DskipTests=true clean install"
  assertCaptured "BUILD SUCCESS"
}

_assertMaven325() {
  assertCaptured "Installing Maven 3.2.5"
  assertFileMD5 "9d4c6b79981a342940b9eff660070748" ${CACHE_DIR}/.maven/bin/mvn
  assertTrue "mvn should be executable" "[ -x ${CACHE_DIR}/.maven/bin/mvn ]"

  assertCaptured "Executing: mvn -B -DskipTests=true clean install"
  assertCaptured "BUILD SUCCESS"
}

_assertMavenLatest() {
  assertCaptured "Installing Maven 3.3.1"
  assertFileMD5 "33b5239bdf488c9867f95dbb93ffc0a6" ${CACHE_DIR}/.maven/bin/mvn
  assertTrue "mvn should be executable" "[ -x ${CACHE_DIR}/.maven/bin/mvn ]"

  assertCaptured "Executing: mvn -B -DskipTests=true clean install"
  assertCaptured "BUILD SUCCESS"
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
}

testCompile()
{
  createPom "$(withDependency)"

  compile

  assertCapturedSuccess

  _assertMavenLatest
}

testCompilationFailure()
{
  # Don't create POM to fail build

  compile

  assertNotEquals 0 "${RETURN}"
  assertContains "Failed to build app with Maven" "$(cat ${STD_OUT})"
}

testDownloadCaching()
{
  createPom

  # simulate a primed cache
  mkdir -p ${CACHE_DIR}/.m2
  mkdir -p ${CACHE_DIR}/.maven/bin
  cat > ${CACHE_DIR}/.maven/bin/mvn <<EOF
echo "Apache Maven 3.2.3"
EOF
  chmod +x ${CACHE_DIR}/.maven/bin/mvn

  compile

  assertNotCaptured "Maven should not be installed again when already cached" "Installing Maven"
}

testNewAppsRemoveM2Cache()
{
  createPom
  rm -r ${CACHE_DIR} # simulate a brand new app without a cache dir

  assertFalse "Precondition: New apps should not have a CACHE_DIR prior to running" "[ -d ${CACHE_DIR} ]"

  compile

  assertCapturedSuccess
  assertFalse ".m2 should not be copied to build dir" "[ -d ${BUILD_DIR}/.m2 ]"
  assertFalse ".maven should not be copied to build dir" "[ -d ${BUILD_DIR}/.maven ]"
}

testCustomSettingsXml()
{
  createPom "$(withDependency)"
  createSettingsXml

  compile

  assertCapturedSuccess
  assertCaptured "Should download from JBoss" "Downloading: http://repository.jboss.org/nexus/content/groups/public"
}

testCustomSettingsXmlWithPath()
{
  createPom "$(withDependency)"
  mkdir -p $BUILD_DIR/support
  createSettingsXml "${BUILD_DIR}/support/settings.xml"

  export MAVEN_SETTINGS_PATH="${BUILD_DIR}/support/settings.xml"

  compile

  assertCapturedSuccess
  assertCaptured "Should download from JBoss" "Downloading: http://repository.jboss.org/nexus/content/groups/public"

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
  assertCaptured "Installing settings.xml"
  assertCaptured "Should download from JBoss" "Downloading: http://repository.jboss.org/nexus/content/groups/public"

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

testMaven311()
{
  cat > ${BUILD_DIR}/system.properties <<EOF
maven.version=3.1.1
EOF

  createPom "$(withDependency)"

  compile

  assertCapturedSuccess

  _assertMaven311
}

testMaven305()
{
  cat > ${BUILD_DIR}/system.properties <<EOF
maven.version=3.0.5
EOF

  createPom "$(withDependency)"

  compile

  assertCapturedSuccess

  _assertMaven305
}

testMavenUpgrade()
{
    cat > ${BUILD_DIR}/system.properties <<EOF
maven.version=3.0.5
EOF

    createPom "$(withDependency)"

    compile
    assertCapturedSuccess

    _assertMaven305

    cat > ${BUILD_DIR}/system.properties <<EOF
maven.version=3.2.3
EOF

    compile

    assertCapturedSuccess
}

testMavenSkipUpgrade()
{
  cat > ${BUILD_DIR}/system.properties <<EOF
maven.version=3.0.5
EOF

  createPom "$(withDependency)"

  compile

  assertCapturedSuccess

  _assertMaven305

  rm ${BUILD_DIR}/system.properties

  compile

  assertCapturedSuccess

  assertNotCaptured "Installing Maven"
  assertFileMD5 "7d2bdb60388da32ba499f953389207fe" ${CACHE_DIR}/.maven/bin/mvn
  assertTrue "mvn should be executable" "[ -x ${CACHE_DIR}/.maven/bin/mvn ]"
  assertCaptured "Executing: mvn -B -DskipTests=true clean install"
  assertCaptured "BUILD SUCCESS"
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
