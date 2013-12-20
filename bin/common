#!/usr/bin/env bash

export_env_file() {
  env_file=$1
  if [ -f "$env_file" ]; then
    whitelisted_env=$(grep -vE "^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH)" "$env_file" || :)
    if [ -n "$whitelisted_env" ]; then
      export $whitelisted_env
    fi
  fi
}
