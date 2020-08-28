require_relative 'spec_helper'

describe "Heroku's Java Buildpack" do
  context "for an app without a system.properties file" do
    it "should install OpenJDK #{DEFAULT_OPENJDK_VERSION} and use Maven #{DEFAULT_MAVEN_VERSION}" do
      Hatchet::Runner.new("test/spec_new/fixtures/repos/simple-maven-app", stack: ENV["HEROKU_TEST_STACK"]).tap do |app|
        app.deploy do
          expect_maven_version(DEFAULT_MAVEN_VERSION, app)
          expect_openjdk_version(DEFAULT_OPENJDK_VERSION, "1.8.0_262-heroku-b10", app)

          expect_maven_build_success(app)
          expect_http_ok(app)
        end
      end
    end
  end


  OPENJDK_VERSIONS_UNDER_TEST.each do |version|
    context "for an app with only 'java.runtime.version=#{version}' in the system.properties file" do
      it "should install OpenJDK #{version} and use Maven #{DEFAULT_MAVEN_VERSION}" do
        Hatchet::Runner.new("test/spec_new/fixtures/repos/simple-maven-app", stack: ENV["HEROKU_TEST_STACK"]).tap do |app|

          app.before_deploy do
            set_java_runtime_version(version)
          end

          app.deploy do
            expect_maven_version(DEFAULT_MAVEN_VERSION, app)
            expect_openjdk_version(version, OPENJDK_VERSIONS[version], app)

            expect_maven_build_success(app)
            expect_http_ok(app)
          end
        end
      end

      it "should not crash when using OpenJDK functionality that depends on libpng" do
        Hatchet::Runner.new("test/spec_new/fixtures/repos/libpng-test", stack: ENV["HEROKU_TEST_STACK"]).tap do |app|

          app.before_deploy do
            set_java_runtime_version(version)
          end

          app.deploy do
            expect_openjdk_version(version, OPENJDK_VERSIONS[version], app)
            expect_maven_build_success(app)
            expect_http_ok(app)
          end
        end
      end
    end

    MAVEN_VERSIONS_UNDER_TEST.each do |maven_version|
      context "for an app with 'java.runtime.version=#{version}' and 'maven.version=#{maven_version}' in the system.properties file" do
        it "should install OpenJDK #{version} and use Maven #{maven_version}" do
          Hatchet::Runner.new("test/spec_new/fixtures/repos/simple-maven-app", stack: ENV["HEROKU_TEST_STACK"]).tap do |app|

            app.before_deploy do
              set_java_runtime_version(version)
              set_maven_version(maven_version)
            end

            app.deploy do
              expect_maven_version(maven_version, app)
              expect_openjdk_version(version, OPENJDK_VERSIONS[version], app)

              expect_maven_build_success(app)
              expect_http_ok(app)
            end
          end
        end
      end
    end
  end
end
