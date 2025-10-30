# frozen_string_literal: true

require 'rspec/core'
require 'hatchet'
require 'fileutils'
require 'rspec/retry'
require 'date'
require 'java-properties'

ENV['RACK_ENV'] = 'test'
ENV['HATCHET_BUILDPACK_BASE'] ||= 'https://github.com/heroku/heroku-buildpack-java.git'

RSpec.configure do |config|
  # Disables the legacy rspec globals and monkey-patched `should` syntax.
  config.disable_monkey_patching!
  # Enable flags like --only-failures and --next-failure.
  config.example_status_persistence_file_path = '.rspec_status'
  # Allows limiting a spec run to individual examples or groups by tagging them
  # with `:focus` metadata via the `fit`, `fcontext` and `fdescribe` aliases.
  config.filter_run_when_matching :focus
  # Allows declaring on which stacks a test/group should run by tagging it with `stacks`.
  config.filter_run_excluding stacks: ->(stacks) { !stacks.include?(ENV.fetch('HATCHET_DEFAULT_STACK')) }
  # Make rspec-retry output a retry message when its had to retry a test.
  config.verbose_retry = true
end

def add_to_system_properties(key, value)
  properties = JavaProperties.load('system.properties')
  properties[key] = value
  JavaProperties.write(properties, 'system.properties')
end

def successful_body(app, options = {})
  retry_limit = options[:retry_limit] || 50
  path = options[:path] ? "/#{options[:path]}" : ''
  Excon.get("#{app.platform_api.app.info(app.name).fetch('web_url')}#{path}", idempotent: true, expects: 200,
                                                                              retry_limit: retry_limit).body
end

def set_java_version(directory, version)
  write_sys_props directory, "java.runtime.version=#{version}"
end

def write_sys_props(directory, props)
  Dir.chdir(directory) do
    `rm -f system.properties`
    File.open('system.properties', 'w') do |f|
      f.puts props
    end
    `git add system.properties && git commit -m "setting jdk version"`
  end
end

def clean_output(output)
  output
    # Remove trailing whitespace characters added by Git:
    # https://github.com/heroku/hatchet/issues/162
    .gsub(/ {8}(?=\R)/, '')
    # Remove ANSI colour codes used in buildpack output (e.g. error messages).
    .gsub(/\e\[[0-9;]+m/, '')
    # Remove trailing space from empty "remote: " lines added by Heroku
    .gsub(/^remote: $/, 'remote:')
end
