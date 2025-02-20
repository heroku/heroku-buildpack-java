# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Maven buildpack' do
  it 'runs Maven wrapper instead of installing Maven when possible' do
    app = Hatchet::Runner.new('simple-http-service')
    app.deploy do
      expect(clean_output(app.output)).to include('$ ./mvnw')
      expect(clean_output(app.output)).to include("[BUILDPACK INTEGRATION TEST - MAVEN VERSION] #{SIMPLE_HTTP_SERVICE_MAVEN_WRAPPER_VERSION}")
    end
  end

  it 'prioritizes installed Maven over wrapper when maven.version property is present' do
    app = Hatchet::Runner.new('simple-http-service')
    app.before_deploy do
      add_to_system_properties('maven.version', DEFAULT_MAVEN_VERSION)
    end

    app.deploy do
      expect(clean_output(app.output)).not_to include('$ ./mvnw')
      expect(clean_output(app.output)).to include("remote: -----> Installing Maven #{DEFAULT_MAVEN_VERSION}... done")
      expect(clean_output(app.output)).to include("[BUILDPACK INTEGRATION TEST - MAVEN VERSION] #{DEFAULT_MAVEN_VERSION}")
    end
  end

  it 'prioritizes installed Maven over wrapper when maven.version property is present, even when the version is unknown' do
    app = Hatchet::Runner.new('simple-http-service', allow_failure: true)
    app.before_deploy do
      add_to_system_properties('maven.version', UNKNOWN_MAVEN_VERSION)
    end

    app.deploy do
      expect(clean_output(app.output)).to include(<<~OUTPUT)
        remote: -----> Installing Maven #{UNKNOWN_MAVEN_VERSION}...
        remote:  !     ERROR: Error, you have defined an unsupported Maven version in the system.properties file.
        remote:        The default supported version is #{DEFAULT_MAVEN_VERSION}
        remote: 
        remote:  !     Push rejected, failed to compile Java app.
      OUTPUT
    end
  end

  it 'installs the default Maven version when no wrapper is present and no version is explicitly configured' do
    app = Hatchet::Runner.new('simple-http-service', allow_failure: true)
    app.before_deploy do
      `rm -r mvnw`
    end

    app.deploy do
      expect(clean_output(app.output)).not_to include('$ ./mvnw')
      expect(clean_output(app.output)).to include("remote: -----> Installing Maven #{DEFAULT_MAVEN_VERSION}... done")
      expect(clean_output(app.output)).to include("[BUILDPACK INTEGRATION TEST - MAVEN VERSION] #{DEFAULT_MAVEN_VERSION}")
    end
  end

  it 'fails with an error message when the configured Maven version is unknown' do
    app = Hatchet::Runner.new('simple-http-service', allow_failure: true)
    app.before_deploy do
      `rm -f mvnw`
      add_to_system_properties('maven.version', UNKNOWN_MAVEN_VERSION)
    end

    app.deploy do
      expect(clean_output(app.output)).to include(<<~OUTPUT)
        remote: -----> Installing Maven #{UNKNOWN_MAVEN_VERSION}...
        remote:  !     ERROR: Error, you have defined an unsupported Maven version in the system.properties file.
        remote:        The default supported version is #{DEFAULT_MAVEN_VERSION}
        remote: 
        remote:  !     Push rejected, failed to compile Java app.
      OUTPUT
    end
  end

  it 'installs the correct Maven version when explicitly configured' do
    app = Hatchet::Runner.new('simple-http-service')
    app.before_deploy do
      `rm mvnw`
      add_to_system_properties('maven.version', '3.9.4')
    end

    app.deploy do
      expect(clean_output(app.output)).not_to include('$ ./mvnw')
      expect(clean_output(app.output)).to include('remote: -----> Installing Maven 3.9.4... done')
      expect(clean_output(app.output)).to include('[BUILDPACK INTEGRATION TEST - MAVEN VERSION] 3.9.4')
    end
  end
end

DEFAULT_MAVEN_VERSION = '3.9.4'
UNKNOWN_MAVEN_VERSION = '1.0.0-unknown-version'
SIMPLE_HTTP_SERVICE_MAVEN_WRAPPER_VERSION = '3.6.3'
