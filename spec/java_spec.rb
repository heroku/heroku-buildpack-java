require_relative 'spec_helper'

describe "Java" do
  before(:each) do
    Dir.chdir(app.directory) do
      File.open('system.properties', 'w') do |f|
        f.puts "java.runtime.version=#{jdk_version}"
      end
      `git commit -am "setting jdk version"`
    end
  end

  let(:app) { Hatchet::Runner.new("java-servlets-sample") }

  ["1.7", "1.8"].each do |version|
    context "on jdk-#{version}" do
      let(:jdk_version) { version }
      it "should not install settings.xml" do
        app.deploy do |app|
          expect(app).to be_deployed
          expect(app.output).to include("Installing OpenJDK #{jdk_version}")
          expect(app.output).to include("Installing Maven 3.0.3")
          expect(app.output).not_to include("Installing settings.xml")
          expect(app.output).not_to include("BUILD FAILURE")

          expect(successful_body(app)).to eq("Hello from Java!")
        end
      end
    end
  end

  context "on jdk-1.6" do
    let(:app) { Hatchet::Runner.new("java-servlets-sample", allow_failure: true) }
    let(:jdk_version) { "1.6" }
    it "should compile 1.7 source" do
      app.deploy do |app|
        expect(app).not_to be_deployed
        expect(app.output).to include("javac: invalid target release: 1.7")
        expect(app.output).to include("BUILD FAILURE")
      end
    end
  end
end
