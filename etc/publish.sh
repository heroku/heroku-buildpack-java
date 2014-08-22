#!/bin/sh

if [ ! -z "$1" ]; then
  pushd . > /dev/null 2>&1
  cd /tmp &&
  git clone git@github.com:heroku/heroku-buildpack-java.git &&
  cd heroku-buildpack-java &&
  git checkout master &&
  find . -not -name 'bin' -maxdepth 1 -delete &&
  heroku buildpacks:publish $1/java
  popd > /dev/null 2>&1
  echo "Cleaning up..."
  rm -rf /tmp/heroku-buildpack-java
  echo "Done."
else
  echo "You must provide a buildkit organization as an argument!"
  exit 1
fi
