#!/bin/bash

set -e

BP_NAME=${1:-"heroku/java"}

curVersion=$(heroku buildpacks:versions "$BP_NAME" | awk 'FNR == 3 { print $1 }')
newVersion="v$((curVersion + 1))"

read -rp "Deploy as version: $newVersion [y/n]? " choice
case "$choice" in
y | Y) echo "" ;;
n | N) exit 0 ;;
*) exit 1 ;;
esac

originMain=$(git rev-parse origin/main)
echo "Tagging commit $originMain with $newVersion... "
git tag $newVersion "${originMain:?}"
git push origin refs/tags/$newVersion

heroku buildpacks:publish "$BP_NAME" $newVersion

echo "Updating previous-version tag"
git tag -d previous-version
git push origin :previous-version
git tag previous-version latest-version
echo "Updating latest-version tag"
git tag -d latest-version
git push origin :latest-version
git tag latest-version "${originMain:?}"
git push --tags

echo "Done."
