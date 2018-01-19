require_relative 'spec_helper'

describe "Spring" do
  before(:each) do
    set_java_version(app.directory, jdk_version)
    init_app(app)
  end

  ["1.7", "1.8"].each do |version|
    context "on jdk-#{version}" do
      let(:jdk_version) { version }

      context "spring-boot-webapp-runner", :retry => 3, :retry_wait => 10 do
        let(:app) { Hatchet::Runner.new("spring-boot-webapp-runner") }
        it "builds a war" do
          app.deploy do |app|
            sleep(10) # :(
            expect(app.output).to include("Installing JDK #{jdk_version}")
            expect(app.output).to match(%r{Building war: /tmp/.*/target/spring-boot-example-1.0-SNAPSHOT.war})
            expect(app.output).not_to match(%r{Building jar: /tmp/.*/target/spring-boot-example-1.0-SNAPSHOT.jar})
            expect(app.output).not_to include("BUILD FAILURE")

            expect(successful_body(app)).to include("Create a New Appointment")
            expect(app).to be_deployed
          end
        end
      end

      context "spring-boot-executable", :retry => 3, :retry_wait => 10 do
        let(:app) { Hatchet::Runner.new("spring-boot-executable") }
        it "builds an executable jar" do
          app.deploy do |app|
            sleep(10) # :(
            expect(app.output).to include("Installing JDK #{jdk_version}")
            expect(app.output).not_to include("Installing Maven")
            expect(app.output).not_to match(%r{Building war: /tmp/.*/target/spring-boot-example-1.0-SNAPSHOT.war})
            expect(app.output).to match(%r{Building jar: /tmp/.*/target/spring-boot-example-1.0-SNAPSHOT.jar})
            expect(app.output).not_to include("BUILD FAILURE")

            expect(successful_body(app)).to include("Create a New Appointment")
            expect(app).to be_deployed
          end
        end

        context "without a Procfile" do
          before do
            Dir.chdir(app.directory) do
              if File.exists?("Procfile")
                `git rm -f Procfile && git commit -am "remove procfile"`
              end
            end
          end

          it "creates a default process type" do
            app.deploy do |app|
              sleep(10) # :(
              expect(app.output).to include("Installing JDK #{jdk_version}")
              expect(app.output).not_to match(%r{Building war: /tmp/.*/target/spring-boot-example-1.0-SNAPSHOT.war})
              expect(app.output).to match(%r{Building jar: /tmp/.*/target/spring-boot-example-1.0-SNAPSHOT.jar})
              expect(app.output).not_to include("BUILD FAILURE")
              expect(app.output).to include("Procfile declares types     -> (none)")
              expect(app.output).to include("Default types for buildpack -> web")

              expect(successful_body(app)).to include("Create a New Appointment")
              expect(app).to be_deployed
            end
          end
        end
      end

    end
  end
end
