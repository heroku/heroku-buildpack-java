# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Maven buildpack' do
  it 'automatically adds a correct default process type for a Spring Boot app' do
    app = Hatchet::Runner.new('buildpack-java-spring-boot-test')
    app.deploy do
      expect(successful_body(app)).to include('Hello from Spring Boot!')
    end
  end
end
