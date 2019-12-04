#!/usr/bin/env bash

is_spring_boot() {
  local buildDir=${1:?}
   test -f ${buildDir}/pom.xml &&
    test -n "$(grep "<groupId>org.springframework.boot" ${buildDir}/pom.xml)" &&
    test -n "$(grep "<artifactId>spring-boot" ${buildDir}/pom.xml)"
}

is_wildfly_swarm() {
  local buildDir=${1:?}
  test -f ${buildDir}/pom.xml &&
    test -n "$(grep "<groupId>org.wildfly.swarm" ${buildDir}/pom.xml)"
}

has_postgres() {
  local buildDir=${1:?}
  test -f ${buildDir}/pom.xml && (
    test -n "$(grep "<groupId>org.postgresql" ${buildDir}/pom.xml)" ||
    test -n "$(grep "<groupId>postgresql" ${buildDir}/pom.xml)" ||
    test -n "$(grep "<groupId>com.impossibl.pgjdbc-ng" ${buildDir}/pom.xml)")
}