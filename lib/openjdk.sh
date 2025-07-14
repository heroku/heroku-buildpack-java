#!/usr/bin/env bash

# This is technically redundant, since all consumers of this lib will have enabled these,
# however, it helps Shellcheck realise the options under which these functions will run.
set -euo pipefail

openjdk::install_openjdk_via_jvm_common_buildpack() {
	local build_dir="${1}"
	# The install_openjdk function from the JVM common buildpack requires the path to the host buildpack to write to the
	# export script so that OpenJDK can be found by subsequent buildpacks.
	local host_buildpack_dir="${2}"

	# Legacy behaviour for customers and testing code can override the download location of the heroku/jvm buildpack
	# with JVM_COMMON_BUILDPACK for testing and debugging purposes.
	local jvm_common_buildpack_tarball_url="${JVM_COMMON_BUILDPACK:-https://buildpack-registry.s3.us-east-1.amazonaws.com/buildpacks/heroku/jvm.tgz}"

	local jvm_common_buildpack_tarball_path
	jvm_common_buildpack_tarball_path=$(mktemp)

	local jvm_common_buildpack_dir
	jvm_common_buildpack_dir=$(mktemp -d)

	curl --silent --fail --retry 3 --retry-connrefused --connect-timeout 5 --location "${jvm_common_buildpack_tarball_url}" -o "${jvm_common_buildpack_tarball_path}"
	tar -xzm --directory "${jvm_common_buildpack_dir}" --strip-components=1 -f "${jvm_common_buildpack_tarball_path}"

	# This script translates non-JDBC compliant DATABASE_URL (and similar) environment variables into their
	# JDBC compatible counterparts and writes them to "JDBC_" prefixed environment variables. We source this script
	# here to allow customers to connect to their databases via JDBC during the build. If no database environment
	# variables are present, this script does nothing.
	# shellcheck source=/dev/null
	source "${jvm_common_buildpack_dir}/opt/jdbc.sh"

	# shellcheck source=/dev/null
	source "${jvm_common_buildpack_dir}/bin/java"

	# See: https://github.com/heroku/heroku-buildpack-jvm-common/blob/main/bin/java
	install_openjdk "${build_dir}" "${host_buildpack_dir}"
}
