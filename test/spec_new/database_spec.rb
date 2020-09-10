require_relative 'spec_helper'
require 'json'

describe "Heroku's Java Buildpack" do
  it "should automatically add a database addon when a postgres driver is detected in the list of dependencies" do
    Hatchet::Runner.new("test/spec_new/fixtures/repos/database-test-app", stack: ENV["HEROKU_TEST_STACK"]).tap do |app|
      app.deploy do
        expect_maven_build_success(app)
        expect_http_ok(app)

        result = JSON.parse(`heroku addons --json -a #{app.name}`)
        expect(result[0]["plan"]["name"]).to eq("heroku-postgresql:hobby-dev")
      end
    end
  end

  it "should not add a database addon when no postgres driver is detected" do
    Hatchet::Runner.new("test/spec_new/fixtures/repos/simple-maven-app", stack: ENV["HEROKU_TEST_STACK"]).tap do |app|
      app.deploy do
        expect_maven_build_success(app)
        expect_http_ok(app)

        result = JSON.parse(`heroku addons --json -a #{app.name}`)
        expect(result).to be_empty
      end
    end
  end
end
