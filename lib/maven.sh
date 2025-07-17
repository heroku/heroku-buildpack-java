#!/usr/bin/env bash

# This is technically redundant, since all consumers of this lib will have enabled these,
# however, it helps Shellcheck realise the options under which these functions will run.
set -euo pipefail

BUILDPACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
source "${BUILDPACK_DIR}/lib/java_properties.sh"
source "${BUILDPACK_DIR}/lib/util.sh"

export DEFAULT_MAVEN_VERSION="3.9.4"

# Downloads and installs the specified Maven version to the given directory.
#
# Usage:
# ```
# maven::download_and_install "3.9.4" "/path/to/maven/home"
# ```
maven::download_and_install() {
	local maven_version="${1}"
	local maven_home="${2}"

	output::step "Installing Maven ${maven_version}..."

	local maven_url="https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/${maven_version}/apache-maven-${maven_version}-bin.tar.gz"

	mkdir -p "${maven_home}"

	local tarball_path
	tarball_path=$(mktemp)

	local http_status_code
	http_status_code=$(curl \
		--retry 3 \
		--retry-connrefused \
		--connect-timeout 5 \
		--silent \
		--show-error \
		--max-time 60 \
		--location \
		--write-out "%{http_code}" \
		--output "${tarball_path}" \
		"${maven_url}")

	local curl_exit_code=$?

	if [[ "${http_status_code}" == "404" ]]; then
		output::error <<-EOF
			Error: The requested Maven version isn't available.

			Your app's system.properties file specifies a Maven version
			of ${maven_version}, however, we couldn't find that version in the
			Maven repository.

			Check that this Maven version has been released upstream:
			https://maven.apache.org/docs/history.html

			If it has, make sure that you are using the latest version
			of this buildpack, and haven't pinned to an older release:
			https://devcenter.heroku.com/articles/managing-buildpacks#view-your-buildpacks
			https://devcenter.heroku.com/articles/managing-buildpacks#classic-buildpacks-references

			We also strongly recommend using the Maven Wrapper instead of
			pinning to an exact Maven version such as ${maven_version}.
			Remove the maven.version property from your system.properties file
			and set up Maven Wrapper in your project, which will automatically
			download and use the correct Maven version.

			Learn more about Maven Wrapper:
			https://maven.apache.org/wrapper/

			The default supported version is ${DEFAULT_MAVEN_VERSION}.
		EOF

		exit 1
	elif [[ "${curl_exit_code}" -ne 0 || "${http_status_code}" != "200" ]]; then
		output::error <<-EOF
			Error: Unable to download Maven.

			An error occurred while downloading the Maven archive from:
			${maven_url}

			In some cases, this happens due to a temporary issue with
			the network connection or server.

			First, make sure that you are using the latest version
			of this buildpack, and haven't pinned to an older release:
			https://devcenter.heroku.com/articles/managing-buildpacks#view-your-buildpacks
			https://devcenter.heroku.com/articles/managing-buildpacks#classic-buildpacks-references

			Then try building again to see if the error resolves itself.

			HTTP status code: ${http_status_code}, curl exit code: ${curl_exit_code}
		EOF

		exit 1
	fi

	local error_log
	error_log=$(mktemp)

	if ! tar -xzm --strip-components 1 -C "${maven_home}" -f "${tarball_path}" 2>&1 | tee "${error_log}"; then
		output::error <<-EOF
			Error: Unable to extract Maven.

			An error occurred while extracting the Maven archive:
			${maven_url}

			In some cases, this happens due to a corrupted download
			or a temporary issue with the archive format.

			First, make sure that you are using the latest version
			of this buildpack, and haven't pinned to an older release:
			https://devcenter.heroku.com/articles/managing-buildpacks#view-your-buildpacks
			https://devcenter.heroku.com/articles/managing-buildpacks#classic-buildpacks-references

			Then try building again to see if the error resolves itself.

			Error details: $(head --lines=1 "${error_log}" || true)
		EOF

		exit 1
	fi

	chmod +x "${maven_home}/bin/mvn"
}

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
			Error: Unable to download Maven settings.xml.

			An error occurred while downloading the Maven settings file from:
			${url}

			In some cases, this happens due to a temporary issue with
			the network connection or server, or because the URL is
			inaccessible or requires authentication.

			Check that the URL in your MAVEN_SETTINGS_URL environment
			variable is correct and publicly accessible. If the settings file
			is not needed, you can remove the MAVEN_SETTINGS_URL environment variable 
			to use default Maven settings.

			Learn more about Maven settings configuration:
			https://devcenter.heroku.com/articles/using-a-custom-maven-settings-xml
		EOF

		exit 1
	fi
}

