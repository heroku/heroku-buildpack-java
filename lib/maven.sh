#!/usr/bin/env bash

# This is technically redundant, since all consumers of this lib will have enabled these,
# however, it helps Shellcheck realise the options under which these functions will run.
set -euo pipefail

BUILDPACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
source "${BUILDPACK_DIR}/lib/java_properties.sh"

maven::get_settings_url() {
	local build_dir="${1}"
	
	if [[ -n "${MAVEN_SETTINGS_PATH:-}" ]]; then
		local absolute_path
		absolute_path=$(cd "${build_dir}" && realpath -m "${MAVEN_SETTINGS_PATH}")
		
		echo "file://${absolute_path}"
	elif [[ -n "${MAVEN_SETTINGS_URL:-}" ]]; then
		echo "${MAVEN_SETTINGS_URL}"
	elif [[ -f "${build_dir}/settings.xml" ]]; then
		echo "file://${build_dir}/settings.xml"
	fi
}

maven::download_settings_xml() {
	local url="${1}"
	
	local target
	target=$(mktemp --suffix=.xml)
	
	if curl --silent --show-error --fail --retry 3 --retry-connrefused --connect-timeout 5 --max-time 10 --location "${url}" --output "${target}"; then
		echo "${target}"
	else
		output::error <<-EOF
			ERROR: Failed to download Maven settings.xml

			The URL specified in MAVEN_SETTINGS_URL couldn't be downloaded. This may be due to:
			- Network connectivity issues
			- Invalid or inaccessible URL
			- Server authentication requirements
			- Temporary server unavailability

			Please verify the URL is correct and accessible, or remove the MAVEN_SETTINGS_URL
			environment variable to use default Maven settings.

			URL: ${url}
		EOF

		exit 1
	fi
}

maven::resolve_settings_file() {
	local url="${1}"
	
	if [[ "${url}" == file://* ]]; then
		echo "${url#file://}"
	else
		maven::download_settings_xml "${url}"
	fi
}

maven::mvn_settings_opt() {
	local build_dir="${1}"
	local cache_dir="${2}"
	
	local url
	url=$(maven::get_settings_url "${build_dir}")

	if [[ -n "${url}" ]]; then
		echo -n "-s $(maven::resolve_settings_file "${url}")"
	fi
}

maven::run_mvn() {
	local build_dir="${1}"
	local cache_dir="${2}"
	local java_opts_extra="${3}"
	local mvn_opts="${4}"

	mkdir -p "${cache_dir}"
	if [[ -f "${build_dir}/mvnw" ]] && [[ -z "$(java_properties::get "${build_dir}/system.properties" "maven.version")" ]]; then
		common::cache_copy ".m2/wrapper" "${cache_dir}" "${build_dir}"
		chmod +x "${build_dir}/mvnw"
		local maven_exe="./mvnw"
	else
		# shellcheck disable=SC2164
		cd "${cache_dir}"

		local maven_home="${cache_dir}/.maven"
		local defined_maven_version
		defined_maven_version=$(java_properties::get "${build_dir}/system.properties" "maven.version")
		local maven_version="${defined_maven_version:-${DEFAULT_MAVEN_VERSION}}"

		output::step "Installing Maven ${maven_version}..."
		local maven_url="https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/${maven_version}/apache-maven-${maven_version}-bin.tar.gz"
		
		# Inlined common::is_supported_maven_version check
		if [[ "${maven_version}" = "${DEFAULT_MAVEN_VERSION}" ]] || curl -I --retry 3 --retry-connrefused --connect-timeout 5 --fail --silent --max-time 5 --location "${maven_url}" >/dev/null; then
			# Inlined common::download_maven
			rm -rf "${maven_home}"
			mkdir -p "${maven_home}"
			curl --fail --retry 3 --retry-connrefused --connect-timeout 5 --silent --max-time 60 --location "${maven_url}" | tar -xzm --strip-components 1 -C "${maven_home}"
			chmod +x "${maven_home}/bin/mvn"
		else
			output::error <<-EOF
				ERROR: You have defined an unsupported Maven version in the system.properties file.

				The default supported version is ${DEFAULT_MAVEN_VERSION}
			EOF
			return 1
		fi

		PATH="${cache_dir}/.maven/bin:${PATH}"
		local maven_exe="mvn"
		# shellcheck disable=SC2164
		cd "${build_dir}"
	fi

	local mvn_settings_opt
	mvn_settings_opt="$(maven::mvn_settings_opt "${build_dir}" "${cache_dir}")"

	export MAVEN_OPTS="-Xmx1024m${java_opts_extra} -Duser.home=${build_dir} -Dmaven.repo.local=${cache_dir}/.m2/repository"

	# shellcheck disable=SC2164
	cd "${build_dir}"

	output::step "Executing Maven"
	echo "$ ${maven_exe} ${mvn_opts}" | output::indent

	# We rely on word splitting for mvn_settings_opt and mvn_opts:
	# shellcheck disable=SC2086
	if ! ${maven_exe} -DoutputFile=target/mvn-dependency-list.log -B ${mvn_settings_opt} ${mvn_opts} | output::indent; then
		output::error <<-EOF
			ERROR: Failed to build app with Maven

			We're sorry this build is failing! If you can't find the issue in application code,
			please submit a ticket so we can help: https://help.heroku.com/
		EOF
		return 1
	fi
}
