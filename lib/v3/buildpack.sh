#!/usr/bin/env bash

bp_install_or_reuse_toolbox() {
  local layer_dir=$1
  local jqUrl="https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64"
  local jqSha="c6b3a7d7d3e7b70c6f51b706a3b90bd01833846c54d32ca32f0027f00226ff6d"
  local yjUrl="https://github.com/sclevine/yj/releases/download/v2.0/yj-linux"
  local yjSha="db2b94b7fbf0941b6af9d30c1e7d43e41be62edad59d711b5c760ad5b13f7d6c"

  mkdir -p "${layer_dir}/bin"

  if [[ ! -f "${layer_dir}/bin/jq" ]]; then
    local jqBin="${layer_dir}/bin/jq"
    curl -o "$jqBin" -Ls "$jqUrl" && chmod +x "$jqBin"
    local actualSha="$(shasum -a 256 ${jqBin} | awk '{ print $1 }')"
    if [ "$actualSha" != "$jqSha" ]; then
      echo "Invalid jq sha: $actualSha"
      exit 1
    fi
  fi

  if [[ ! -f "${layer_dir}/bin/yj" ]]; then
    local yjBin="${layer_dir}/bin/yj"
    curl -o "$yjBin" -Ls "$yjUrl" && chmod +x "$yjBin"
    local actualSha="$(shasum -a 256 $yjBin | awk '{ print $1 }')"
    if [ "$actualSha" != "$yjSha" ]; then
      echo "Invalid yj sha: $actualSha"
      exit 1
    fi
  fi

  echo "cache = true" > "${layer_dir}.toml"
  echo "build = true" >> "${layer_dir}.toml"
  echo "launch = false" >> "${layer_dir}.toml"
}

bp_layer_has_key?() {
  local layerDir="${1:?}"
  local key="${2:?}"
  local value="${3:?}"
  local layerMetadata="${layerDir}.toml"

  if [[ "$value" == "$([[ -f "${layerMetadata}" ]] && cat "${layerMetadata}" | yj -t | jq -r "${key}")" ]]; then
    return 0
  fi
  return 1
}

bp_layer_metadata_create() {
  local launch="${1:-false}"
  local cache="${2:-false}"
  local build="${3:-false}"
  local metadata="${4:-}"

  cat <<EOF
launch = ${launch}
cache = ${cache}
build = ${build}

[metadata]
${metadata}
EOF
}

bp_layer_init() {
  local layers_dir="${1:?}"
  local name="${2:?}"
  local metadata="${3:?}"

  local layer_dir="${layers_dir}/${name}"
  local layer_metadata="${layer_dir}.toml"

  mkdir -p "${layer_dir}"
  echo "${metadata}" > "${layer_metadata}"

  echo "${layer_dir}"
}
