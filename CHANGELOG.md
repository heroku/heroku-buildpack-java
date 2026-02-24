# Changelog

## [Unreleased]


## [v81] - 2026-02-24

* Improve OpenJDK installation via `jvm-common` buildpack to prevent function overrides and fix environment variable handling. ([#275](https://github.com/heroku/heroku-buildpack-java/pull/275))
* Improve detection error message with better user experience and guidance for other build tools. ([#270](https://github.com/heroku/heroku-buildpack-java/pull/270))
* Changed the S3 URLs used for downloads to use AWS' dual-stack (IPv6 compatible) endpoint. ([#284](https://github.com/heroku/heroku-buildpack-java/pull/284))

## [v80] - 2025-09-08

* Change Maven Wrapper validation from build-failing error to warning when properties file is missing. ([#268](https://github.com/heroku/heroku-buildpack-java/pull/268))

## [v79] - 2025-09-04

* Add Maven Wrapper validation with clear error message when required files are missing. ([#266](https://github.com/heroku/heroku-buildpack-java/pull/266))

## [v78] - 2025-09-04

* Fix a buildpack crash when determining Maven version that can occur for some configurations. ([#264](https://github.com/heroku/heroku-buildpack-java/pull/264))

## [v77] - 2025-09-04

* Refactor Maven installation and invocation code. ([#257](https://github.com/heroku/heroku-buildpack-java/pull/257))
* Improve error messages with detailed troubleshooting guidance. ([#257](https://github.com/heroku/heroku-buildpack-java/pull/257))
* Enhance `settings.xml` handling and error reporting. ([#257](https://github.com/heroku/heroku-buildpack-java/pull/257))
* Buildpack output slightly changed. If you match against the buildpack output, verify your matching still works and adjust if necessary. ([#257](https://github.com/heroku/heroku-buildpack-java/pull/257))

## [v76] - 2025-07-14

* Remove `heroku-20` support. ([#245](https://github.com/heroku/heroku-buildpack-java/pull/245))
* Buildpack output slightly changed. If you match against the buildpack output, verify your matching still works and adjust if necessary. ([#249](https://github.com/heroku/heroku-buildpack-java/pull/249))

## [v75] - 2025-02-24

* Internal changes only.

## [v74] - 2024-10-04

* Add default process type for Micronaut and Quarkus. ([#224](https://github.com/heroku/heroku-buildpack-java/pull/224))

## [v73] - 2023-08-14

* Remove `heroku-18` support. ([#204](https://github.com/heroku/heroku-buildpack-java/pull/204))
* Upgrade default Maven version to `3.9.4`. ([#207](https://github.com/heroku/heroku-buildpack-java/pull/207))

## [v72] - 2022-06-14

* Adjust `curl` retry and connection timeout handling.
* Vendor `buildpack-stdlib` rather than downloading it at build time.
* Switch to the recommended regional S3 domain instead of the global one.

## [v71] - 2022-06-07

* Add `heroku-22` support.

## [v70] - 2022-05-18

* Remove `heroku-16` support.
* Remove Cloud Native Buildpack support. Development of Heroku JVM Cloud Native Buildpacks now takes place in a dedicated repository: https://github.com/heroku/buildpacks-jvm.

## [v69] - 2021-01-13

* Upgrade CNB API compatibility version to `0.4`.

## [v68] - 2020-11-17

* Enable `heroku-20` testing.

## [v67] - 2020-10-12

* Update tests.

## [v66] - 2019-12-17

* Add support for Cloud Native Buildpacks API.
* Add support for Maven wrapper without binary JAR by removing check for `.mvn/wrapper/maven-wrapper.jar`.

## [v65] - 2019-10-14

* Upgrade default Maven version to `3.6.2`. ([#118](https://github.com/heroku/heroku-buildpack-java/pull/118))

## [v64] - 2019-09-30

* Add support for Maven `3.5` and `3.6`. ([#115](https://github.com/heroku/heroku-buildpack-java/pull/115))
* Cache `system.properties` file. ([#110](https://github.com/heroku/heroku-buildpack-java/pull/110))

## [v63] - 2019-02-27

* Add support for `MAVEN_HEROKU_CI_GOAL`. ([#107](https://github.com/heroku/heroku-buildpack-java/pull/107))

## [v62] - 2018-06-13

* Improve error behavior for `MAVEN_SETTINGS_URL`. ([#96](https://github.com/heroku/heroku-buildpack-java/pull/96))
* Change location of JVM common buildpack. ([#97](https://github.com/heroku/heroku-buildpack-java/pull/97))

## [v61] - 2018-04-26

* Internal changes only.

## [v60] - 2018-04-13

* Fix Maven profile handling to avoid hardcoding build directory. ([#94](https://github.com/heroku/heroku-buildpack-java/pull/94))
* Fix testpack API to use correct parameters. ([#95](https://github.com/heroku/heroku-buildpack-java/pull/95))

## [v59] - 2018-01-19

* Add support for `settings.xml` in `bin/test`. ([#93](https://github.com/heroku/heroku-buildpack-java/pull/93))

## [v58] - 2018-01-04

* Add measurement of Kotlin and Groovy files in the repository. ([#91](https://github.com/heroku/heroku-buildpack-java/pull/91))
* Fix some Bash issues. ([#92](https://github.com/heroku/heroku-buildpack-java/pull/92))

## [v57] - 2017-10-19

* Add measurement of build time with and without cache. ([#88](https://github.com/heroku/heroku-buildpack-java/pull/88))

## [v56] - 2017-10-10

* Internal changes only.

## [v55] - 2017-09-11

* Add message when `pom.xml` is not found.

## [v42] - 2015-12-15

* Use latest version of Maven by default.

## [v41] - 2015-12-02

* Upgrade to Maven `3.3.9`. ([#62](https://github.com/heroku/heroku-buildpack-java/pull/62))
* Add retry option to `curl` commands. ([#63](https://github.com/heroku/heroku-buildpack-java/pull/63))

## [v40] - 2015-10-12

* Add `dependency:list` to Maven commands.

## [v39] - 2015-08-06

* Upgrade default Maven to `3.3.3`.
* Upgrade default JDK to `8u51`.

## [v38] - 2015-04-20

* Add a new config var for customizing Maven options: `MAVEN_JAVA_OPTS`.

[unreleased]: https://github.com/heroku/heroku-buildpack-java/compare/v81...main
[v81]: https://github.com/heroku/heroku-buildpack-java/compare/v80...v81
[v80]: https://github.com/heroku/heroku-buildpack-java/compare/v79...v80
[v79]: https://github.com/heroku/heroku-buildpack-java/compare/v78...v79
[v78]: https://github.com/heroku/heroku-buildpack-java/compare/v77...v78
[v77]: https://github.com/heroku/heroku-buildpack-java/compare/v76...v77
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
[v64]: https://github.com/heroku/heroku-buildpack-java/compare/v63...v64
[v63]: https://github.com/heroku/heroku-buildpack-java/compare/v62...v63
[v62]: https://github.com/heroku/heroku-buildpack-java/compare/v61...v62
[v61]: https://github.com/heroku/heroku-buildpack-java/compare/v60...v61
[v60]: https://github.com/heroku/heroku-buildpack-java/compare/v59...v60
[v59]: https://github.com/heroku/heroku-buildpack-java/compare/v58...v59
[v58]: https://github.com/heroku/heroku-buildpack-java/compare/v57...v58
[v57]: https://github.com/heroku/heroku-buildpack-java/compare/v56...v57
[v56]: https://github.com/heroku/heroku-buildpack-java/compare/v54...v56
[v55]: https://github.com/heroku/heroku-buildpack-java/compare/v54...v56
[v42]: https://github.com/heroku/heroku-buildpack-java/compare/v41...v42
[v41]: https://github.com/heroku/heroku-buildpack-java/compare/v40...v41
[v40]: https://github.com/heroku/heroku-buildpack-java/compare/v39...v40
[v39]: https://github.com/heroku/heroku-buildpack-java/compare/v38...v39
[v38]: https://github.com/heroku/heroku-buildpack-java/compare/v37...v38
