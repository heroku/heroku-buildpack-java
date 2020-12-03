require_relative "spec_helper"

DEFAULT_MAVEN_VERSION = "3.6.2"
PREVIOUS_MAVEN_VERSION = "3.5.4"
UNKNOWN_MAVEN_VERSION = "1.0.0-unknown-version"
SIMPLE_HTTP_SERVICE_MAVEN_WRAPPER_VERSION = "3.6.3"

describe "Heroku's Java Buildpack" do

  context "for an app with Maven wrapper" do
    it "will use Maven wrapper to build the app" do
      new_default_hatchet_runner("test/fixtures/simple-http-service").tap do |app|
        app.deploy do |app|
          expect(app.output).to_not include("Installing Maven")
          expect(app.output).to include("$ ./mvnw")
          expect(app.output).to include("[BUILDPACK INTEGRATION TEST - MAVEN VERSION] #{SIMPLE_HTTP_SERVICE_MAVEN_WRAPPER_VERSION}")
        end
      end
    end

    context "that also has 'maven.version=#{PREVIOUS_MAVEN_VERSION}' in its system.properties file" do
      it "will install and use Maven #{PREVIOUS_MAVEN_VERSION}" do
        new_default_hatchet_runner("test/fixtures/simple-http-service").tap do |app|
          app.before_deploy do
            set_maven_version(Dir.pwd, PREVIOUS_MAVEN_VERSION)
          end

          app.deploy do |app|
            expect(app.output).to include("Installing Maven #{PREVIOUS_MAVEN_VERSION}... done")
            expect(app.output).to_not include("$ ./mvnw")
            expect(app.output).to include("[BUILDPACK INTEGRATION TEST - MAVEN VERSION] #{PREVIOUS_MAVEN_VERSION}")
          end
        end
      end
    end

    context "that also has 'maven.version=#{UNKNOWN_MAVEN_VERSION}' in its system.properties file" do
      it "will fail with a descriptive error message" do
        new_default_hatchet_runner("test/fixtures/simple-http-service", allow_failure: true).tap do |app|
          app.before_deploy do
            set_maven_version(Dir.pwd, UNKNOWN_MAVEN_VERSION)
          end

          app.deploy do |app|
            expect(app).not_to be_deployed
            expect(app.output).to include("Error, you have defined an unsupported Maven version in the system.properties file.")
            expect(app.output).to include("The default supported version is #{DEFAULT_MAVEN_VERSION}")
          end
        end
      end
    end
  end

  context "for an app without Maven wrapper" do
    context "without 'maven.version' in its system.properties file" do
      it "will install Maven #{DEFAULT_MAVEN_VERSION}" do
        new_default_hatchet_runner("test/fixtures/simple-http-service").tap do |app|
          app.before_deploy do
            remove_maven_wrapper(Dir.pwd)
          end

          app.deploy do |app|
            expect(app.output).to include("Installing Maven #{DEFAULT_MAVEN_VERSION}... done")
            expect(app.output).to include("[BUILDPACK INTEGRATION TEST - MAVEN VERSION] #{DEFAULT_MAVEN_VERSION}")
          end
        end
      end
    end

    context "with 'maven.version=#{UNKNOWN_MAVEN_VERSION}' in its system.properties file" do
      it "will fail with a descriptive error message" do
        new_default_hatchet_runner("test/fixtures/simple-http-service", allow_failure: true).tap do |app|
          app.before_deploy do
            remove_maven_wrapper(Dir.pwd)
            set_maven_version(Dir.pwd, UNKNOWN_MAVEN_VERSION)
          end

          app.deploy do |app|
            expect(app).not_to be_deployed
            expect(app.output).to include("Error, you have defined an unsupported Maven version in the system.properties file.")
            expect(app.output).to include("The default supported version is #{DEFAULT_MAVEN_VERSION}")
          end
        end
      end
    end

    context "with 'maven.version=3.6.2' in its system.properties file" do
      it "will install Maven 3.6.2" do
        new_default_hatchet_runner("test/fixtures/simple-http-service").tap do |app|
          app.before_deploy do
            remove_maven_wrapper(Dir.pwd)
            set_maven_version(Dir.pwd, "3.6.2")
          end

          app.deploy do |app|
            expect(app.output).to include("Installing Maven 3.6.2... done")
            expect(app.output).to include("[BUILDPACK INTEGRATION TEST - MAVEN VERSION] 3.6.2")
          end
        end
      end
    end

    context "with 'maven.version=3.5.4' in its system.properties file" do
      it "will install Maven 3.5.4" do
        new_default_hatchet_runner("test/fixtures/simple-http-service").tap do |app|
          app.before_deploy do
            remove_maven_wrapper(Dir.pwd)
            set_maven_version(Dir.pwd, "3.5.4")
          end

          app.deploy do |app|
            expect(app.output).to include("Installing Maven 3.5.4... done")
            expect(app.output).to include("[BUILDPACK INTEGRATION TEST - MAVEN VERSION] 3.5.4")
          end
        end
      end
    end

    context "with 'maven.version=3.3.9' in its system.properties file" do
      it "will install Maven 3.3.9" do
        new_default_hatchet_runner("test/fixtures/simple-http-service").tap do |app|
          app.before_deploy do
            remove_maven_wrapper(Dir.pwd)
            set_maven_version(Dir.pwd, "3.3.9")
          end

          app.deploy do |app|
            expect(app.output).to include("Installing Maven 3.3.9... done")
            expect(app.output).to include("[BUILDPACK INTEGRATION TEST - MAVEN VERSION] 3.3.9")
          end
        end
      end
    end

    context "with 'maven.version=3.2.5' in its system.properties file" do
      it "will install Maven 3.2.5" do
        new_default_hatchet_runner("test/fixtures/simple-http-service").tap do |app|
          app.before_deploy do
            remove_maven_wrapper(Dir.pwd)
            set_maven_version(Dir.pwd, "3.2.5")
          end

          app.deploy do |app|
            expect(app.output).to include("Installing Maven 3.2.5... done")
            expect(app.output).to include("[BUILDPACK INTEGRATION TEST - MAVEN VERSION] 3.2.5")
          end
        end
      end
    end
  end
end
