# Java Buildpack Changelog

## master

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
