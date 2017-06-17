#!/usr/bin/env bash

set -e

if [ -z "$HEROKU_API_KEY" ]; then
  echo "Missing \$HEROKU_API_KEY. Skipping."
  exit 0
elif [ -n "$CIRCLE_BRANCH" ]; then
  export HATCHET_BUILDPACK_BRANCH="$CIRCLE_BRANCH"
elif [ -n "$TRAVIS_PULL_REQUEST_BRANCH" ]; then
  export HATCHET_BUILDPACK_BRANCH="$TRAVIS_PULL_REQUEST_BRANCH"
else
  export HATCHET_BUILDPACK_BRANCH=$(git name-rev HEAD 2> /dev/null | sed 's#HEAD\ \(.*\)#\1#')
fi

export HATCHET_RETRIES=3
export HATCHET_APP_LIMIT=20
export HATCHET_DEPLOY_STRATEGY=git
export HATCHET_BUILDPACK_BASE="https://github.com/heroku/heroku-buildpack-java.git"

./mvnw verify
