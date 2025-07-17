#!/usr/bin/env bash

# This is technically redundant, since all consumers of this lib will have enabled these,
# however, it helps Shellcheck realise the options under which these functions will run.
set -euo pipefail

export DEFAULT_MAVEN_VERSION="3.9.4"

# Copies a subdirectory from source to destination, replacing any existing content.
#
# Usage:
# ```
# common::cache_copy ".m2/wrapper" "${CACHE_DIR}" "${BUILD_DIR}"
# ```
common::cache_copy() {
	local subdirectory="${1}"
	local source_dir="${2}"
	local destination_dir="${3}"
	
	local destination_path="${destination_dir}/${subdirectory}"
	local source_path="${source_dir}/${subdirectory}"
	
	rm -rf "${destination_path:?}"
	
	if [[ -d "${source_path}" ]]; then
		mkdir -p "${destination_path}"
		cp -pr "${source_path}"/. "${destination_path}"
	fi
}
