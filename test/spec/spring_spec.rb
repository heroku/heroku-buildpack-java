require_relative 'spec_helper'


describe "Heroku's Java buildpack" do
  context "using OpenJDK #{DEFAULT_OPENJDK_VERSION}" do
    it "correctly builds spring-boot-webapp-runner" do
      Hatchet::Runner.new("spring-boot-webapp-runner", stack: ENV["HEROKU_TEST_STACK"]).tap do |app|
        app.before_deploy do
          set_java_version(DEFAULT_OPENJDK_VERSION)
        end

        app.deploy do
          expect(app.output).to include("Installing OpenJDK #{DEFAULT_OPENJDK_VERSION}")
          expect(app.output).to match(%r{Building war: /tmp/.*/target/spring-boot-example-1.0-SNAPSHOT.war})
          expect(app.output).not_to match(%r{Building jar: /tmp/.*/target/spring-boot-example-1.0-SNAPSHOT.jar})
          expect(app.output).not_to include("BUILD FAILURE")

          expect(http_get(app)).to include("Create a New Appointment")
        end
      end
    end

    it "correctly builds spring-boot-executable" do
      Hatchet::Runner.new("spring-boot-executable", stack: ENV["HEROKU_TEST_STACK"]).tap do |app|
        app.before_deploy do
          set_java_version(DEFAULT_OPENJDK_VERSION)
        end

        app.deploy do |app|
          expect(app.output).to include("Installing OpenJDK #{DEFAULT_OPENJDK_VERSION}")
          expect(app.output).not_to include("Installing Maven")
          expect(app.output).not_to match(%r{Building war: /tmp/.*/target/spring-boot-example-1.0-SNAPSHOT.war})
          expect(app.output).to match(%r{Building jar: /tmp/.*/target/spring-boot-example-1.0-SNAPSHOT.jar})
          expect(app.output).not_to include("BUILD FAILURE")

          expect(http_get(app)).to include("Create a New Appointment")
        end
      end
    end

    it "provides a default web process type for spring-boot-executable" do
      Hatchet::Runner.new("spring-boot-executable", stack: ENV["HEROKU_TEST_STACK"]).tap do |app|
        app.before_deploy do
          set_java_version(DEFAULT_OPENJDK_VERSION)
          File.delete("Procfile")
        end

        app.deploy do |app|
          expect(app.output).to include("Installing OpenJDK #{DEFAULT_OPENJDK_VERSION}")
          expect(app.output).not_to match(%r{Building war: /tmp/.*/target/spring-boot-example-1.0-SNAPSHOT.war})
          expect(app.output).to match(%r{Building jar: /tmp/.*/target/spring-boot-example-1.0-SNAPSHOT.jar})
          expect(app.output).not_to include("BUILD FAILURE")
          expect(app.output).to include("Procfile declares types     -> (none)")
          expect(app.output).to include("Default types for buildpack -> web")

          expect(http_get(app)).to include("Create a New Appointment")
        end
      end
    end
  end
end
