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
        remote:  !     Error: Unable to download Maven settings.xml.
        remote:  !
        remote:  !     An error occurred while downloading the Maven settings file from:
        remote:  !     #{SETTINGS_XML_URL_404}
        remote:  !
        remote:  !     In some cases, this happens due to a temporary issue with
        remote:  !     the network connection or server, or because the URL is
        remote:  !     inaccessible or requires authentication.
        remote:  !
        remote:  !     Check that the URL in your MAVEN_SETTINGS_URL environment
        remote:  !     variable is correct and publicly accessible. If the settings file
        remote:  !     is not needed, you can remove the MAVEN_SETTINGS_URL environment variable
        remote:  !     to use default Maven settings.
        remote:  !
        remote:  !     Learn more about Maven settings configuration:
        remote:  !     https://devcenter.heroku.com/articles/using-a-custom-maven-settings-xml
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

  context 'when settings.xml already exists' do
    it 'preserves existing settings.xml and warns when MAVEN_SETTINGS_PATH is set' do
      settings_xml_filename = 'custom-settings.xml'
      custom_test_value = 'Custom settings from MAVEN_SETTINGS_PATH'
      existing_test_value = 'Existing settings file'

      app = Hatchet::Runner.new('simple-http-service', config: { MAVEN_SETTINGS_PATH: settings_xml_filename })

      app.before_deploy do
        write_settings_xml(settings_xml_filename, custom_test_value)
        FileUtils.mkdir_p('.m2')
        write_settings_xml('.m2/settings.xml', existing_test_value)
        `git add . && git commit -m "add settings files"`
      end

      app.deploy do
        expect(clean_output(app.output)).to match(Regexp.new(<<~REGEX, Regexp::MULTILINE))
          remote:  !     Warning: Using existing settings\\.xml file\\.
          remote:  !
          remote:  !     A settings\\.xml file already exists at .*\\.m2/settings\\.xml\\.
          remote:  !     However, the MAVEN_SETTINGS_PATH environment variable is set, which
          remote:  !     would normally be used as the settings\\.xml configuration\\. The existing
          remote:  !     file will be used\\.
          remote:  !
          remote:  !     If you intended to use the settings from MAVEN_SETTINGS_PATH instead,
          remote:  !     remove the existing settings\\.xml file at .*\\.m2/settings\\.xml\\.
        REGEX

        expect(clean_output(app.output)).to(
          include("[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] #{existing_test_value}")
        )
        expect(clean_output(app.output)).not_to(
          include("[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] #{custom_test_value}")
        )
      end
    end

    it 'preserves existing settings.xml and warns when MAVEN_SETTINGS_URL is set' do
      existing_test_value = 'Existing settings file for URL test'

      app = Hatchet::Runner.new('simple-http-service', config: { MAVEN_SETTINGS_URL: SETTINGS_XML_URL })

      app.before_deploy do
        FileUtils.mkdir_p('.m2')
        write_settings_xml('.m2/settings.xml', existing_test_value)
        `git add . && git commit -m "add existing settings file"`
      end

      app.deploy do
        expect(clean_output(app.output)).to match(Regexp.new(<<~REGEX, Regexp::MULTILINE))
          remote:  !     Warning: Using existing settings\\.xml file\\.
          remote:  !
          remote:  !     A settings\\.xml file already exists at .*\\.m2/settings\\.xml\\.
          remote:  !     However, the MAVEN_SETTINGS_URL environment variable is set, which
          remote:  !     would normally be used as the settings\\.xml configuration\\. The existing
          remote:  !     file will be used\\.
          remote:  !
          remote:  !     If you intended to use the settings from MAVEN_SETTINGS_URL instead,
          remote:  !     remove the existing settings\\.xml file at .*\\.m2/settings\\.xml\\.
        REGEX

        expect(clean_output(app.output)).to(
          include("[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] #{existing_test_value}")
        )
        expect(clean_output(app.output)).not_to(
          include("[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] #{SETTINGS_XML_URL_VALUE}")
        )
      end
    end

    it 'preserves existing settings.xml and warns when project settings.xml exists' do
      project_test_value = 'Project directory settings'
      existing_test_value = 'Existing settings file for project test'

      app = Hatchet::Runner.new('simple-http-service')

      app.before_deploy do
        write_settings_xml('settings.xml', project_test_value)
        FileUtils.mkdir_p('.m2')
        write_settings_xml('.m2/settings.xml', existing_test_value)
        `git add . && git commit -m "add settings files"`
      end

      app.deploy do
        expect(clean_output(app.output)).to match(Regexp.new(<<~REGEX, Regexp::MULTILINE))
          remote:  !     Warning: Using existing settings\\.xml file\\.
          remote:  !
          remote:  !     A settings\\.xml file already exists at .*\\.m2/settings\\.xml\\.
          remote:  !     However, a settings\\.xml file was also found in the project directory,
          remote:  !     which would normally be used as the settings\\.xml configuration\\. The
          remote:  !     existing file will be used\\.
          remote:  !
          remote:  !     If you intended to use the settings from your project directory instead,
          remote:  !     remove the existing settings\\.xml file at .*\\.m2/settings\\.xml\\.
        REGEX

        expect(clean_output(app.output)).to(
          include("[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] #{existing_test_value}")
        )
        expect(clean_output(app.output)).not_to(
          include("[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] #{project_test_value}")
        )
      end
    end

    it 'uses existing settings.xml without warning when no other methods are configured' do
      existing_test_value = 'Existing settings file, no conflicts'

      app = Hatchet::Runner.new('simple-http-service')

      app.before_deploy do
        FileUtils.mkdir_p('.m2')
        write_settings_xml('.m2/settings.xml', existing_test_value)
        `git add . && git commit -m "add existing settings file"`
      end

      app.deploy do
        expect(clean_output(app.output)).not_to match(/remote:  !     Warning: Using existing settings\.xml file\./)
        expect(clean_output(app.output)).not_to match(/would normally be used as the settings\.xml configuration/)
        expect(clean_output(app.output)).to(
          include("[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] #{existing_test_value}")
        )
      end
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
