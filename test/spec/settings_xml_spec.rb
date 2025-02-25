# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Maven buildpack' do
  it 'allows adding Maven settings via SETTINGS_XML_URL' do
    app = Hatchet::Runner.new('simple-http-service', config: { MAVEN_SETTINGS_URL: SETTINGS_XML_URL })
    app.deploy do
      expect(clean_output(app.output)).to(
        include("[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] #{SETTINGS_XML_URL_VALUE}")
      )
    end
  end

  it 'maven_settings_url_failure' do
    app = Hatchet::Runner.new('simple-http-service', allow_failure: true,
                                                     config: { MAVEN_SETTINGS_URL: SETTINGS_XML_URL_404 })
    app.deploy do
      expect(clean_output(app.output)).to include(<<~OUTPUT)
        remote: -----> Executing Maven
        remote:        $ ./mvnw -DskipTests clean dependency:list install
        remote:        [ERROR] Error executing Maven.
        remote:        [ERROR] 1 problem was encountered while building the effective settings
        remote:        [FATAL] Non-parseable settings /tmp/codon/tmp/cache/.m2/settings.xml: only whitespace content allowed before start tag and not N (position: START_DOCUMENT seen N... @1:1)  @ /tmp/codon/tmp/cache/.m2/settings.xml, line 1, column 1
        remote:        
        remote: 
        remote:  !     ERROR: Failed to build app with Maven
        remote:        We're sorry this build is failing! If you can't find the issue in application code,
        remote:        please submit a ticket so we can help: https://help.heroku.com/
        remote: 
        remote:  !     Push rejected, failed to compile Java app.
      OUTPUT
    end
  end

  it 'allows adding Maven settings via MAVEN_SETTINGS_PATH' do
    settings_xml_filename = 'forgreatjustice.xml'
    settings_xml_test_value = "Take off every 'ZIG'!!"

    app = Hatchet::Runner.new('simple-http-service', config: { MAVEN_SETTINGS_PATH: settings_xml_filename })
    app.before_deploy do
      write_settings_xml(settings_xml_filename, settings_xml_test_value)
    end

    app.deploy do
      expect(clean_output(app.output)).to(
        include("[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] #{settings_xml_test_value}")
      )
    end
  end

  it 'picks MAVEN_SETTINGS_PATH over SETTINGS_XML_URL' do
    settings_xml_filename = 'zerowing.xml'
    settings_xml_test_value = 'We get signal.'

    app = Hatchet::Runner.new('simple-http-service',
                              config: { MAVEN_SETTINGS_PATH: settings_xml_filename,
                                        MAVEN_SETTINGS_URL: SETTINGS_XML_URL, })
    app.before_deploy do
      write_settings_xml(settings_xml_filename, settings_xml_test_value)
    end

    app.deploy do
      # MAVEN_SETTINGS_PATH should take precedence
      expect(clean_output(app.output)).to(
        include("[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] #{settings_xml_test_value}")
      )
    end
  end

  it 'automatically uses settings.xml if its present in the application root' do
    settings_xml_filename = 'settings.xml'
    settings_xml_test_value = 'Somebody set up us the bomb.'

    # Note that there is no MAVEN_SETTINGS_PATH here
    app = Hatchet::Runner.new('simple-http-service')

    app.before_deploy do
      write_settings_xml(settings_xml_filename, settings_xml_test_value)
    end

    app.deploy do
      expect(clean_output(app.output)).to(
        include("[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] #{settings_xml_test_value}")
      )
    end
  end

  it 'picks MAVEN_SETTINGS_PATH over the default settings.xml' do
    settings_xml_filename = 'settings.xml'
    settings_xml_test_value = 'Somebody set up us the bomb.'
    zero_wing_filename = 'zerowing.xml'
    zero_wing_test_value = 'How are you gentlemen !!'

    app = Hatchet::Runner.new('simple-http-service', config: { MAVEN_SETTINGS_PATH: zero_wing_filename })

    app.before_deploy do
      write_settings_xml(settings_xml_filename, settings_xml_test_value)
      write_settings_xml(zero_wing_filename, zero_wing_test_value)
    end

    app.deploy do
      expect(clean_output(app.output)).to(
        include("[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] #{zero_wing_test_value}")
      )
    end
  end

  it 'picks MAVEN_SETTINGS_URL over the default settings.xml' do
    settings_xml_filename = 'settings.xml'
    settings_xml_test_value = 'Somebody set up us the bomb.'

    app = Hatchet::Runner.new('simple-http-service', config: { MAVEN_SETTINGS_URL: SETTINGS_XML_URL })

    app.before_deploy do
      write_settings_xml(settings_xml_filename, settings_xml_test_value)
    end

    app.deploy do
      expect(clean_output(app.output)).to(
        include("[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] #{SETTINGS_XML_URL_VALUE}")
      )
    end
  end
end

def write_settings_xml(path, test_value) # rubocop:disable Metrics/MethodLength
  File.write(path, <<~FILE)
    <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">
      <profiles>
          <profile>
              <activation>
                  <activeByDefault>true</activeByDefault>
              </activation>
              <properties>
                  <heroku.maven.settings-test.value>#{test_value}</heroku.maven.settings-test.value>
              </properties>
          </profile>
      </profiles>
    </settings>
  FILE
end

SETTINGS_XML_URL = 'https://gist.githubusercontent.com/Malax/d47323823a3d59249cbb5593c4f1b764/raw/83f196719d2c4d56aec6720964ba7d7c86b71727/download-settings.xml'
SETTINGS_XML_URL_VALUE = 'Main screen turn on.'
SETTINGS_XML_URL_404 = 'https://gist.githubusercontent.com/Malax/settings.xml'
