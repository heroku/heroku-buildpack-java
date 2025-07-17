#!/usr/bin/env bash

# This is technically redundant, since all consumers of this lib will have enabled these,
# however, it helps Shellcheck realise the options under which these functions will run.
set -euo pipefail

export DEFAULT_MAVEN_VERSION="3.9.4"

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
