#!/usr/bin/env bash

write_mvn_profile() {
  local home=${1}
  mkdir -p ${home}/.profile.d
  cat << EOF > ${home}/.profile.d/maven.sh
export M2_HOME="\$HOME/.maven"
export MAVEN_OPTS="$(_mvn_java_opts "test" "\$HOME" "\$HOME")"
export PATH="\$M2_HOME/bin:\$PATH"
EOF
}