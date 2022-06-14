# Java Buildpack Changelog

## main

## v72

* Adjust curl retry and connection timeout handling
* Vendor buildpack-stdlib rather than downloading it at build time
* Switch to the recommended regional S3 domain instead of the global one

## v71

+ Add heroku-22 support

## v70

+ Remove heroku-16 support
+ Remove Cloud Native Buildpack support. Development of Heroku JVM Cloud Native Buildpacks now takes place in a dedicated repository: https://github.com/heroku/buildpacks-jvm

## v69

+ Upgrade CNB API compatibility version to 0.4

## v68

+ Enable heroku-20 testing

## v67

+ Update tests

## v66

+ Add support for Cloud Native Buildpacks API
+ Add support for Maven wrapper without binary JAR by removing check for .mvn/wrapper/maven-wrapper.jar

## v65

+ Upgrade default Maven version to 3.6.2

## 64

+ Add support for Maven 3.5 and 3.6
+ Cache system.properties file

## 63

+ Add support for MAVEN_HEROKU_CI_GOAL

## 62

+ Improved error behavior for MAVEN_SETTINGS_URL
+ Changed location of JVM common buildpack

## v59

+ Add support for settings.xml in bin/test

## v58

+ Added mcount of kotlin and groovy files in the repo
+ PR #92: Fix some Bash issues

## v57

+ Added measurement of build time with and without cache

## v55

+ Added message when pom.xml is not found

## v42

+ Use latest version of Maven by default

## v41

+ Upgrade to Maven 3.3.9
+ Add retry option to curl commands

## v40

+ Added dependency:list to maven commands

## v39

Upgrade JDK and Maven

+ Upgrade default Maven to 3.3.3
+ Upgrade default JDK to 8u51

## v38

Added a new config var for customizing Maven options

+ Added MAVEN_JAVA_OPTS variable
