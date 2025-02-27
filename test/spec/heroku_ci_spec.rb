# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Maven buildpack' do
  it 'runs tests on Heroku CI' do
    app = Hatchet::Runner.new('simple-http-service')

    app.run_ci do |test_run|
      expect(clean_output(test_run.output)).to match(Regexp.new(<<~REGEX, Regexp::MULTILINE))
        \\[INFO\\] -------------------------------------------------------
        \\[INFO\\]  T E S T S
        \\[INFO\\] -------------------------------------------------------
        \\[INFO\\] Running com.heroku.AppTest
        \\[INFO\\] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: [0-9\\.]+ s - in com.heroku.AppTest
        \\[INFO\\] 
        \\[INFO\\] Results:
        \\[INFO\\] 
        \\[INFO\\] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
      REGEX
    end
  end
end
