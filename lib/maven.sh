#!/usr/bin/env bash

# This is technically redundant, since all consumers of this lib will have enabled these,
# however, it helps Shellcheck realise the options under which these functions will run.
set -euo pipefail

maven::mvn_java_opts() {
	local build_dir="${1}"
	local cache_dir="${2}"
	local java_opts_extra="${3}"

	echo -n "-Xmx1024m${java_opts_extra} -Duser.home=${build_dir} -Dmaven.repo.local=${cache_dir}/.m2/repository"
}

maven::mvn_settings_opt() {
	local build_dir="${1}"
	local cache_dir="${2}"

	if [[ -n "${MAVEN_SETTINGS_PATH:-}" ]]; then
		echo -n "-s ${MAVEN_SETTINGS_PATH}"
	elif [[ -n "${MAVEN_SETTINGS_URL:-}" ]]; then
		local settings_xml="${cache_dir}/.m2/settings.xml"
		mkdir -p "$(dirname "${settings_xml}")"
		curl --retry 3 --retry-connrefused --connect-timeout 5 --silent --max-time 10 --location "${MAVEN_SETTINGS_URL}" --output "${settings_xml}"
		if [[ -f "${settings_xml}" ]]; then
			echo -n "-s ${settings_xml}"
		else
			output::error <<-EOF
				ERROR: Could not download settings.xml from the URL defined in MAVEN_SETTINGS_URL!
			EOF
			return 1
		fi
	elif [[ -f "${build_dir}/settings.xml" ]]; then
		echo -n "-s ${build_dir}/settings.xml"
	else
		echo -n ""
	fi
}

maven::has_maven_wrapper() {
	local build_dir="${1}"
	[[ -f "${build_dir}/mvnw" ]] && [[ -f "${build_dir}/.mvn/wrapper/maven-wrapper.properties" ]]
}

maven::run_mvn() {
	local build_dir="${1}"
	local cache_dir="${2}"
	local java_opts_extra="${3}"
	local mvn_opts="${4}"

	mkdir -p "${cache_dir}"
	if maven::has_maven_wrapper "${build_dir}" && [[ -z "$(common::detect_maven_version "${build_dir}")" ]]; then
		common::cache_copy ".m2/wrapper" "${cache_dir}" "${build_dir}"
		chmod +x "${build_dir}/mvnw"
		local maven_exe="./mvnw"
	else
		# shellcheck disable=SC2164
		cd "${cache_dir}"

		local maven_home="${cache_dir}/.maven"
		local defined_maven_version
		defined_maven_version=$(common::detect_maven_version "${build_dir}")
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

	MAVEN_OPTS="$(maven::mvn_java_opts "${build_dir}" "${cache_dir}" "${java_opts_extra}")"
	export MAVEN_OPTS

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


