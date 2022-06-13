require_relative "spec_helper"

describe "Heroku's Java buildpack" do
  context "using OpenJDK #{DEFAULT_OPENJDK_VERSION}" do
    it "should use connection pool" do
      Hatchet::Runner.new("java-apache-dbcp-sample", stack: ENV["HEROKU_TEST_STACK"]).tap do |app|
        app.before_deploy do
          set_java_version(DEFAULT_OPENJDK_VERSION)
        end

        app.deploy do
          expect(app.output).to include("Installing OpenJDK #{DEFAULT_OPENJDK_VERSION}")
          expect(app.output).to include("Installing Maven")
          expect(app.output).to include("BUILD SUCCESS")
          expect(http_get(app, :path => "db")).to match("Read from DB:")
        end
      end
    end
  end
end
