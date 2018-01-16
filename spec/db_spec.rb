require_relative 'spec_helper'

describe "Java" do
  before(:each) do
    set_java_version(app.directory, jdk_version)
    init_app(app)
  end

  %w{1.7 1.8}.each do |version|
    context "on jdk-#{version}" do
      let(:app) { Hatchet::Runner.new("java-apache-dbcp-sample") }
      let(:jdk_version) { version }
      it "should use connection pool" do
        app.deploy do |app|
          expect(app.output).to include("Installing JDK #{jdk_version}")
          expect(app.output).to include("Installing Maven")
          expect(app.output).not_to include("BUILD FAILURE")
          expect(app.output).to include("BUILD SUCCESS")

          expect(successful_body(app, :path => "db")).to match("Read from DB:")

          expect(app).to be_deployed
        end
      end
    end
  end
end
