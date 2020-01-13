unit:
	@echo "Running unit tests in docker (heroku-18)..."
	@docker run -v $(shell pwd):/buildpack:ro --rm -it -e "CNB_STACK_ID=heroku-18" -e "BUILDPACK_HOME=/buildpack" heroku/heroku:18 bash -c 'cp -r /buildpack /buildpack_test; cd /buildpack_test/; test/unit;'
	@echo ""

v3:
	@echo "Running v3 integration tests in docker (heroku-18)..."
	@docker run -v $(shell pwd):/buildpack:ro --rm -it -e "CNB_STACK_ID=heroku-18" -e "BUILDPACK_HOME=/buildpack" heroku/heroku:18 bash -c 'cp -r /buildpack /buildpack_test; cd /buildpack_test/; test/v3;'
	@echo ""

heroku-18: unit v3

heroku-16:
	@echo "Running tests in docker (heroku-16)..."
	@docker run -v $(shell pwd):/buildpack:ro --rm -it -e "CNB_STACK_ID=heroku-16" -e "BUILDPACK_HOME=/buildpack" heroku/heroku:16 bash -c 'cp -r /buildpack /buildpack_test; cd /buildpack_test/; test/unit;'
	@echo ""
	@docker run -v $(shell pwd):/buildpack:ro --rm -it -e "STACK=heroku-16" -e "BUILDPACK_HOME=/buildpack" heroku/heroku:16 bash -c 'cp -r /buildpack /buildpack_test; cd /buildpack_test/; test/v3;'
	@echo ""

cedar-14:
	@echo "Running tests in docker (cedar-14)..."
	@docker run -v $(shell pwd):/buildpack:ro --rm -it -e "CNB_STACK_ID=cedar-14" -e "BUILDPACK_HOME=/buildpack" heroku/cedar:14 bash -c 'cp -r /buildpack /buildpack_test; cd /buildpack_test/; test/unit;'
	@echo ""
	@docker run -v $(shell pwd):/buildpack:ro --rm -it -e "STACK=cedar-14" -e "BUILDPACK_HOME=/buildpack" heroku/cedar:14 bash -c 'cp -r /buildpack /buildpack_test; cd /buildpack_test/; test/v;'
	@echo ""

package:
	@tar czvf heroku-buildpack-maven.tgz bin/ buildpack.toml etc/ lib/ vendor/ README.md LICENSE