#!/usr/bin/env bash

# This is technically redundant, since all consumers of this lib will have enabled these,
# however, it helps Shellcheck realise the options under which these functions will run.
set -euo pipefail

maven::mvn_java_opts() {
	local scope="${1}"
	local home="${2}"
	local cache="${3}"

	echo -n "-Xmx1024m"
	if [[ "${scope}" = "compile" ]]; then
		echo -n " ${MAVEN_JAVA_OPTS:-""}"
	elif [[ "${scope}" = "test-compile" ]]; then
		echo -n ""
	fi

	echo -n " -Duser.home=${home} -Dmaven.repo.local=${cache}/.m2/repository"
}

maven::mvn_settings_opt() {
	local home="${1}"
	local maven_install_dir="${2}"

	if [[ -n "${MAVEN_SETTINGS_PATH:-}" ]]; then
		echo -n "-s ${MAVEN_SETTINGS_PATH}"
	elif [[ -n "${MAVEN_SETTINGS_URL:-}" ]]; then
		local settings_xml="${maven_install_dir}/.m2/settings.xml"
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
	elif [[ -f "${home}/settings.xml" ]]; then
		echo -n "-s ${home}/settings.xml"
	else
		echo -n ""
	fi
}

maven::has_maven_wrapper() {
	local home="${1}"
	[[ -f "${home}/mvnw" ]] && [[ -f "${home}/.mvn/wrapper/maven-wrapper.properties" ]]
}

maven::run_mvn() {
	local scope="${1}"
	local home="${2}"
	local maven_install_dir="${3}"

	mkdir -p "${maven_install_dir}"
	if maven::has_maven_wrapper "${home}" && [[ -z "$(common::detect_maven_version "${home}")" ]]; then
		common::cache_copy ".m2/wrapper" "${maven_install_dir}" "${home}"
		chmod +x "${home}/mvnw"
		local maven_exe="./mvnw"
	else
		# shellcheck disable=SC2164
		cd "${maven_install_dir}"

		local maven_home="${maven_install_dir}/.maven"
		local defined_maven_version
		defined_maven_version=$(common::detect_maven_version "${home}")
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

		PATH="${maven_install_dir}/.maven/bin:${PATH}"
		local maven_exe="mvn"
		# shellcheck disable=SC2164
		cd "${home}"
	fi

	local mvn_settings_opt
	mvn_settings_opt="$(maven::mvn_settings_opt "${home}" "${maven_install_dir}")"

	MAVEN_OPTS="$(maven::mvn_java_opts "${scope}" "${home}" "${maven_install_dir}")"
	export MAVEN_OPTS

	# shellcheck disable=SC2164
	cd "${home}"
	local mvn_opts
	if [[ "${scope}" = "compile" ]]; then
		mvn_opts="${MAVEN_CUSTOM_OPTS:-"-DskipTests"} ${MAVEN_CUSTOM_GOALS:-"clean dependency:list install"}"
	elif [[ "${scope}" = "test-compile" ]]; then
		mvn_opts="${MAVEN_CUSTOM_GOALS:-"clean dependency:resolve-plugins test-compile"}"
	else
		mvn_opts=""
	fi

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


