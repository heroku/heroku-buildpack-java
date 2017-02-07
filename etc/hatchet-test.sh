#!/usr/bin/env bash

set -e

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  echo "Skipping Hatchet tests on Pull Request."
else
  export HEROKU_API_KEY="$(heroku auth:token)"
  export HATCHET_RETRIES=3
  export HATCHET_DEPLOY_STRATEGY=git
  export HATCHET_BUILDPACK_BASE="https://github.com/heroku/heroku-buildpack-java.git"
  export HATCHET_BUILDPACK_BRANCH=$(git name-rev HEAD 2> /dev/null | sed 's#HEAD\ \(.*\)#\1#')

  ./mvnw verify
fi
