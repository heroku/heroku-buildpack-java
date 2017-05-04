#!/usr/bin/env bash

_mvn_java_opts() {
  local scope=${1}
  local home=${2}
  local cache=${3}

  echo -n "-Xmx1024m"
  if [ "$scope" = "compile" ]; then
    echo -n " $MAVEN_JAVA_OPTS"
  elif [ "$scope" = "test-compile" ]; then
    echo -n ""
  fi

  echo -n " -Duser.home=$home -Dmaven.repo.local=$cache/.m2/repository"
}

_mvn_cmd_opts() {
  local scope=${1}

  if [ "$scope" = "compile" ]; then
    echo -n "${MAVEN_CUSTOM_OPTS:-"-DskipTests"}"
    echo -n " ${MAVEN_CUSTOM_GOALS:-"clean dependency:list install"}"
  elif [ "$scope" = "test-compile" ]; then
    echo -n "${MAVEN_CUSTOM_GOALS:-"clean dependency:resolve-plugins test-compile"}"
  else
    echo -n ""
  fi
}

has_maven_wrapper() {
  local home=${1}
  if [ -f $home/mvnw ] &&
      [ -f $home/.mvn/wrapper/maven-wrapper.jar ] &&
      [ -f $home/.mvn/wrapper/maven-wrapper.properties ] &&
      [ -z "$(detect_maven_version $home)"]; then
    return 0;
  else
    return 1;
  fi
}

run_mvn() {
  local scope=${1}
  local home=${2}
  local mavenInstallDir=${3}

  mkdir -p ${mavenInstallDir}
  if has_maven_wrapper $home; then
    cache_copy ".m2/wrapper" $mavenInstallDir $home
    chmod +x $home/mvnw
    local mavenExe="./mvnw"
    mcount "mvn.version.wrapper"
  else
    cd $mavenInstallDir
    let start=$(nowms)
    install_maven ${mavenInstallDir} ${home}
    mtime "mvn.${scope}.time" "${start}"
    PATH="${mavenInstallDir}/.maven/bin:$PATH"
    local mavenExe="mvn"
    cd $home
  fi

  if [ -n "$MAVEN_SETTINGS_PATH" ]; then
    local mvn_settings_opt="-s $MAVEN_SETTINGS_PATH"
    mcount "mvn.settings.path"
  elif [ -n "$MAVEN_SETTINGS_URL" ]; then
    status_pending "Installing settings.xml"
    mkdir -p ${mavenInstallDir}/.m2
    curl --retry 3 --silent --max-time 10 --location $MAVEN_SETTINGS_URL --output ${mavenInstallDir}/.m2/settings.xml
    status_done
    local mvn_settings_opt="-s $mavenInstallDir/.m2/settings.xml"
    mcount "mvn.settings.url"
  elif [ -f ${home}/settings.xml ]; then
    local mvn_settings_opt="-s ${home}/settings.xml"
    mcount "mvn.settings.file"
  else
    mcount "mvn.settings.default"
  fi

  export MAVEN_OPTS="$(_mvn_java_opts ${scope} ${home} ${mavenInstallDir})"

  cd $home
  local mvnOpts="$(_mvn_cmd_opts ${scope})"
  status "Executing: ${mavenExe} ${mvnOpts}"

  let start=$(nowms)
  ${mavenExe} -DoutputFile=target/mvn-dependency-list.log -B ${mvn_settings_opt} ${mvnOpts} | indent

  if [ "${PIPESTATUS[*]}" != "0 0" ]; then
    error "Failed to build app with Maven
We're sorry this build is failing! If you can't find the issue in application code,
please submit a ticket so we can help: https://help.heroku.com/"
  fi

  mtime "mvn.${scope}.time" "${start}"
}

write_mvn_profile() {
  local home=${1}
  local mvnBinDir=${home}/.maven/bin
  mkdir -p ${home}/.profile.d
  cat << EOF > ${home}/.profile.d/maven.sh
export M2_HOME="${home}/.maven"
export MAVEN_OPTS="$(_mvn_java_opts "test" ${home} ${home})"
export PATH="${mvnBinDir}:\$PATH"
EOF
}
