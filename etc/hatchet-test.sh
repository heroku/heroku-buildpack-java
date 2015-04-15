#!/usr/bin/env bash

gem install rspec-retry -v 0.4.0
gem install heroku_hatchet -v 1.4.1

#if [ -n "$JVM_COMMON_BRANCH" ]; then
  #jvmCommonUrl="https://api.github.com/repos/heroku/heroku-buildpack-jvm-common/tarball/${JVM_COMMON_BRANCH}"
#elif [ -n "$JVM_COMMON_BUILDKIT" ]; then
  #jvmCommonUrl="https://codon-buildpacks.s3.amazonaws.com/buildpacks/$JVM_COMMON_BUILDKIT/jvm-common.tgz"
#fi

hatchet install &&
HATCHET_RETRIES=3 \
HATCHET_DEPLOY_STRATEGY=git \
HATCHET_BUILDPACK_BASE="https://github.com/heroku/heroku-buildpack-java.git" \
HATCHET_BUILDPACK_BRANCH=$(git name-rev HEAD 2> /dev/null | sed 's#HEAD\ \(.*\)#\1#') \
rspec $@
