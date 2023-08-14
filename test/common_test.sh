#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh
. ${BUILDPACK_HOME}/test/stdlib_stubs.sh
. ${BUILDPACK_HOME}/lib/common.sh

# Mocks

download_maven() {
  echo "Not actually downloading maven..."
}

status() {
  echo "$1..."
}

status_pending() {
  echo -n "$1..."
}

status_done() {
  echo " done"
}

error_return() {
  echo "$1"
}

error() {
  echo "$1"
}

# Helpers

create_mvn() {
  mkdir -p ${BUILD_DIR}/.maven/bin
  cat > ${BUILD_DIR}/.maven/bin/mvn <<EOF
cat <<MVN
Apache Maven 3.2.1 (ea8b2b07643dbb1b84b6d16e1f08391b666bc1e9; 2014-02-14T11:37:52-06:00)
Maven home: /Users/jkutner/local/apache-maven
Java version: 1.7.0_51, vendor: Oracle Corporation
Java home: /Library/Java/JavaVirtualMachines/jdk1.7.0_51.jdk/Contents/Home/jre
Default locale: en_US, platform encoding: UTF-8
OS name: "mac os x", version: "10.9.4", arch: "x86_64", family: "mac"
MVN
EOF
  chmod +x ${BUILD_DIR}/.maven/bin/mvn
}

# Tests

test_detect_maven_version_supported() {
  cat > ${BUILD_DIR}/system.properties <<EOF
java.runtime.version=1.6
maven.version=3.1.1
EOF
  capture detect_maven_version ${BUILD_DIR}
  assertCapturedEquals "3.1.1"
}

test_detect_maven_version_missing() {
  cat > ${BUILD_DIR}/system.properties <<EOF
java.runtime.version=1.6
EOF
  capture detect_maven_version ${BUILD_DIR}
  assertCapturedEquals ""
}

test_detect_maven_version_with_no_file() {
  capture detect_maven_version ${BUILD_DIR}
  assertCapturedEquals ""
}

test_is_supported_maven_version_default() {
  capture is_supported_maven_version "$DEFAULT_MAVEN_VERSION" "https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/${DEFAULT_MAVEN_VERSION}/apache-maven-${DEFAULT_MAVEN_VERSION}-bin.tar.gz"
  assertCapturedSuccess
}

test_is_supported_maven_version_old() {
  capture is_supported_maven_version "3.6.2" "https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.6.2/apache-maven-3.6.2-bin.tar.gz"
  assertCapturedSuccess
}

test_is_supported_maven_version_no() {
  capture is_supported_maven_version "1.1.1" "https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/1.1.1/apache-maven-1.1.1-bin.tar.gz"
  assertEquals 1 "${RETURN}"
}

test_install_maven() {
  capture install_maven ${BUILD_DIR} ${BUILD_DIR}
  assertCapturedSuccess
  assertCaptured "Installing Maven $DEFAULT_MAVEN_VERSION"
}

test_install_maven_failure() {
  cat > ${BUILD_DIR}/system.properties <<EOF
maven.version=3.0.0
EOF
  capture install_maven ${BUILD_DIR} ${BUILD_DIR}
  assertEquals 1 "${RETURN}"
  assertCaptured "Installing Maven 3.0.0"
  assertCapturedError "Error, you have defined an unsupported Maven version in the system.properties file"
}
