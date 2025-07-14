# Changelog

## [Unreleased]


## [v76] - 2025-07-14

* Remove heroku-20 support ([#245](https://github.com/heroku/heroku-buildpack-java/pull/245))
* Buildpack output slightly changed. If you match against the buildpack output, verify your matching still works and adjust if necessary. ([#249](https://github.com/heroku/heroku-buildpack-java/pull/249))

## [v75] - 2025-02-24

* Internal changes only

## [v74] - 2024-10-04

* Add default process type for Micronaut and Quarkus. ([#224](https://github.com/heroku/heroku-buildpack-java/pull/224))

## [v73] - 2023-08-14

* Remove heroku-18 support ([#204](https://github.com/heroku/heroku-buildpack-java/pull/204))
* Upgrade default Maven version to `3.9.4`. ([#207](https://github.com/heroku/heroku-buildpack-java/pull/207))

## [v72] - 2022-06-14

* Adjust curl retry and connection timeout handling
* Vendor buildpack-stdlib rather than downloading it at build time
* Switch to the recommended regional S3 domain instead of the global one

## [v71] - 2022-06-07

* Add heroku-22 support

## [v70] - 2022-05-18

* Remove heroku-16 support
* Remove Cloud Native Buildpack support. Development of Heroku JVM Cloud Native Buildpacks now takes place in a dedicated repository: https://github.com/heroku/buildpacks-jvm

## [v69] - 2021-01-13

* Upgrade CNB API compatibility version to 0.4

## [v68] - 2020-11-17

* Enable heroku-20 testing

## [v67] - 2020-10-12

* Update tests

## [v66] - 2019-12-17

* Add support for Cloud Native Buildpacks API
* Add support for Maven wrapper without binary JAR by removing check for .mvn/wrapper/maven-wrapper.jar

## [v65] - 2019-10-14

* Upgrade default Maven version to 3.6.2

## 64

* Add support for Maven 3.5 and 3.6
* Cache system.properties file

## 63

* Add support for MAVEN_HEROKU_CI_GOAL

## 62

* Improved error behavior for MAVEN_SETTINGS_URL
* Changed location of JVM common buildpack

## v59

* Add support for settings.xml in bin/test

## v58

* Added mcount of kotlin and groovy files in the repo
* PR #92: Fix some Bash issues

## v57

* Added measurement of build time with and without cache

## v55

* Added message when pom.xml is not found

## v42

* Use latest version of Maven by default

## v41

* Upgrade to Maven 3.3.9
* Add retry option to curl commands

## v40

* Added dependency:list to maven commands

## v39

* Upgrade default Maven to 3.3.3
* Upgrade default JDK to 8u51

## v38

* Added a new config var for customizing Maven options: `MAVEN_JAVA_OPTS`

[unreleased]: https://github.com/heroku/heroku-buildpack-java/compare/v76...main
[v76]: https://github.com/heroku/heroku-buildpack-java/compare/v75...v76
[v75]: https://github.com/heroku/heroku-buildpack-java/compare/v74...v75
[v74]: https://github.com/heroku/heroku-buildpack-java/compare/v73...v74
[v73]: https://github.com/heroku/heroku-buildpack-java/compare/v72...v73
[v72]: https://github.com/heroku/heroku-buildpack-java/compare/v71...v72
[v71]: https://github.com/heroku/heroku-buildpack-java/compare/v70...v71
[v70]: https://github.com/heroku/heroku-buildpack-java/compare/v69...v70
[v69]: https://github.com/heroku/heroku-buildpack-java/compare/v68...v69
[v68]: https://github.com/heroku/heroku-buildpack-java/compare/v67...v68
[v67]: https://github.com/heroku/heroku-buildpack-java/compare/v66...v67
[v66]: https://github.com/heroku/heroku-buildpack-java/compare/v65...v66
[v65]: https://github.com/heroku/heroku-buildpack-java/compare/v64...v65
