#!/usr/bin/env bash

status() {
  local color="\033[0;35m"
  local no_color="\033[0m"
  echo -e "\n${color}[${1:-""}]${no_color}"
}

status_pending() {
  status "$@"
}

status_done() {
  return 0
}

indent() {
  case $(uname) in
    Darwin) sed -l "";; # mac/bsd sed: -l buffers on line boundaries
    *)      sed -u "";; # unix/gnu sed: -u unbuffered (arbitrary) chunks of data
  esac
}

error() {
  (>&2 echo "$@")
  exit 1
}

error_return() {
  (>&2 echo "$@")
}

info() {
  echo -e "${1:-""}"
}

debug() {
  echo -e "${1:-""}"
}

curl_retry_on_18() {
	local ec=18;
	local attempts=0;
	while (( ec == 18 && attempts++ < 3 )); do
		curl "$@" # -C - would return code 33 if unsupported by server
		ec=$?
	done
	return $ec
}

# Usage: $ _env-blacklist pattern
# Outputs a regex of default blacklist env vars.
_env_blacklist() {
  local regex=${1:-''}
  if [ -n "$regex" ]; then
    regex="|$regex"
  fi
  echo "^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH$regex)$"
}

# Usage: $ export-env ENV_DIR WHITELIST BLACKLIST
# Exports the environment variables defined in the given directory.
export_env() {
  local env_dir=${1:-$ENV_DIR}
  local whitelist=${2:-''}
  local blacklist
  blacklist="$(_env_blacklist "$3")"
  if [ -d "$env_dir" ]; then
    # Environment variable names won't contain characters affected by:
    # shellcheck disable=SC2045
    for e in $(ls "$env_dir"); do
      echo "$e" | grep -E "$whitelist" | grep -qvE "$blacklist" &&
      export "$e=$(cat "$env_dir/$e")"
      :
    done
  fi
}

mtime() {
  # no-op
  return 0
}

mcount() {
  # no-op
  return 0
}

nowms() {
  date +%s%3N
}
