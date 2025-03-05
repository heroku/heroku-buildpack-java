#!/usr/bin/env bash

frameworks::is_spring_boot() {
	local build_dir=${1:?}
	test -f "${build_dir}/pom.xml" &&
		test -n "$(grep "<groupId>org.springframework.boot" "${build_dir}/pom.xml")" &&
		test -n "$(grep "<artifactId>spring-boot" "${build_dir}/pom.xml")"
}

frameworks::is_wildfly_swarm() {
	local build_dir=${1:?}
	test -f "${build_dir}/pom.xml" &&
		test -n "$(grep "<groupId>org.wildfly.swarm" "${build_dir}/pom.xml")"
}

frameworks::is_micronaut() {
	local build_dir=${1:?}
	test -f "${build_dir}/pom.xml" &&
		test -n "$(grep "<groupId>io.micronaut" "${build_dir}/pom.xml")"
}

frameworks::is_quarkus() {
	local build_dir=${1:?}
	test -f "${build_dir}/pom.xml" &&
		test -n "$(grep "<groupId>io.quarkus" "${build_dir}/pom.xml")"
}

frameworks::has_postgres() {
	local build_dir=${1:?}
	# shellcheck disable=SC2235
	test -f "${build_dir}/pom.xml" && (
		test -n "$(grep "<groupId>org.postgresql" "${build_dir}/pom.xml")" ||
			test -n "$(grep "<groupId>postgresql" "${build_dir}/pom.xml")" ||
			test -n "$(grep "<groupId>com.impossibl.pgjdbc-ng" "${build_dir}/pom.xml")"
	)
}
