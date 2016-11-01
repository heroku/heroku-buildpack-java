if [[ "$TEST_CMD" =~ "mvn verify" ]] && [ "$TRAVIS_PULL_REQUEST" = "false" ]; then
  # create netrc
  cat >> $HOME/.netrc <<EOF
machine git.heroku.com
  login buildpack@example.com
  password $HEROKU_API_KEY
EOF

  curl --fail --retry 3 --retry-delay 1 --connect-timeout 3 --max-time 30 https://toolbelt.heroku.com/install-ubuntu.sh | sh

  yes | heroku keys:add
fi
