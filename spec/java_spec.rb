require_relative 'spec_helper'

describe "Java" do
  before(:each) do
    set_java_version(app.directory, jdk_version)
  end

  ["1.7", "1.8"].each do |version|
    context "on jdk-#{version}" do
      let(:app) { Hatchet::Runner.new("java-servlets-sample") }
      let(:jdk_version) { version }
      it "should not install settings.xml" do
        app.deploy do |app|
          expect(app).to be_deployed
          expect(app.output).to include("Installing OpenJDK #{jdk_version}")
          expect(app.output).to include("Installing Maven 3.0.3")
          expect(app.output).not_to include("Installing settings.xml")
          expect(app.output).not_to include("BUILD FAILURE")
          expect(app.output).to include("BUILD SUCCESS")

          expect(successful_body(app)).to eq("Hello from Java!")
        end
      end
    end
  end

  context "on jdk-1.6" do
    let(:app) { Hatchet::Runner.new("java-servlets-sample", allow_failure: true) }
    let(:jdk_version) { "1.6" }
    it "should not compile 1.7 source" do
      app.deploy do |app|
        expect(app).not_to be_deployed
        expect(app.output).to include("javac: invalid target release: 1.7")
        expect(app.output).to include("BUILD FAILURE")
      end
    end
  end

  context "korvan" do
    ["1.6", "1.7"].each do |version|
      let(:app) { Hatchet::Runner.new("korvan") }
      context "on jdk-#{version}" do
        let(:jdk_version) { version }
        it "runs commands" do
          app.deploy do |app|
            expect(app).to be_deployed
            expect(app.output).to include("Installing OpenJDK #{jdk_version}")
            expect(app.output).to include("Installing Maven 3.0.3")
            expect(app.output).not_to include("Installing settings.xml")
            expect(app.output).not_to include("BUILD FAILURE")

            expect(successful_body(app)).to eq("/1")

            expect(app.run("jce")).
                to include("Picked up JAVA_TOOL_OPTIONS:  -Djava.rmi.server.useCodebaseOnly=true -Djava.rmi.server.useCodebaseOnly=true").
                and include(%q{Encrypting, "Test"}).
                and include(%q{Decrypted: Test})

            expect(app.run("netpatch")).
                to include("Picked up JAVA_TOOL_OPTIONS:  -Djava.rmi.server.useCodebaseOnly=true -Djava.rmi.server.useCodebaseOnly=true").
                and include(%q{name:eth0 (eth0)}).
                and include(%q{name:lo (lo)})

          end
        end
      end
    end
  end

  ["1.6", "1.7", "1.8"].each do |version|
    context "#{version} with webapp-runner" do
      let(:app) { Hatchet::Runner.new("webapp-runner-sample") }
      let(:jdk_version) { version }

      context "and expanded war" do
        before do
          Dir.chdir(app.directory) do
            File.open('Procfile', 'w') do |f|
              f.puts <<-EOF
              web: java $JAVA_OPTS -jar target/dependency/webapp-runner.jar --expand-war --port $PORT target/*.war
              EOF
            end
            `git commit -am "adding --expand-war to Procfile"`
          end
        end

        it "expands war" do
          app.deploy do |app|
            expect(app).to be_deployed
            expect(app.output).to include("Installing OpenJDK #{jdk_version}")
            expect(app.output).to include("Installing Maven 3.0.3")
            expect(app.output).to match(%r{Building war: /tmp/.*/target/.*.war})
            expect(app.output).not_to match(%r{Building jar: /tmp/.*/target/.*.jar})
            expect(app.output).not_to include("Installing settings.xml")
            expect(app.output).not_to include("BUILD FAILURE")
            expect(app.output).to include("BUILD SUCCESS")

            expect(successful_body(app)).to eq("Hello from Java!")
          end
        end
      end
    end
  end
end
