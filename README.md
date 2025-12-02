![java](https://cloud.githubusercontent.com/assets/871315/20325947/f3544014-ab43-11e6-9c51-8240ce161939.png)

# Heroku Buildpack: Java (Maven) [![CI](https://github.com/heroku/heroku-buildpack-java/actions/workflows/ci.yml/badge.svg)](https://github.com/heroku/heroku-buildpack-java/actions/workflows/ci.yml)

This is the official [Heroku buildpack](https://devcenter.heroku.com/articles/buildpacks) for apps that use [Maven](https://maven.apache.org/) as their build tool. It's primarily used to build [Java](https://www.java.com/) applications, but it can also build applications written in other JVM languages.

If you're using a different JVM build tool, use the appropriate buildpack:
* [Gradle buildpack](https://github.com/heroku/heroku-buildpack-gradle) for [Gradle](https://gradle.org/) projects
* [Scala buildpack](https://github.com/heroku/heroku-buildpack-scala) for [sbt](https://www.scala-sbt.org/) projects
* [Clojure buildpack](https://github.com/heroku/heroku-buildpack-clojure) for [Leiningen](https://leiningen.org/) projects

## Table of Contents

- [Supported Maven Versions](#supported-maven-versions)
- [Getting Started](#getting-started)
- [Application Requirements](#application-requirements)
- [Configuration](#configuration)
  - [OpenJDK Version](#openjdk-version)
  - [Maven Version](#maven-version)
  - [Buildpack Configuration](#buildpack-configuration)
- [Documentation](#documentation)

## Supported Maven Versions

This buildpack officially supports Maven `3.x`. Maven `4.x` support will be added after its release.

## Getting Started

See the [Getting Started with Java on Heroku](https://devcenter.heroku.com/articles/getting-started-with-java) tutorial.

## Application Requirements

Your app requires a `pom.xml` file, or one of the other POM formats supported by the [Maven Polyglot](https://github.com/takari/polyglot-maven) plugin, in the root directory.

## Configuration

### OpenJDK Version

Specify an OpenJDK version by creating a `system.properties` file in the root of your project directory and setting the `java.runtime.version` property. See the [Java Support article](https://devcenter.heroku.com/articles/java-support#supported-java-versions) for available versions and configuration instructions.

### Maven Version

Specify a Maven version by adding the [Maven Wrapper](https://maven.apache.org/tools/wrapper/) to your project. When this buildpack detects the presence of a `mvnw` script and a `.mvn` directory, it will run the Maven Wrapper instead of the default `mvn` command.

Alternatively, you can set the `maven.version` property in `system.properties`, though using the Maven Wrapper is the recommended approach.

### Buildpack Configuration

Configure the buildpack by setting environment variables:

| Environment Variable | Description | Default |
|---------------------|-------------|---------|
| `MAVEN_CUSTOM_GOALS` | Maven goals to execute | `clean dependency:list install` |
| `MAVEN_CUSTOM_OPTS` | Maven command-line options | `-DskipTests` |
| `MAVEN_JAVA_OPTS` | JVM options for Maven execution | (none) |
| `MAVEN_SETTINGS_PATH` | Path to a custom `settings.xml` file | (none) |
| `MAVEN_SETTINGS_URL` | URL from which to download a custom `settings.xml` file | (none) |
| `MAVEN_HEROKU_CI_GOAL` | Maven goal for Heroku CI test runs | `test` |

For more information about using a custom Maven `settings.xml` file, see [Using a Custom Maven Settings File](https://devcenter.heroku.com/articles/using-a-custom-maven-settings-xml).

## Documentation

For more information about using Java on Heroku, see the [Java Support](https://devcenter.heroku.com/categories/java-support) documentation on Dev Center.
