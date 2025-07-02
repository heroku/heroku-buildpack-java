#!/usr/bin/env bash

# This is technically redundant, since all consumers of this lib will have enabled these,
# however, it helps Shellcheck realise the options under which these functions will run.
set -euo pipefail

export DEFAULT_MAVEN_VERSION="3.9.4"

common::install_maven() {
	local install_dir="${1}"
	local build_dir="${2}"
	local maven_home="${install_dir}/.maven"

	local defined_maven_version
	defined_maven_version=$(common::detect_maven_version "${build_dir}")

	local maven_version="${defined_maven_version:-${DEFAULT_MAVEN_VERSION}}"

	output::step "Installing Maven ${maven_version}..."
	local maven_url="https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/${maven_version}/apache-maven-${maven_version}-bin.tar.gz"
	if common::is_supported_maven_version "${maven_version}" "${maven_url}"; then
		common::download_maven "${maven_url}" "${maven_home}"
	else
		output::error <<-EOF
			ERROR: You have defined an unsupported Maven version in the system.properties file.

			The default supported version is ${DEFAULT_MAVEN_VERSION}
		EOF
		return 1
	fi
}

common::download_maven() {
	local maven_url="${1}"
	local install_dir="${2}"

	rm -rf "${install_dir}"
	mkdir -p "${install_dir}"
	curl --fail --retry 3 --retry-connrefused --connect-timeout 5 --silent --max-time 60 --location "${maven_url}" | tar -xzm --strip-components 1 -C "${install_dir}"
	chmod +x "${install_dir}/bin/mvn"
}

common::is_supported_maven_version() {
	local maven_version="${1}"
	local maven_url="${2:?}"
	if [[ "${maven_version}" = "${DEFAULT_MAVEN_VERSION}" ]]; then
		return 0
	elif curl -I --retry 3 --retry-connrefused --connect-timeout 5 --fail --silent --max-time 5 --location "${maven_url}" >/dev/null; then
		return 0
	else
		return 1
	fi
}

common::detect_maven_version() {
	local base_dir="${1}"
	if [[ -f "${base_dir}/system.properties" ]]; then
		local maven_version
		maven_version=$(common::get_app_system_value "${base_dir}/system.properties" "maven.version")
		if [[ -n "${maven_version}" ]]; then
			echo "${maven_version}"
		else
			echo ""
		fi
	else
		echo ""
	fi
}

common::get_app_system_value() {
	local file="${1?No file specified}"
	local key="${2?No key specified}"

	# escape for regex
	local escaped_key
	# shellcheck disable=SC2001
	escaped_key="$(echo "${key}" | sed "s/\./\\\./g")"

	[[ -f "${file}" ]] &&
		grep -E "^${escaped_key}[[:space:]=]+" "${file}" |
		sed -E -e "s/${escaped_key}([\ \t]*=[\ \t]*|[\ \t]+)([A-Za-z0-9\.-]*).*/\2/g"
}

common::cache_copy() {
	local rel_dir="${1}"
	local from_dir="${2}"
	local to_dir="${3}"
	rm -rf "${to_dir:?}/${rel_dir:?}"
	if [[ -d "${from_dir}/${rel_dir}" ]]; then
		mkdir -p "${to_dir}/${rel_dir}"
		cp -pr "${from_dir}/${rel_dir}"/. "${to_dir}/${rel_dir}"
	fi
}

common::install_jdk() {
	local install_dir="${1}"
	local cache_dir="${2}"

	JVM_COMMON_BUILDPACK=${JVM_COMMON_BUILDPACK:-https://buildpack-registry.s3.us-east-1.amazonaws.com/buildpacks/heroku/jvm.tgz}
	mkdir -p /tmp/jvm-common
	curl --fail --retry 3 --retry-connrefused --connect-timeout 5 --silent --location "${JVM_COMMON_BUILDPACK}" | tar xzm -C /tmp/jvm-common --strip-components=1
	#shellcheck source=/dev/null
	source /tmp/jvm-common/bin/java
	#shellcheck source=/dev/null
	source /tmp/jvm-common/opt/jdbc.sh

	install_java_with_overlay "${install_dir}" "${cache_dir}"
}