maven::mvn_settings_opt() {
	local build_dir="${1}"
	local cache_dir="${2}"

	local url
	url=$(maven::get_settings_url "${build_dir}")

	if [[ -n "${url}" ]]; then
		local settings_file
		if [[ "${url}" == file://* ]]; then
			settings_file="${url#file://}"
		else
			settings_file=$(maven::download_settings_xml "${url}")
		fi
		echo -n "-s ${settings_file}"
	fi
}

maven::run_mvn() {
	local build_dir="${1}"
	local cache_dir="${2}"
	local java_opts_extra="${3}"
	local mvn_opts="${4}"

	local use_maven_wrapper=0
	if [[ -f "${build_dir}/mvnw" ]] && [[ -z "$(java_properties::get "${build_dir}/system.properties" "maven.version")" ]]; then
		use_maven_wrapper=1
	fi

	if ((use_maven_wrapper)); then
		util::cache_copy ".m2/wrapper" "${cache_dir}" "${build_dir}"
		chmod +x "${build_dir}/mvnw"
		local maven_exe="./mvnw"
	else
		local defined_maven_version
		defined_maven_version=$(java_properties::get "${build_dir}/system.properties" "maven.version")
		local maven_version="${defined_maven_version:-${DEFAULT_MAVEN_VERSION}}"

		maven::download_and_install "${maven_version}" "${cache_dir}/.maven"

		PATH="${cache_dir}/.maven/bin:${PATH}"
		local maven_exe="mvn"
	fi

	local mvn_settings_opt
	mvn_settings_opt="$(maven::mvn_settings_opt "${build_dir}" "${cache_dir}")"

	export MAVEN_OPTS="-Xmx1024m${java_opts_extra:+ ${java_opts_extra}} -Duser.home=${build_dir} -Dmaven.repo.local=${cache_dir}/.m2/repository"

	output::step "Executing Maven"

	cd "${build_dir}"
	echo "$ ${maven_exe} ${mvn_opts}" | output::indent

	# We rely on word splitting for mvn_settings_opt and mvn_opts:
	# shellcheck disable=SC2086
	if ! ${maven_exe} -DoutputFile=target/mvn-dependency-list.log -B ${mvn_settings_opt} ${mvn_opts} | output::indent; then
		output::error <<-EOF
			Error: Maven build failed.

			An error occurred during the Maven build process. This usually
			indicates an issue with your application's dependencies, configuration,
			or source code.

			First, check the build output above for specific error messages
			from Maven that might indicate what went wrong. Common issues include:

			- Missing or incompatible dependencies in your POM
			- Compilation errors in your application source code
			- Test failures (if tests are enabled during the build)
			- Invalid Maven configuration or settings
			- Using an incompatible OpenJDK version for your project

			If you're unable to determine the cause from the Maven output,
			try building your application locally with the same Maven command
			to reproduce and debug the issue.
		EOF

		return 1
	fi

	if ((use_maven_wrapper)); then
		util::cache_copy ".m2/wrapper" "${build_dir}" "${cache_dir}"
		rm -rf "${build_dir}/.m2"
	fi
}
