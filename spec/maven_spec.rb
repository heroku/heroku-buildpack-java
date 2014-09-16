require_relative 'spec_helper'

describe "Maven" do

  context "on jdk-1.7" do
    let(:app) { Hatchet::Runner.new("java-servlets-sample") }
    let(:jdk_version) { "1.7" }

    it "should upgrade and downgrade successfully" do
      set_java_and_maven_versions(app.directory, jdk_version, "3.0.5")

      app.deploy do |app|
        expect(app.output).to include("Installing Maven 3.0.5")
        expect(app.output).to include("BUILD SUCCESS")
        expect(successful_body(app)).to eq("Hello from Java!")

        set_java_and_maven_versions(app.directory, jdk_version, "3.2.3")

        app.push!
        expect(app.output).to include("Installing Maven 3.2.3")
        expect(app.output).to include("BUILD SUCCESS")
        expect(successful_body(app)).to eq("Hello from Java!")

        set_java_and_maven_versions(app.directory, jdk_version, "3.1.1")

        app.push!
        expect(app.output).to include("Installing Maven 3.1.1")
        expect(app.output).to include("BUILD SUCCESS")
        expect(successful_body(app)).to eq("Hello from Java!")
      end
    end
  end

  context "on jdk-1.6" do
    let(:app) { Hatchet::Runner.new("java-servlets-sample") }
    let(:jdk_version) { "1.6" }

    it "should not force and upgrade" do
      set_java_and_maven_versions(app.directory, jdk_version, "3.0.5")

      app.deploy do |app|
        expect(app.output).to include("Installing Maven 3.0.5")
        expect(app.output).to include("BUILD SUCCESS")
        expect(successful_body(app)).to eq("Hello from Java!")

        `git rm system.properties`
        `git commit -m "removed system properties"`

        app.push!
        expect(app.output).not_to include("Installing Maven")
        expect(app.output).to include("BUILD SUCCESS")
        expect(successful_body(app)).to eq("Hello from Java!")
      end
    end
  end
end
