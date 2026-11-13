# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Maven buildpack' do
  it 'resolves Maven Central artifacts from the Google mirror by default' do
    app = Hatchet::Runner.new('simple-http-service')
    app.deploy do
      expect(clean_output(app.output)).to include('Downloading from central: https://maven-central.storage-download.googleapis.com/maven2/')
      expect(clean_output(app.output)).not_to include('Downloading from central: https://repo.maven.apache.org/maven2/')
    end
  end

  it 'resolves Maven Central artifacts from Maven Central when MAVEN_CENTRAL_MIRROR is false',
     skip: 'Maven Central rate limits CI' do
    app = Hatchet::Runner.new('simple-http-service', config: { MAVEN_CENTRAL_MIRROR: 'false' })
    app.deploy do
      expect(clean_output(app.output)).to include('Downloading from central: https://repo.maven.apache.org/maven2/')
      expect(clean_output(app.output)).not_to include('https://maven-central.storage-download.googleapis.com')
    end
  end

  it 'prefers mirrors from the user settings.xml over the Google mirror' do
    app = Hatchet::Runner.new('simple-http-service')

    app.before_deploy do
      File.write('settings.xml', <<~FILE)
        <settings>
          <mirrors>
            <mirror>
              <id>user-mirror</id>
              <mirrorOf>*</mirrorOf>
              <url>https://maven-central.storage-download.googleapis.com/maven2</url>
            </mirror>
          </mirrors>
        </settings>
      FILE
    end

    app.deploy do
      # The user mirror points at the Google mirror instead of Maven Central since Maven Central rate limits CI.
      # The buildpack's mirror has the `central` id, so the mirror id in the log tells them apart.
      expect(clean_output(app.output)).to include('Downloading from user-mirror: https://maven-central.storage-download.googleapis.com/maven2/')
      expect(clean_output(app.output)).not_to include('Downloading from central:')
    end
  end
end
