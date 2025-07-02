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

maven::mvn_cmd_opts() {
	local scope="${1}"

	if [[ "${scope}" = "compile" ]]; then
		echo -n "${MAVEN_CUSTOM_OPTS:-"-DskipTests"}"
		echo -n " ${MAVEN_CUSTOM_GOALS:-"clean dependency:list install"}"
	elif [[ "${scope}" = "test-compile" ]]; then
		echo -n "${MAVEN_CUSTOM_GOALS:-"clean dependency:resolve-plugins test-compile"}"
	else
		echo -n ""
	fi
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
	if [[ -f "${home}/mvnw" ]] &&
		[[ -f "${home}/.mvn/wrapper/maven-wrapper.properties" ]] &&
		[[ -z "$(common::detect_maven_version "${home}")" ]]; then
		return 0
	else
		return 1
	fi
}

maven::run_mvn() {
	local scope="${1}"
	local home="${2}"
	local maven_install_dir="${3}"

	mkdir -p "${maven_install_dir}"
	if maven::has_maven_wrapper "${home}"; then
		common::cache_copy ".m2/wrapper" "${maven_install_dir}" "${home}"
		chmod +x "${home}/mvnw"
		local maven_exe="./mvnw"
	else
		# shellcheck disable=SC2164
		cd "${maven_install_dir}"

		common::install_maven "${maven_install_dir}" "${home}"
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
	mvn_opts="$(maven::mvn_cmd_opts "${scope}")"

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

maven::write_mvn_profile() {
	local home="${1}"

	mkdir -p "${home}/.profile.d"
	cat <<-EOF >"${home}/.profile.d/maven.sh"
		export M2_HOME="\$HOME/.maven"
		export MAVEN_OPTS="$(maven::mvn_java_opts "test" "\$HOME" "\$HOME")"
		export PATH="\$M2_HOME/bin:\$PATH"
	EOF
}

maven::remove_mvn() {
	local home="${1}"
	local maven_install_dir="${2}"
	if maven::has_maven_wrapper "${home}"; then
		common::cache_copy ".m2/wrapper" "${home}" "${maven_install_dir}"
		rm -rf "${home}/.m2"
	fi
}
