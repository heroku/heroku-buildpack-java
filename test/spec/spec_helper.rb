require "rspec/core"
require "rspec/retry"
require "java-properties"
require "hatchet"

RSpec.configure do |config|
  # config.filter_run :focus => true
end

def new_default_hatchet_runner(*args, **kwargs)
  kwargs[:stack] ||= ENV["DEFAULT_APP_STACK"]
  kwargs[:config] ||= {}

  ENV.keys.each do |key|
    if key.start_with?("DEFAULT_APP_CONFIG_")
      kwargs[:config][key.delete_prefix("DEFAULT_APP_CONFIG_")] ||= ENV[key]
    end
  end

  Hatchet::Runner.new(*args, **kwargs)
end

def remove_maven_wrapper(app_dir)
  File.delete("#{app_dir}/mvnw")
  File.delete("#{app_dir}/mvnw.cmd")
  FileUtils.remove_dir("#{app_dir}/.mvn/wrapper")
end

def set_java_version(app_dir, version_string)
  set_system_properties_key(app_dir, "java.runtime.version", version_string)
end

def set_maven_version(app_dir, version_string)
  set_system_properties_key(app_dir, "maven.version", version_string)
end

def set_system_properties_key(app_dir, key, value)
  properties = {}

  path = "#{app_dir}/system.properties"

  if File.file?(path)
    properties = JavaProperties.load(path)
  end

  properties[key.to_sym] = value
  JavaProperties.write(properties, path)
end

def write_settings_xml(app_dir, filename, test_value)
  settings_xml = <<~EOF
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
  EOF

  File.open(File.join(app_dir, filename), "w") { |file| file.write(settings_xml) }
end
