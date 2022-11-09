Heroku buildpack for Java [![CI](https://github.com/heroku/heroku-buildpack-java/actions/workflows/ci.yml/badge.svg)](https://github.com/heroku/heroku-buildpack-java/actions/workflows/ci.yml)
=========================

![java](https://cloud.githubusercontent.com/assets/871315/20325947/f3544014-ab43-11e6-9c51-8240ce161939.png)

This is the official [Heroku buildpack](http://devcenter.heroku.com/articles/buildpack) for Java apps.
It uses Maven 3.6.2 to build your application and OpenJDK 8 to run it. However, the JDK version can be configured as described below.

## How it works

The buildpack will detect your app as Java if it has a `pom.xml` file, or one of the other POM formats supports by the [Maven Polyglot](https://github.com/takari/polyglot-maven) plugin, in its root directory.  It will use Maven to execute the build defined by your `pom.xml` and download your dependencies. The `.m2` folder (local maven repository) will be cached between builds for faster dependency resolution. However neither the `mvn` executable nor the `.m2` folder will be available in your slug at runtime.

## Documentation

For more information about using Java and buildpacks on Heroku, see these Dev Center articles:

*  [Heroku Java Support](https://devcenter.heroku.com/articles/java-support)
*  [Introduction to Heroku for Java Developers](https://devcenter.heroku.com/articles/intro-for-java-developers)
*  [Deploying Tomcat-based Java Web Applications with Webapp Runner](https://devcenter.heroku.com/articles/java-webapp-runner)
*  [Deploy a Java Web Application that launches with Jetty Runner](https://devcenter.heroku.com/articles/deploy-a-java-web-application-that-launches-with-jetty-runner)
*  [Using a Custom Maven Settings File](https://devcenter.heroku.com/articles/using-a-custom-maven-settings-xml)
*  [Using Grunt with Java and Maven to Automate JavaScript Tasks](https://devcenter.heroku.com/articles/using-grunt-with-java-and-maven-to-automate-javascript-tasks)

## Examples

* [Tomcat Webapp-Runner Example](https://github.com/kissaten/webapp-runner-minimal)
* [Spring Boot Example](https://github.com/kissaten/spring-boot-heroku-demo)

## Configuration

### Choose a JDK

Create a `system.properties` file in the root of your project directory and set `java.runtime.version=1.8`.

Example:

    $ ls
    Procfile pom.xml src

    $ echo "java.runtime.version=1.8" > system.properties

    $ git add system.properties && git commit -m "Java 8"

    $ git push heroku main
    ...
    -----> Java app detected
    -----> Installing OpenJDK 1.8... done
    -----> Installing Maven 3.3.3... done
    ...

### Choose a Maven Version

You can define a specific version of Maven for Heroku to use by adding the
[Maven Wrapper](https://github.com/takari/maven-wrapper) to your project. When
this buildpack detects the presence of a `mvnw` script and a `.mvn` directory,
it will run the Maven Wrapper instead of the default `mvn` command.

If you need to override this, the `system.properties` file also allows for a `maven.version` entry
(regardless of whether you specify a `java.runtime.version` entry). For example:

```
java.runtime.version=1.8
maven.version=3.3.9
```

### Customize Maven

There are three config variables that can be used to customize the Maven execution:

+ `MAVEN_CUSTOM_GOALS`: set to `clean dependency:list install` by default
+ `MAVEN_CUSTOM_OPTS`: set to `-DskipTests` by default
+ `MAVEN_JAVA_OPTS`: set to `-Xmx1024m` by default

These variables can be set like this:

```sh-session
$ heroku config:set MAVEN_CUSTOM_GOALS="clean package"
$ heroku config:set MAVEN_CUSTOM_OPTS="--update-snapshots -DskipTests=true"
$ heroku config:set MAVEN_JAVA_OPTS="-Xss2g"
```

Other options are available for [defining a custom `settings.xml` file](https://devcenter.heroku.com/articles/using-a-custom-maven-settings-xml).

## Development

To make changes to this buildpack, fork it on Github. Push up changes to your fork, then create a new Heroku app to test it, or configure an existing app to use your buildpack:

```
# Create a new Heroku app that uses your buildpack
heroku create --buildpack <your-github-url>

# Configure an existing Heroku app to use your buildpack
heroku buildpacks:set <your-github-url>

# You can also use a git branch!
heroku buildpacks:set <your-github-url>#your-branch
```

For example if you want to have Maven available to use at runtime in your application, you can copy it from the cache directory to the build directory by adding the following lines to the compile script:

    for DIR in ".m2" ".maven" ; do
      cp -r $CACHE_DIR/$DIR $BUILD_DIR/$DIR
    done

This will copy the local Maven repo and Maven binaries into your slug.

Commit and push the changes to your buildpack to your GitHub fork, then push your sample app to Heroku to test. Once the push succeeds you should be able to run:

    $ heroku run bash

and then:

    $ ls -al

and you'll see the `.m2` and `.maven` directories are now present in your slug.

License
-------

Licensed under the MIT License. See LICENSE file.
