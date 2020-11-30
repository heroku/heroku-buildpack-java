require_relative "spec_helper"

describe "Heroku's Maven Cloud Native Buildpack" do
  it "will write ${APP_DIR}/target/mvn-dependency-list.log with the app's dependencies" do
    rapier.app_dir_from_fixture("simple-http-service") do |app_dir|
      rapier.pack_build(app_dir) do |pack_result|
        pack_result.start_container do |container|
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

          expect(container.get_file_contents("/app/target/mvn-dependency-list.log")).to eq(expected_dependency_list)
        end
      end
    end
  end

  it "will not leave unexpected files in ${APP_DIR}" do
    rapier.app_dir_from_fixture("simple-http-service") do |app_dir|
      rapier.pack_build(app_dir) do |pack_result|
        pack_result.start_container do |container|

          expected_output = <<~EOF
            /workspace/.mvn/wrapper/MavenWrapperDownloader.java
            /workspace/.mvn/wrapper/maven-wrapper.jar
            /workspace/.mvn/wrapper/maven-wrapper.properties
            /workspace/Procfile
            /workspace/mvnw
            /workspace/mvnw.cmd
            /workspace/pom.xml
            /workspace/src/main/java/com/heroku/App.java
            /workspace/src/test/java/com/heroku/AppTest.java
            /workspace/target/classes/com/heroku/App$1.class
            /workspace/target/classes/com/heroku/App.class
            /workspace/target/dependency/checker-qual-3.5.0.jar
            /workspace/target/dependency/error_prone_annotations-2.3.4.jar
            /workspace/target/dependency/failureaccess-1.0.1.jar
            /workspace/target/dependency/guava-30.0-jre.jar
            /workspace/target/dependency/hamcrest-core-1.3.jar
            /workspace/target/dependency/j2objc-annotations-1.3.jar
            /workspace/target/dependency/jboss-logging-3.4.1.Final.jar
            /workspace/target/dependency/jboss-threads-3.1.0.Final.jar
            /workspace/target/dependency/jsr305-3.0.2.jar
            /workspace/target/dependency/junit-4.13.1.jar
            /workspace/target/dependency/listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar
            /workspace/target/dependency/undertow-core-2.1.1.Final.jar
            /workspace/target/dependency/wildfly-client-config-1.0.1.Final.jar
            /workspace/target/dependency/wildfly-common-1.5.2.Final.jar
            /workspace/target/dependency/xnio-api-3.8.0.Final.jar
            /workspace/target/dependency/xnio-nio-3.8.0.Final.jar
            /workspace/target/maven-archiver/pom.properties
            /workspace/target/maven-status/maven-compiler-plugin/compile/default-compile/createdFiles.lst
            /workspace/target/maven-status/maven-compiler-plugin/compile/default-compile/inputFiles.lst
            /workspace/target/maven-status/maven-compiler-plugin/testCompile/default-testCompile/createdFiles.lst
            /workspace/target/maven-status/maven-compiler-plugin/testCompile/default-testCompile/inputFiles.lst
            /workspace/target/mvn-dependency-list.log
            /workspace/target/simple-http-service-1.0-SNAPSHOT.jar
            /workspace/target/test-classes/com/heroku/AppTest.class
          EOF

          expect(container.bash_exec("find /workspace -type f | sort -s").stdout).to eq(expected_output)
        end
      end
    end
  end

  #it "will not log internal Maven options and goals" do
  #  rapier.app_dir_from_fixture("simple-http-service") do |app_dir|
  #    rapier.pack_build(app_dir) do |pack_result|
  #      expect(pack_result.stdout).to_not include("-Dmaven.repo.local=")
  #      expect(pack_result.stdout).to_not include("-Duser.home=")
  #      expect(pack_result.stdout).to_not include("dependency:list")
  #      expect(pack_result.stdout).to_not include("-DoutputFile=target/mvn-dependency-list.log")
  #    end
  #  end
  #end

  it "will cache dependencies between builds" do
    rapier.app_dir_from_fixture("simple-http-service") do |app_dir|
      rapier.pack_build(app_dir) do |first_pack_result|
        rapier.pack_build(app_dir, image_name: first_pack_result.image_name) do |second_pack_result|
          expect(first_pack_result.stdout).to include("Downloading from central")
          expect(second_pack_result.stdout).to_not include("Downloading from central")
        end
      end
    end
  end

  context "with an app that does not compile" do
    it "will exit with a descriptive error message" do
      rapier.app_dir_from_fixture("app-with-compile-error") do |app_dir|
        rapier.pack_build(app_dir, exception_on_failure: false) do |pack_result|
          expect(pack_result.build_success?).to be(false)
          expect(pack_result.stdout).to include("[INFO] BUILD FAILURE")

          expect(pack_result.stderr).to include("Failed to build app with Maven")
          expect(pack_result.stderr).to include("We're sorry this build is failing! If you can't find the issue in application code,")
          expect(pack_result.stderr).to include("please submit a ticket so we can help: https://help.heroku.com/")
        end
      end
    end
  end
end
