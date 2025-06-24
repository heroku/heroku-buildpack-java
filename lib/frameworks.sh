#!/usr/bin/env bash

# This is technically redundant, since all consumers of this lib will have enabled these,
# however, it helps Shellcheck realise the options under which these functions will run.
set -euo pipefail

frameworks::is_spring_boot() {
	local build_dir="${1}"

	grep -qs "<groupId>org.springframework.boot" "${build_dir}/pom.xml" &&
		grep -qs "<artifactId>spring-boot" "${build_dir}/pom.xml"
}

frameworks::is_wildfly_swarm() {
	local build_dir="${1}"
	grep -qs "<groupId>org.wildfly.swarm" "${build_dir}/pom.xml"
}

frameworks::is_micronaut() {
	local build_dir="${1}"
	grep -qs "<groupId>io.micronaut" "${build_dir}/pom.xml"
}

frameworks::is_quarkus() {
	local build_dir="${1}"
	grep -qs "<groupId>io.quarkus" "${build_dir}/pom.xml"
}

frameworks::has_postgres() {
	local build_dir="${1}"

	grep -qs "<groupId>org.postgresql" "${build_dir}/pom.xml" ||
		grep -qs "<groupId>postgresql" "${build_dir}/pom.xml" ||
		grep -qs "<groupId>com.impossibl.pgjdbc-ng" "${build_dir}/pom.xml"
}
