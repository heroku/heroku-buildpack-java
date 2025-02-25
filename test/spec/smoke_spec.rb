# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Maven buildpack' do
  it 'can build and run Heroku\'s Java getting started app' do
    app = Hatchet::Runner.new('java-getting-started')
    app.deploy do
      expect(successful_body(app)).to include('Java Getting Started on Heroku')
    end
  end
end
