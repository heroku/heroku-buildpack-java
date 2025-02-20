# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Maven buildpack' do
  it 'caches dependencies between builds' do
    app = Hatchet::Runner.new('simple-http-service')
    app.deploy do
      expect(app.output).to include('Downloading from central')

      app.commit!
      app.push!

      expect(app.output).not_to include('Downloading from central')
    end
  end
end
