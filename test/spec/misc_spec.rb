require_relative "spec_helper"

describe "Heroku's Java Buildpack" do
  it "will write ${APP_DIR}/target/mvn-dependency-list.log with the app's dependencies" do
    new_default_hatchet_runner("test/fixtures/simple-http-service").tap do |app|
      app.deploy do |app|
        expected_dependency_list = <<~EOF

            The following files have been resolved:
               io.undertow:undertow-core:jar:2.1.1.Final:compile
               org.jboss.logging:jboss-logging:jar:3.4.1.Final:compile
               org.jboss.xnio:xnio-api:jar:3.8.0.Final:compile
               org.wildfly.common:wildfly-common:jar:1.5.2.Final:compile
               org.wildfly.client:wildfly-client-config:jar:1.0.1.Final:compile
               org.jboss.xnio:xnio-nio:jar:3.8.0.Final:runtime
               org.jboss.threads:jboss-threads:jar:3.1.0.Final:compile
               com.google.guava:guava:jar:30.0-jre:compile
               com.google.guava:failureaccess:jar:1.0.1:compile
               com.google.guava:listenablefuture:jar:9999.0-empty-to-avoid-conflict-with-guava:compile
               com.google.code.findbugs:jsr305:jar:3.0.2:compile
               org.checkerframework:checker-qual:jar:3.5.0:compile
               com.google.errorprone:error_prone_annotations:jar:2.3.4:compile
               com.google.j2objc:j2objc-annotations:jar:1.3:compile
               junit:junit:jar:4.13.1:test
               org.hamcrest:hamcrest-core:jar:1.3:test

        EOF

        # On CircleCI, there are sometimes unexpected newlines and/or null-bytes before and/or after the expected
        # output. Stripping both strings and removing ^@^@ works around the issue.
        expect(app.run("cat target/mvn-dependency-list.log").strip).to eq(expected_dependency_list.strip)
      end
    end
  end

  it "will not leave unexpected files in ${APP_DIR}" do
    new_default_hatchet_runner("test/fixtures/simple-http-service").tap do |app|
      app.deploy do |app|
        expected_output = <<~EOF
          ./.heroku/bin/heroku-metrics-agent.jar
          ./.heroku/bin/with_jmap
          ./.heroku/bin/with_jmap_and_jstack
          ./.heroku/bin/with_jstack
          ./.heroku/with_jmap/bin/java
          ./.heroku/with_jmap_and_jstack/bin/java
          ./.heroku/with_jstack/bin/java
          ./.mvn/wrapper/MavenWrapperDownloader.java
          ./.mvn/wrapper/maven-wrapper.jar
          ./.mvn/wrapper/maven-wrapper.properties
          ./.profile.d/default-proc-warning.sh
          ./.profile.d/heroku-jvm-metrics.sh
          ./.profile.d/jdbc.sh
          ./.profile.d/jvm-redis.sh
          ./.profile.d/jvmcommon.sh
          ./Procfile
          ./mvnw
          ./mvnw.cmd
          ./pom.xml
          ./src/main/java/com/heroku/App.java
          ./src/test/java/com/heroku/AppTest.java
          ./target/classes/com/heroku/App$1.class
          ./target/classes/com/heroku/App.class
          ./target/dependency/checker-qual-3.5.0.jar
          ./target/dependency/error_prone_annotations-2.3.4.jar
          ./target/dependency/failureaccess-1.0.1.jar
          ./target/dependency/guava-30.0-jre.jar
          ./target/dependency/hamcrest-core-1.3.jar
          ./target/dependency/j2objc-annotations-1.3.jar
          ./target/dependency/jboss-logging-3.4.1.Final.jar
          ./target/dependency/jboss-threads-3.1.0.Final.jar
          ./target/dependency/jsr305-3.0.2.jar
          ./target/dependency/junit-4.13.1.jar
          ./target/dependency/listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar
          ./target/dependency/undertow-core-2.1.1.Final.jar
          ./target/dependency/wildfly-client-config-1.0.1.Final.jar
          ./target/dependency/wildfly-common-1.5.2.Final.jar
          ./target/dependency/xnio-api-3.8.0.Final.jar
          ./target/dependency/xnio-nio-3.8.0.Final.jar
          ./target/maven-archiver/pom.properties
          ./target/maven-status/maven-compiler-plugin/compile/default-compile/createdFiles.lst
          ./target/maven-status/maven-compiler-plugin/compile/default-compile/inputFiles.lst
          ./target/maven-status/maven-compiler-plugin/testCompile/default-testCompile/createdFiles.lst
          ./target/maven-status/maven-compiler-plugin/testCompile/default-testCompile/inputFiles.lst
          ./target/mvn-dependency-list.log
          ./target/simple-http-service-1.0-SNAPSHOT.jar
          ./target/test-classes/com/heroku/AppTest.class
        EOF

        # On CircleCI, there are sometimes unexpected newlines and/or null-bytes before and/or after the expected
        # output. Stripping both strings and removing ^@^@ works around the issue.
        expect(app.run("find . -type f | grep -v './.jdk/' | sort -s").strip).to eq(expected_output.strip)
      end
    end
  end

  #it "will not log internal Maven options and goals" do
  #  new_default_hatchet_runner("test/fixtures/simple-http-service").tap do |app|
  #    app.deploy do |app|
  #      expect(app.output).to_not include("-Dmaven.repo.local=")
  #      expect(app.output).to_not include("-Duser.home=")
  #      expect(app.output).to_not include("dependency:list")
  #      expect(app.output).to_not include("-DoutputFile=target/mvn-dependency-list.log")
  #    end
  #  end
  #end

  it "will cache dependencies between builds" do
    new_default_hatchet_runner("test/fixtures/simple-http-service").tap do |app|
      app.deploy do |app|
        expect(app.output).to include("Downloading from central")

        app.commit!
        app.push!

        expect(app.output).to_not include("Downloading from central")
      end
    end
  end

  context "with an app that does not compile" do
    it "will exit with a descriptive error message" do
      new_default_hatchet_runner("test/fixtures/app-with-compile-error", allow_failure: true).tap do |app|
        app.deploy do |app|
          expect(app).not_to be_deployed
          expect(app.output).to include("[INFO] BUILD FAILURE")

          expect(app.output).to include("Failed to build app with Maven")
          expect(app.output).to include("We're sorry this build is failing! If you can't find the issue in application code,")
          expect(app.output).to include("please submit a ticket so we can help: https://help.heroku.com/")
        end
      end
    end
  end
end
