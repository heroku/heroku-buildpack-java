Java buildpack
==============

This is a [buildpack](https://www.cloudcontrol.com/dev-center/Platform%20Documentation#buildpacks-and-the-procfile) for Java apps.
It uses Maven to build your application and OpenJDK to run it.

Usage
-----

This is our default buildpack for Java applications. In case you want to introduce some changes, fork our buildpack, apply changes and test it via [custom buildpack feature](https://www.cloudcontrol.com/dev-center/Guides/Third-Party%20Buildpacks/Third-Party%20Buildpacks):

~~~bash
    $ cctrlapp APP_NAME create custom --buildpack https://github.com/cloudControl/buildpack-java.git
~~~

The buildpack will detect your app as Java if it has the file `pom.xml` in the root. It will use Maven to execute the build defined by your pom.xml and download your dependencies. The .m2 folder (local maven repository) will be cached between builds for faster dependency resolution. However neither the mvn executable or the .m2 folder will be available in your slug at runtime.

Choose a JDK
--------------
Create a `system.properties` file in the root of your project directory and set `java.runtime.version=1.7`.

Example:
~~~bash
    $ echo "java.runtime.version=1.7" > system.properties
~~~


Run the Tests
-------------
* Install the buildpack testrunner:
	https://github.com/cloudControl/heroku-buildpack-testrunner

* Run
~~~bash
	$ export DOMAIN=devcctrl.com PAAS_VENDOR=cloudControl
	$ {PATH_TO_YOUR_BUILDPACK_TESTRUNNER}/bin/run .
~~~


License
-------

Licensed under the MIT License. See LICENSE file.
