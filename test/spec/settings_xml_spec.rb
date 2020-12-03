require_relative "spec_helper"

url = "https://gist.githubusercontent.com/Malax/d47323823a3d59249cbb5593c4f1b764/raw/83f196719d2c4d56aec6720964ba7d7c86b71727/download-settings.xml"
url_value = "Main screen turn on."

describe "Heroku's Java Buildpack" do
  context "when the MAVEN_SETTINGS_URL environment variable is set" do
    it "will download and use the settings.xml form that URL" do
      new_default_hatchet_runner("test/fixtures/simple-http-service").tap do |app|
        app.before_deploy do
          app.set_config({:MAVEN_SETTINGS_URL => url})
        end

        app.deploy do |app|
          expect(app.output).to include("[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] #{url_value}")
        end
      end
    end

    #it "will fail with a descriptive error message if that settings.xml file could not be downloaded" do
    #  new_default_hatchet_runner("test/fixtures/simple-http-service").tap do |app|
    #    rapier.pack_build(app_dir, exception_on_failure: false, build_env: {:MAVEN_SETTINGS_URL => "https://gist.githubusercontent.com/Malax/settings.xml"}) do |pack_result|
    #      expect(pack_result.build_success?).to be(false)
    #      expect(app.output).to include("Could not download settings.xml from the URL defined in MAVEN_SETTINGS_URL:")
    #      # This error message comes from Maven itself. We expect Maven to to be executed at all.
    #      expect(pack_result).to_not include("[INFO] BUILD FAILURE")
    #    end
    #  end
    #end
  end

  context "when the MAVEN_SETTINGS_PATH environment variable is set" do
    it "will use that settings.xml file" do
      new_default_hatchet_runner("test/fixtures/simple-http-service").tap do |app|
        settings_xml_filename = "forgreatjustice.xml"
        settings_xml_test_value = "Take off every 'ZIG'!!"

        app.before_deploy do
          write_settings_xml(Dir.pwd, settings_xml_filename, settings_xml_test_value)
          app.set_config({:MAVEN_SETTINGS_PATH => settings_xml_filename})
        end

        app.deploy do |app|
          expect(app.output).to include("[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] #{settings_xml_test_value}")
        end
      end
    end
  end

  context "when the MAVEN_SETTINGS_URL and MAVEN_SETTINGS_PATH environment variables are set" do
    it "will give MAVEN_SETTINGS_PATH precedence" do
      new_default_hatchet_runner("test/fixtures/simple-http-service").tap do |app|
        settings_xml_filename = "zerowing.xml"
        settings_xml_test_value = "We get signal."

        app.before_deploy do
          write_settings_xml(Dir.pwd, settings_xml_filename, settings_xml_test_value)
          app.set_config({:MAVEN_SETTINGS_URL => url, :MAVEN_SETTINGS_PATH => settings_xml_filename})
        end

        app.deploy do |app|
          expect(app.output).to include("[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] #{settings_xml_test_value}")
        end
      end
    end
  end

  context "with an app that has a settings.xml file in the it's root directory" do
    it "will use that settings.xml file" do
      new_default_hatchet_runner("test/fixtures/simple-http-service").tap do |app|
        settings_xml_filename = "settings.xml"
        settings_xml_test_value = "Somebody set up us the bomb."

        app.before_deploy do
          write_settings_xml(Dir.pwd, settings_xml_filename, settings_xml_test_value)
        end

        app.deploy do |app|
          expect(app.output).to include("[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] #{settings_xml_test_value}")
        end
      end
    end
  end

  context "with an app that has a settings.xml file in the root directory and the MAVEN_SETTINGS_PATH environment variable is set" do
    it "will give MAVEN_SETTINGS_PATH precedence" do
      new_default_hatchet_runner("test/fixtures/simple-http-service").tap do |app|
        zero_wing_filename = "zerowing.xml"
        zero_wing_test_value = "How are you gentlemen !!"
        settings_xml_test_value = "Somebody set up us the bomb."

        app.before_deploy do
          write_settings_xml(Dir.pwd, "settings.xml", settings_xml_test_value)
          write_settings_xml(Dir.pwd, zero_wing_filename, zero_wing_test_value)
          app.set_config({:MAVEN_SETTINGS_PATH => zero_wing_filename})
        end

        app.deploy do |app|
          expect(app.output).to include("[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] #{zero_wing_test_value}")
        end
      end
    end
  end

  context "with an app that has a settings.xml file in the root directory and the MAVEN_SETTINGS_URL environment variable is set" do
    it "will give MAVEN_SETTINGS_URL precedence" do
      new_default_hatchet_runner("test/fixtures/simple-http-service").tap do |app|
        settings_xml_test_value = "We get signal."

        app.before_deploy do
          write_settings_xml(Dir.pwd, "settings.xml", settings_xml_test_value)
          app.set_config({:MAVEN_SETTINGS_URL => url})
        end

        app.deploy do |app|
          expect(app.output).to include("[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] #{url_value}")
        end
      end
    end
  end
end
