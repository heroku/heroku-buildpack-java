#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh
. ${BUILDPACK_HOME}/test/stdlib_stubs.sh

testDetectPomXml()
{
  touch ${BUILD_DIR}/pom.xml

  detect

  assertAppDetected "Java"
}

testDetectPomAtom()
{
  touch ${BUILD_DIR}/pom.atom

  detect

  assertAppDetected "Java"
}

testDetectPomClj()
{
  touch ${BUILD_DIR}/pom.clj

  detect

  assertAppDetected "Java"
}

testDetectPomGroovy()
{
  touch ${BUILD_DIR}/pom.groovy

  detect

  assertAppDetected "Java"
}

testDetectPomRb()
{
  touch ${BUILD_DIR}/pom.rb

  detect

  assertAppDetected "Java"
}

testDetectPomScala()
{
  touch ${BUILD_DIR}/pom.scala

  detect

  assertAppDetected "Java"
}

testDetectYml()
{
  touch ${BUILD_DIR}/pom.yml

  detect

  assertAppDetected "Java"
}

testDetectYaml()
{
  touch ${BUILD_DIR}/pom.yaml

  detect

  assertAppDetected "Java"
}

testNoDetectMissingPomFile()
{
  detect

  assertEquals "1" "${RETURN}"
}

testNoDetectPomFileAsDir()
{
  mkdir -p ${BUILD_DIR}/pom.xml

  detect

  assertEquals "1" "${RETURN}"
}
