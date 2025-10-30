#!/usr/bin/env bash

# This is technically redundant, since all consumers of this lib will have enabled these,
# however, it helps Shellcheck realise the options under which these functions will run.
set -euo pipefail

BUILDPACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
source "${BUILDPACK_DIR}/lib/java_properties.sh"
source "${BUILDPACK_DIR}/lib/util.sh"
source "${BUILDPACK_DIR}/lib/metrics.sh"

export DEFAULT_MAVEN_VERSION="3.9.4"

# Sets up Maven environment and builds the application.
#
# This function handles the complete Maven build process including:
# - Detecting and configuring Maven Wrapper (mvnw) or downloading specified Maven version
# - Setting up Maven repository caching and wrapper caching for faster subsequent builds
# - Configuring MAVEN_OPTS with memory limits and repository locations
# - Resolving settings.xml from MAVEN_SETTINGS_PATH, MAVEN_SETTINGS_URL, or local file
# - Executing the build with the specified Maven goals and options
#
# Usage:
# ```
# maven::setup_maven_and_build_app "${BUILD_DIR}" "${CACHE_DIR}" "${MAVEN_JAVA_OPTS}" "${MAVEN_OPTS}" "${MAVEN_GOALS}"
# ```
function maven::setup_maven_and_build_app() {
	local build_dir="${1}"
	local cache_dir="${2}"
	local maven_java_opts="${3}"
	local maven_opts="${4}"
	local maven_goals="${5}"

	# See: https://maven.apache.org/configure.html#maven_opts-environment-variable
	export MAVEN_OPTS="-Xmx1024m${maven_java_opts:+ ${maven_java_opts}} -Duser.home=${build_dir} -Dmaven.repo.local=${cache_dir}/.m2/repository"

	# Check for incomplete Maven wrapper setup and warn users, regardless of whether
	# the wrapper will be used, to help them fix the issue without failing the build.
	# Not failing the build is legacy behavior, but we will change it in a future version.
	maven::check_wrapper_setup "${build_dir}"

	if maven::should_use_wrapper "${build_dir}"; then
		metrics::set_raw "maven_wrapper" "true"
		local maven_exe="./mvnw"

		util::cache_copy ".m2/wrapper" "${cache_dir}" "${build_dir}"
		chmod +x "${build_dir}/${maven_exe}"
	else
		metrics::set_raw "maven_wrapper" "false"
		local maven_exe="mvn"

		maven_version_selector=$(java_properties::get "${build_dir}/system.properties" "maven.version")

		local maven_install_start_time
		maven_install_start_time=$(util::nowms)

		maven::install_maven "${maven_version_selector:-${DEFAULT_MAVEN_VERSION}}" "${cache_dir}/.maven"

		metrics::set_duration "maven_install_duration" "${maven_install_start_time}"
	fi

	local maven_version="unknown"
	maven_version="$( (cd "${build_dir}" && ${maven_exe} --version 2>/dev/null | awk '/Apache Maven/ {gsub(/\x1b\[[0-9;]*m/, ""); print $3}') || true)"
	metrics::set_string "maven_version" "${maven_version}"

	maven::install_settings_xml "${build_dir}" "${build_dir}/.m2/settings.xml"

	output::step "Executing Maven"

	echo "$ ${maven_exe} ${maven_opts} ${maven_goals}" | output::indent

	# We rely on word splitting for settings_xml_opts, maven_opts, and maven_goals:
	# Intentional word splitting needed for Maven command arguments
	# shellcheck disable=SC2086
	if ! (cd "${build_dir}" && ${maven_exe} -DoutputFile=target/mvn-dependency-list.log -B ${maven_opts} ${maven_goals}) | output::indent; then
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

		metrics::set_string "failure_reason" "execute_maven::non_zero_exit_code"
		return 1
	fi

	util::cache_copy ".m2/wrapper" "${build_dir}" "${cache_dir}"
	rm -rf "${build_dir}/.m2/wrapper"
}

# Downloads and installs the specified Maven version to the given directory.
# Sets up PATH to include the Maven bin directory.
#
# Usage:
# ```
# maven::install_maven "3.9.4" "/path/to/maven/home"
# ```
function maven::install_maven() {
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

		metrics::set_string "failure_reason" "install_maven::version_unavailable"
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

		metrics::set_string "failure_reason" "install_maven::download_error"
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

		metrics::set_string "failure_reason" "install_maven::extraction_error"
		exit 1
	fi

	export PATH="${maven_home}/bin:${PATH}"
	chmod +x "${maven_home}/bin/mvn"
}

# Determines if Maven Wrapper should be used for the given build directory.
# Returns 0 (true) if mvnw exists and no maven.version is specified in system.properties.
#
# Usage:
# ```
# if maven::should_use_wrapper "${BUILD_DIR}"; then
#     echo "Using Maven Wrapper"
# fi
# ```
function maven::should_use_wrapper() {
	local build_dir="${1}"

	# A surprising number of projects don't have a maven-wrapper.properties file,
	# but have an mvnw script. We will enforce correct Maven wrapper setup at some point, but
	# for now, we continue to support this and fall back to not using the wrapper in such cases.
	[[ -f "${build_dir}/mvnw" ]] && [[ -f "${build_dir}/.mvn/wrapper/maven-wrapper.properties" ]] && [[ -z "$(java_properties::get "${build_dir}/system.properties" "maven.version")" ]]
}

