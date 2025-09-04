#!/usr/bin/env bash

# This is technically redundant, since all consumers of this lib will have enabled these,
# however, it helps Shellcheck realise the options under which these functions will run.
set -euo pipefail

# Detects if the application is a Spring Boot project by checking for Spring Boot
# group and artifact IDs in the pom.xml file.
#
# Usage:
# ```
# if frameworks::is_spring_boot "${BUILD_DIR}"; then
#     echo "Spring Boot application detected"
# fi
# ```
function frameworks::is_spring_boot() {
	local build_dir="${1}"

	grep -qs "<groupId>org.springframework.boot" "${build_dir}/pom.xml" &&
		grep -qs "<artifactId>spring-boot" "${build_dir}/pom.xml"
}

# Detects if the application uses WildFly Swarm by checking for WildFly Swarm
# group ID in the pom.xml file.
#
# Usage:
# ```
# if frameworks::is_wildfly_swarm "${BUILD_DIR}"; then
#     echo "WildFly Swarm application detected"
# fi
# ```
function frameworks::is_wildfly_swarm() {
	local build_dir="${1}"
	grep -qs "<groupId>org.wildfly.swarm" "${build_dir}/pom.xml"
}

# Detects if the application uses Micronaut by checking for Micronaut
# group ID in the pom.xml file.
#
# Usage:
# ```
# if frameworks::is_micronaut "${BUILD_DIR}"; then
#     echo "Micronaut application detected"
# fi
# ```
function frameworks::is_micronaut() {
	local build_dir="${1}"
	grep -qs "<groupId>io.micronaut" "${build_dir}/pom.xml"
}

# Detects if the application uses Quarkus by checking for Quarkus
# group ID in the pom.xml file.
#
# Usage:
# ```
# if frameworks::is_quarkus "${BUILD_DIR}"; then
#     echo "Quarkus application detected"
# fi
# ```
function frameworks::is_quarkus() {
	local build_dir="${1}"
	grep -qs "<groupId>io.quarkus" "${build_dir}/pom.xml"
}

# Detects if the application has PostgreSQL dependencies by checking for
# PostgreSQL-related group IDs in the pom.xml file.
#
# Usage:
# ```
# if frameworks::has_postgres "${BUILD_DIR}"; then
#     echo "PostgreSQL dependency detected"
# fi
# ```
function frameworks::has_postgres() {
	local build_dir="${1}"

	grep -qs "<groupId>org.postgresql" "${build_dir}/pom.xml" ||
		grep -qs "<groupId>postgresql" "${build_dir}/pom.xml" ||
		grep -qs "<groupId>com.impossibl.pgjdbc-ng" "${build_dir}/pom.xml"
}
