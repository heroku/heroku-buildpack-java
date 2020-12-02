require_relative "spec_helper"

DEFAULT_MAVEN_VERSION = "3.6.2"
PREVIOUS_MAVEN_VERSION = "3.5.4"
UNKNOWN_MAVEN_VERSION = "1.0.0-unknown-version"
SIMPLE_HTTP_SERVICE_MAVEN_WRAPPER_VERSION = "3.6.3"

describe "Heroku's Maven Cloud Native Buildpack" do

  context "for an app with Maven wrapper" do
    it "will use Maven wrapper to build the app" do
      rapier.app_dir_from_fixture("simple-http-service") do |app_dir|
        rapier.pack_build(app_dir) do |pack_result|
          expect(pack_result.stdout).to_not include("Installing Maven")
          expect(pack_result.stdout).to include("$ ./mvnw")
          expect(pack_result.stdout).to include("[BUILDPACK INTEGRATION TEST - MAVEN VERSION] #{SIMPLE_HTTP_SERVICE_MAVEN_WRAPPER_VERSION}")
        end
      end
    end

    context "that also has 'maven.version=#{PREVIOUS_MAVEN_VERSION}' in its system.properties file" do
      it "will install and use Maven #{PREVIOUS_MAVEN_VERSION}" do
        rapier.app_dir_from_fixture("simple-http-service") do |app_dir|
          set_maven_version(app_dir, PREVIOUS_MAVEN_VERSION)
          rapier.pack_build(app_dir) do |pack_result|
            expect(pack_result.stdout).to include("[Installing Maven #{PREVIOUS_MAVEN_VERSION}]")
            expect(pack_result.stdout).to_not include("$ ./mvnw")
            expect(pack_result.stdout).to include("[BUILDPACK INTEGRATION TEST - MAVEN VERSION] #{PREVIOUS_MAVEN_VERSION}")
          end
        end
      end
    end

    context "that also has 'maven.version=#{UNKNOWN_MAVEN_VERSION}' in its system.properties file" do
      it "will fail with a descriptive error message" do
        rapier.app_dir_from_fixture("simple-http-service") do |app_dir|
          set_maven_version(app_dir, UNKNOWN_MAVEN_VERSION)
          rapier.pack_build(app_dir, exception_on_failure: false) do |pack_result|
            expect(pack_result.build_success?).to be(false)
            expect(pack_result.stderr).to include("Error, you have defined an unsupported Maven version in the system.properties file.")
            expect(pack_result.stderr).to include("The default supported version is #{DEFAULT_MAVEN_VERSION}")
          end
        end
      end
    end
  end

  context "for an app without Maven wrapper" do
    context "without 'maven.version' in its system.properties file" do
      it "will install Maven #{DEFAULT_MAVEN_VERSION}" do
        rapier.app_dir_from_fixture("simple-http-service") do |app_dir|
          remove_maven_wrapper(app_dir)
          rapier.pack_build(app_dir) do |pack_result|
            expect(pack_result.stdout).to include("[Installing Maven #{DEFAULT_MAVEN_VERSION}]")
            expect(pack_result.stdout).to include("[BUILDPACK INTEGRATION TEST - MAVEN VERSION] #{DEFAULT_MAVEN_VERSION}")
          end
        end
      end
    end

    context "with 'maven.version=#{UNKNOWN_MAVEN_VERSION}' in its system.properties file" do
      it "will fail with a descriptive error message" do
        rapier.app_dir_from_fixture("simple-http-service") do |app_dir|
          remove_maven_wrapper(app_dir)
          set_maven_version(app_dir, UNKNOWN_MAVEN_VERSION)

          rapier.pack_build(app_dir, exception_on_failure: false) do |pack_result|
            expect(pack_result.build_success?).to be(false)
            expect(pack_result.stderr).to include("Error, you have defined an unsupported Maven version in the system.properties file.")
            expect(pack_result.stderr).to include("The default supported version is #{DEFAULT_MAVEN_VERSION}")
          end
        end
      end
    end

    context "with 'maven.version=3.6.2' in its system.properties file" do
      it "will install Maven 3.6.2" do
        rapier.app_dir_from_fixture("simple-http-service") do |app_dir|
          remove_maven_wrapper(app_dir)
          set_maven_version(app_dir, "3.6.2")
          rapier.pack_build(app_dir) do |pack_result|
            expect(pack_result.stdout).to include("[Installing Maven 3.6.2]")
            expect(pack_result.stdout).to include("[BUILDPACK INTEGRATION TEST - MAVEN VERSION] 3.6.2")
          end
        end
      end
    end

    context "with 'maven.version=3.5.4' in its system.properties file" do
      it "will install Maven 3.5.4" do
        rapier.app_dir_from_fixture("simple-http-service") do |app_dir|
          remove_maven_wrapper(app_dir)
          set_maven_version(app_dir, "3.5.4")
          rapier.pack_build(app_dir) do |pack_result|
            expect(pack_result.stdout).to include("[Installing Maven 3.5.4]")
            expect(pack_result.stdout).to include("[BUILDPACK INTEGRATION TEST - MAVEN VERSION] 3.5.4")
          end
        end
      end
    end

    context "with 'maven.version=3.3.9' in its system.properties file" do
      it "will install Maven 3.3.9" do
        rapier.app_dir_from_fixture("simple-http-service") do |app_dir|
          remove_maven_wrapper(app_dir)
          set_maven_version(app_dir, "3.3.9")
          rapier.pack_build(app_dir) do |pack_result|
            expect(pack_result.stdout).to include("[Installing Maven 3.3.9]")
            expect(pack_result.stdout).to include("[BUILDPACK INTEGRATION TEST - MAVEN VERSION] 3.3.9")
          end
        end
      end
    end

    context "with 'maven.version=3.2.5' in its system.properties file" do
      it "will install Maven 3.2.5" do
        rapier.app_dir_from_fixture("simple-http-service") do |app_dir|
          remove_maven_wrapper(app_dir)
          set_maven_version(app_dir, "3.2.5")
          rapier.pack_build(app_dir) do |pack_result|
            expect(pack_result.stdout).to include("[Installing Maven 3.2.5]")
            expect(pack_result.stdout).to include("[BUILDPACK INTEGRATION TEST - MAVEN VERSION] 3.2.5")
          end
        end
      end
    end
  end
end