# Checks Maven Wrapper setup completeness.
#
# If mvnw exists but required wrapper files are missing, emits a warning
# with instructions for fixing the setup. Does not warn if mvnw is not present.
#
# Usage:
# ```
# maven::check_wrapper_setup "${BUILD_DIR}"
# ```
function maven::check_wrapper_setup() {
	local build_dir="${1}"

	if [[ ! -f "${build_dir}/mvnw" ]]; then
		return 0
	fi

	if [[ ! -f "${build_dir}/.mvn/wrapper/maven-wrapper.properties" ]]; then
		output::warning <<-EOF
			Warning: Maven Wrapper script found without properties file.

			Found mvnw script but missing .mvn/wrapper/maven-wrapper.properties.
			The Maven Wrapper requires both files to function properly.

			To fix this issue, run this command in your project directory
			locally and commit the generated files:
			$ mvn wrapper:wrapper

			Alternatively, if you don't want to use Maven Wrapper, you can
			delete the mvnw file from your project, though the usage of the
			Maven Wrapper is strongly recommended.

			IMPORTANT: This warning will become an error in a future version
			of this buildpack. Please fix this issue as soon as possible.

			For more information about Maven Wrapper, see:
			https://maven.apache.org/tools/wrapper/
			https://devcenter.heroku.com/articles/java-support#specifying-a-maven-version
		EOF

		metrics::set_string "maven_wrapper_incomplete" "true"
	fi
}

# Installs Maven settings.xml to the specified destination.
#
# This is an optional feature - if no settings are found, this function is a no-op.
# If a settings.xml already exists at the destination, it will be preserved and
# this function will exit early, ignoring any other configuration methods.
#
# When no existing settings.xml is found, checks for settings in priority order
# and symlinks local files or downloads remote ones:
# 1. MAVEN_SETTINGS_PATH environment variable (symlinked)
# 2. MAVEN_SETTINGS_URL environment variable (downloaded)
# 3. Local settings.xml file in project directory (symlinked)
#
# Usage:
# ```
# maven::install_settings_xml "${BUILD_DIR}" "${BUILD_DIR}/.m2/settings.xml"
# ```
function maven::install_settings_xml() {
	local build_dir="${1}"
	local settings_destination="${2}"

	mkdir -p "$(dirname "${settings_destination}")"

	# Check if settings.xml already exists and warn if any method would be used
	if [[ -f "${settings_destination}" ]]; then
		metrics::set_string "maven_settings_xml_source_type" "maven_default_location"

		if [[ -n "${MAVEN_SETTINGS_PATH:-}" ]]; then
			output::warning <<-EOF
				Warning: Using existing settings.xml file.

				A settings.xml file already exists at ${settings_destination}.
				However, the MAVEN_SETTINGS_PATH environment variable is set, which
				would normally be used as the settings.xml configuration. The existing
				file will be used.

				If you intended to use the settings from MAVEN_SETTINGS_PATH instead,
				remove the existing settings.xml file at ${settings_destination}.
			EOF
			return
		elif [[ -n "${MAVEN_SETTINGS_URL:-}" ]]; then
			output::warning <<-EOF
				Warning: Using existing settings.xml file.

				A settings.xml file already exists at ${settings_destination}.
				However, the MAVEN_SETTINGS_URL environment variable is set, which
				would normally be used as the settings.xml configuration. The existing
				file will be used.

				If you intended to use the settings from MAVEN_SETTINGS_URL instead,
				remove the existing settings.xml file at ${settings_destination}.
			EOF
			return
		elif [[ -f "${build_dir}/settings.xml" ]]; then
			output::warning <<-EOF
				Warning: Using existing settings.xml file.

				A settings.xml file already exists at ${settings_destination}.
				However, a settings.xml file was also found in the project directory,
				which would normally be used as the settings.xml configuration. The
				existing file will be used.

				If you intended to use the settings from your project directory instead,
				remove the existing settings.xml file at ${settings_destination}.
			EOF
			return
		fi
	fi

	if [[ -n "${MAVEN_SETTINGS_PATH:-}" ]]; then
		local settings_source
		if [[ "${MAVEN_SETTINGS_PATH}" = /* ]]; then
			settings_source="${MAVEN_SETTINGS_PATH}"
		else
			settings_source="${build_dir}/${MAVEN_SETTINGS_PATH}"
		fi

		output::step "Using settings.xml from ${MAVEN_SETTINGS_PATH}"
		metrics::set_string "maven_settings_xml_source_type" "path"
		ln -sf "${settings_source}" "${settings_destination}"
	elif [[ -n "${MAVEN_SETTINGS_URL:-}" ]]; then
		output::step "Using settings.xml from ${MAVEN_SETTINGS_URL}"
		metrics::set_string "maven_settings_xml_source_type" "url"

		if ! curl \
			--silent \
			--show-error \
			--fail \
			--retry 3 \
			--retry-connrefused \
			--connect-timeout 5 \
			--max-time 10 \
			--location \
			--output "${settings_destination}" \
			"${MAVEN_SETTINGS_URL}"; then
			output::error <<-EOF
				Error: Unable to download Maven settings.xml.

				An error occurred while downloading the Maven settings file from:
				${MAVEN_SETTINGS_URL}

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

			metrics::set_string "failure_reason" "settings_xml::download_error"
			exit 1
		fi
	elif [[ -f "${build_dir}/settings.xml" ]]; then
		output::step "Using settings.xml from project directory"
		metrics::set_string "maven_settings_xml_source_type" "app_root"
		ln -sf "${build_dir}/settings.xml" "${settings_destination}"
	fi
}
