#!/usr/bin/env bash

setupJavaEnv() {
  # like jvmcommon but without 'ulimit -u', which doesn't work on Travis
  export JAVA_HOME="$BUILD_DIR/.jdk"
  export LD_LIBRARY_PATH="$JAVA_HOME/jre/lib/amd64/server:$LD_LIBRARY_PATH"
  export PATH="$BUILD_DIR/.heroku/bin:$JAVA_HOME/bin:$PATH"
}

createPom()
{
  cat > ${BUILD_DIR:?}/pom.xml <<EOF
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

  if [ ! -z "${1:-}" ]; then
    settings_file="$1"
  else
    settings_file="${BUILD_DIR:?}/settings.xml"
  fi

  cat > $settings_file <<EOF
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

_mavenDir() {
  if [ -n "$CNB_STACK_ID" ]; then
    echo "${LAYERS_DIR}/maven"
  else
    echo "$CACHE_DIR"
  fi
}

_assertMaven325() {
  local installDir="$(_mavenDir)"
  assertCaptured "Wrong Maven Installed" "Installing Maven 3.2.5"
  assertFileMD5 "9d4c6b79981a342940b9eff660070748" ${installDir}/.maven/bin/mvn
  assertTrue "mvn should be executable" "[ -x ${installDir}/.maven/bin/mvn ]"

  assertCaptured "Unexpected mvn command" "mvn -DskipTests clean dependency:list install"
  assertCaptured "Build was not successful" "BUILD SUCCESS"
}

_assertMaven339() {
  local installDir="$(_mavenDir)"
  assertCaptured "Wrong Maven Installed" "Installing Maven 3.3.9"
  assertFileMD5 "b34974f4c849ec2ae6481651e1f24ef1" ${installDir}/.maven/bin/mvn
  assertTrue "mvn should be executable" "[ -x ${installDir}/.maven/bin/mvn ]"

  assertCaptured "Unexpected mvn command" "mvn -DskipTests clean dependency:list install"
  assertCaptured "Build was not successful" "BUILD SUCCESS"
}

_assertMaven354() {
  local installDir="$(_mavenDir)"
  assertCaptured "Wrong Maven Installed" "Installing Maven 3.5.4"
  assertFileMD5 "833f5bcc6ee59f6716223f866570bc88" ${installDir}/.maven/bin/mvn
  assertTrue "mvn should be executable" "[ -x ${installDir}/.maven/bin/mvn ]"

  assertCaptured "Unexpected mvn command" "mvn -DskipTests clean dependency:list install"
  assertCaptured "Build was not successful" "BUILD SUCCESS"
}

_assertMavenLatest() {
  local installDir="$(_mavenDir)"
  assertCaptured "Wrong Maven Installed" "Installing Maven 3.6.2"
  assertFileMD5 "833f5bcc6ee59f6716223f866570bc88" ${installDir}/.maven/bin/mvn
  assertTrue "mvn should be executable" "[ -x ${installDir}/.maven/bin/mvn ]"

  assertCaptured "Unexpected mvn command" "mvn -DskipTests clean dependency:list install"
  assertCaptured "Build was not successful" "BUILD SUCCESS"
}
