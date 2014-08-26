require_relative 'spec_helper'

describe "Spring" do
  before(:each) do
    set_java_version(app.directory, jdk_version)
  end

  ["1.6", "1.7", "1.8"].each do |version|
    context "on jdk-#{version}" do
      let(:jdk_version) { version }

      context "spring-boot-webapp-runner" do
        let(:app) { Hatchet::Runner.new("spring-boot-webapp-runner") }
        it "builds a war" do
          app.deploy do |app|
            expect(app).to be_deployed
            expect(app.output).to include("Installing OpenJDK #{jdk_version}")
            expect(app.output).to include("Installing Maven 3.0.5")
            expect(app.output).to match(%r{Building war: /tmp/.*/target/spring-boot-example-1.0-SNAPSHOT.war})
            expect(app.output).not_to match(%r{Building jar: /tmp/.*/target/spring-boot-example-1.0-SNAPSHOT.jar})
            expect(app.output).not_to include("Installing settings.xml")
            expect(app.output).not_to include("BUILD FAILURE")

            expect(successful_body(app)).to include("Create a New Appointment")
          end
        end
      end

      context "spring-boot-executable" do
        let(:app) { Hatchet::Runner.new("spring-boot-executable") }
        it "builds an executable jar" do
          app.deploy do |app|
            expect(app).to be_deployed
            expect(app.output).to include("Installing OpenJDK #{jdk_version}")
            expect(app.output).to include("Installing Maven 3.0.5")
            expect(app.output).not_to match(%r{Building war: /tmp/.*/target/spring-boot-example-1.0-SNAPSHOT.war})
            expect(app.output).to match(%r{Building jar: /tmp/.*/target/spring-boot-example-1.0-SNAPSHOT.jar})
            expect(app.output).not_to include("Installing settings.xml")
            expect(app.output).not_to include("BUILD FAILURE")

            expect(successful_body(app)).to include("Create a New Appointment")
          end
        end
      end

    end
  end
end
