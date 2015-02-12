#!/usr/bin/env bash

if [ -z "$JVM_COMMON_BRANCH" ]; then
  jvmCommonUrl="https://api.github.com/repos/heroku/heroku-buildpack-jvm-common/tarball/${JVM_COMMON_BRANCH}"
fi

hatchet install &&
HATCHET_RETRIES=3 \
HATCHET_DEPLOY_STRATEGY=git \
HATCHET_BUILDPACK_BASE="https://github.com/heroku/heroku-buildpack-java.git" \
HATCHET_BUILDPACK_BRANCH=$(git name-rev HEAD 2> /dev/null | sed 's#HEAD\ \(.*\)#\1#') \
JVM_COMMON_BUILDPACK="${JVM_COMMON_BUILDPACK:-jvmCommonUrl}" \
rspec $@
