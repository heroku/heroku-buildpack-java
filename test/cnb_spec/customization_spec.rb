require_relative "spec_helper"

describe "Heroku's Maven Cloud Native Buildpack" do
  context "with the MAVEN_CUSTOM_GOALS environment variable set" do
    it "will only use goals from MAVEN_CUSTOM_GOALS" do
      rapier.app_dir_from_fixture("simple-http-service") do |app_dir|
        rapier.pack_build(app_dir, build_env: {:MAVEN_CUSTOM_GOALS => "site"}) do |pack_result|
          expect(pack_result.stdout).to include("./mvnw -DskipTests site")
          expect(pack_result.stdout).to include("[INFO] --- maven-site-plugin:3.7.1:site (default-site) @ simple-http-service ---")
        end
      end
    end

    # This is implemented by using the dependency:list goal. We need to ensure it won't be overwritten by
    # the user's choice of goals.
    #it "will still create ${APP_DIR}/target/mvn-dependency-list.log" do
    #  rapier.app_dir_from_fixture("simple-http-service") do |app_dir|
    #    rapier.pack_build(app_dir, build_env: {:MAVEN_CUSTOM_GOALS => "clean"}) do |pack_result|
    #      expect(pack_result.stdout).to include("./mvnw -DskipTests clean")
    #      expect(pack_result.stdout).to include("[INFO] --- maven-clean-plugin:3.1.0:clean (default-clean) @ simple-http-service ---")
    #
    #      pack_result.start_container do |container|
    #
    #        expected_dependency_list = <<~EOF
    #
    #          The following files have been resolved:
    #             io.undertow:undertow-core:jar:2.1.1.Final:compile
    #             org.jboss.logging:jboss-logging:jar:3.4.1.Final:compile
    #             org.jboss.xnio:xnio-api:jar:3.8.0.Final:compile
    #             org.wildfly.common:wildfly-common:jar:1.5.2.Final:compile
    #             org.wildfly.client:wildfly-client-config:jar:1.0.1.Final:compile
    #             org.jboss.xnio:xnio-nio:jar:3.8.0.Final:runtime
    #             org.jboss.threads:jboss-threads:jar:3.1.0.Final:compile
    #             com.google.guava:guava:jar:30.0-jre:compile
    #             com.google.guava:failureaccess:jar:1.0.1:compile
    #             com.google.guava:listenablefuture:jar:9999.0-empty-to-avoid-conflict-with-guava:compile
    #             com.google.code.findbugs:jsr305:jar:3.0.2:compile
    #             org.checkerframework:checker-qual:jar:3.5.0:compile
    #             com.google.errorprone:error_prone_annotations:jar:2.3.4:compile
    #             com.google.j2objc:j2objc-annotations:jar:1.3:compile
    #             junit:junit:jar:4.13.1:test
    #             org.hamcrest:hamcrest-core:jar:1.3:test
    #
    #        EOF
    #
    #        expect(container.get_file_contents("/app/target/mvn-dependency-list.log")).to eq(expected_dependency_list)
    #      end
    #    end
    #  end
    #end
  end

  #context "with the MAVEN_CUSTOM_OPTS environment variable set" do
  #  it "will only use options from MAVEN_CUSTOM_OPTS" do
  #    rapier.app_dir_from_fixture("simple-http-service") do |app_dir|
  #      rapier.pack_build(app_dir, build_env: {:MAVEN_CUSTOM_OPTS => "-X"}) do |pack_result|
  #        expect(pack_result.stdout).to include("./mvnw -X clean install")
  #        expect(pack_result.stdout).to include("[DEBUG] -- end configuration --")
  #
  #        # -DskipTests is part of the default Maven options. We expect it to be overridden by MAVEN_CUSTOM_OPTS and
  #        # therefore expect Maven to run tests.
  #        expect(pack_result.stdout).to include("[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0")
  #      end
  #    end
  #  end
  #end
end
