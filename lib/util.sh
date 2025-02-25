#!/usr/bin/env bash

_env_blacklist() {
	local regex=${1:-''}
	if [ -n "${regex}" ]; then
		regex="|${regex}"
	fi

	echo "^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH${regex})$"
}

export_env_dir() {
	local env_dir=${1:-$ENV_DIR}
	local whitelist=${2:-''}

	local blacklist
	blacklist="$(_env_blacklist "${3}")"

	if [ -d "$env_dir" ]; then
		for e in "${env_dir}"/*; do
			echo "${e}" | grep -E "${whitelist}" | grep -qvE "${blacklist}" &&
				export "${e}=$(cat "${env_dir}/${e}")"
			:
		done
	fi
}

nowms() {
	date +%s%3N
}
