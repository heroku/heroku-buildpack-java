require "rspec/core"
require "rspec/retry"
require "hatchet"
require "java-properties"

OPENJDK_VERSIONS=%w(1.8 11)
DEFAULT_OPENJDK_VERSION="1.8"

RSpec.configure do |config|
  config.fail_if_no_examples = true
  config.full_backtrace      = true
  # rspec-retry
  config.verbose_retry       = true
  config.default_retry_count = 2 if ENV["CI"]
end

def set_java_version(version_string)
  set_system_properties_key("java.runtime.version", version_string)
end

def set_maven_version(version_string)
  set_system_properties_key("maven.version", version_string)
end

def set_system_properties_key(key, value)
  properties = {}

  if File.file?("system.properties")
    properties = JavaProperties.load("system.properties")
  end

  properties[key.to_sym] = value
  JavaProperties.write(properties, "system.properties")
end

def write_to_procfile(content)
  File.open("Procfile", "w") do |file|
    file.write(content)
  end
end

def run(cmd)
  out = `#{cmd}`
  raise "Command #{cmd} failed with output #{out}" unless $?.success?
  out
end

def http_get(app, options = {})
  retry_limit = options[:retry_limit] || 50
  path = options[:path] ? "/#{options[:path]}" : ""

  begin
    Excon.get("#{app.platform_api.app.info(app.name).fetch("web_url")}#{path}", :idempotent => true, :expects => 200, :retry_limit => retry_limit).body
  rescue Excon::Error => e
    puts e.response.body
  end
end
