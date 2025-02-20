# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Maven buildpack' do
  it 'supports POM files that are not using XML' do
    app = Hatchet::Runner.new('simple-http-service-groovy-polyglot')
    app.deploy do
      expect(app.output).to include('[INFO] BUILD SUCCESS')
    end
  end
end
