require_relative 'spec_helper'

describe "Maven" do

  context "polyglot" do
    let(:app) { Hatchet::Runner.new("maven-polyglot") }
    let(:jdk_version) { "1.8" }
    it "detects and deploys" do
      app.deploy do |app|
        expect(app.output).to include("Installing JDK #{jdk_version}")
        expect(app.output).to include(".polyglot.pom.yaml")
        expect(app.output).not_to include("BUILD FAILURE")
        expect(app.output).to include("BUILD SUCCESS")
        expect(successful_body(app)).to eq("Hello from Java!")
      end
    end
  end

  context "on jdk-1.8" do
    let(:app) { Hatchet::Runner.new("java-servlets-sample") }
    let(:jdk_version) { "1.8" }

    it "should upgrade and downgrade successfully" do
      Dir.chdir(app.directory) do
        set_java_and_maven_versions(jdk_version, "3.2.5")
      end

      app.deploy do |app|
        expect(app.output).to include("Installing Maven 3.2.5")
        expect(app.output).to include("BUILD SUCCESS")
        expect(successful_body(app)).to eq("Hello from Java!")

        set_java_and_maven_versions(jdk_version, "3.6.2")

        app.push!
        expect(app.output).to include("Installing Maven 3.6.2")
        expect(app.output).to include("BUILD SUCCESS")
        expect(successful_body(app)).to eq("Hello from Java!")

        set_java_and_maven_versions(jdk_version, "3.5.4")

        app.push!
        expect(app.output).to include("Installing Maven 3.5.4")
        expect(app.output).to include("BUILD SUCCESS")
        expect(successful_body(app)).to eq("Hello from Java!")

        set_java_and_maven_versions(jdk_version, "3.3.9")

        app.push!
        expect(app.output).to include("Installing Maven 3.3.9")
        expect(app.output).to include("BUILD SUCCESS")
        expect(successful_body(app)).to eq("Hello from Java!")
      end
    end
  end
end
