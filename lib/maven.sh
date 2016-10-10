#!/usr/bin/env bash

_mvn_java_opts() {
  local scope=${1}
  local home=${2}

  echo -n "-Xmx1024m"
  if [ "$scope" = "compile" ]; then
    echo -n " $MAVEN_JAVA_OPTS"
  elif [ "$scope" = "test-compile" ]; then
    echo -n ""
  fi

  echo -n " -Duser.home=$home -Dmaven.repo.local=$home/.m2/repository"
}

_mvn_cmd_opts() {
  local scope=${1}

  echo -n "-B"
  if [ "$scope" = "compile" ]; then
    echo -n " ${MAVEN_CUSTOM_OPTS:-"-DskipTests"}"
    echo -n " ${MAVEN_CUSTOM_GOALS:-"clean dependency:list install"}"
  elif [ "$scope" = "test-compile" ]; then
    echo -n " ${MAVEN_CUSTOM_GOALS:-"clean dependency:resolve-plugins test-compile"}"
  else
    echo -n "clean"
  fi
}

run_mvn() {
  local scope=${1}
  local home=${2}
  local mvnDir=${3}

  if [ -n "$MAVEN_SETTINGS_PATH" ]; then
    MAVEN_SETTINGS_OPT="-s $MAVEN_SETTINGS_PATH"
  elif [ -n "$MAVEN_SETTINGS_URL" ]; then
    status_pending "Installing settings.xml"
    mkdir -p .m2
    curl --retry 3 --silent --max-time 10 --location $MAVEN_SETTINGS_URL --output .m2/settings.xml
    status_done
    MAVEN_SETTINGS_OPT="-s $home/.m2/settings.xml"
  elif [ -f $home/settings.xml ]; then
    MAVEN_SETTINGS_OPT="-s $home/settings.xml"
  else
    unset MAVEN_SETTINGS_OPT
  fi

  export MAVEN_OPTS="$(_mvn_java_opts ${scope} ${home})"

  status "Executing: mvn ${mvnOpts}"
  ${mvnDir}/bin/mvn -DoutputFile=target/mvn-dependency-list.log $(_mvn_cmd_opts ${scope}) | indent

  if [ "${PIPESTATUS[*]}" != "0 0" ]; then
    error "Failed to setup app with Maven
We're sorry this build is failing! If you can't find the issue in application code,
please submit a ticket so we can help: https://help.heroku.com/"
  fi
}

write_mvn_profile() {
  local buildDir=${1}
  local mavenDir=${buildDir}/.maven
  mkdir -p ${buildDir}/.profile.d
  cat << EOF > ${buildDir}/.profile.d/maven.sh
export MAVEN_OPTS="$(_mvn_java_opts "test")"
export PATH="${mavenDir}/bin:\$PATH"
EOF
}
