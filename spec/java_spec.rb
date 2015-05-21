require_relative 'spec_helper'

describe "Java" do

  def expect_successful_maven(jdk_version)
    expect(app.output).to include("Installing OpenJDK #{jdk_version}")
    expect(app.output).to include("Installing Maven 3.3.1")
    expect(app.output).not_to include("Installing settings.xml")
    expect(app.output).not_to include("BUILD FAILURE")
    expect(app.output).to include("BUILD SUCCESS")
  end

  before(:each) do
    set_java_version(app.directory, jdk_version)
    init_app(app)
  end

  ["1.7", "1.8"].each do |version|
    context "on jdk-#{version}" do
      let(:app) { Hatchet::Runner.new("java-servlets-sample") }
      let(:jdk_version) { version }
      it "should not install settings.xml" do
        app.deploy do |app|
          expect_successful_maven(jdk_version)
          expect(successful_body(app)).to eq("Hello from Java!")

          `git commit -am "redeploy" --allow-empty`
          app.push!
          expect(app.output).not_to include("Installing Maven")
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
        expect(app.output).to include("Unsupported major.minor version 51.0")
      end
    end
  end

  context "korvan" do
    ["1.7", "1.8"].each do |version|
      let(:app) { Hatchet::Runner.new("korvan") }
      context "on jdk-#{version}" do
        let(:jdk_version) { version }
        it "runs commands" do
          app.deploy do |app|
            expect_successful_maven(jdk_version)

            expect(successful_body(app)).to eq("/1")

            expect(app.run("echo $JAVA_TOOL_OPTIONS")).
                to include(%q{-Xmx384m -Xss512k -Dfile.encoding=UTF-8})

            expect(app.run("echo $JAVA_OPTS")).
                to include(%q{-Xmx384m -Xss512k})

            expect(app.run("jce")).
                to include(%q{Encrypting, "Test"}).
                and include(%q{Decrypted: Test})

            expect(app.run("netpatch")).
                to include(%q{name:eth0 (eth0)}).
                and include(%q{name:lo (lo)})

            expect(app.run("https")).
                to include("Successfully invoked HTTPS service.").
                and match(%r{"X-Forwarded-Proto(col)?": "https"})
          end
        end
      end
    end
  end

  %w{1.7 1.8}.each do |version|
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

        it "expands war", :retry => 3, :retry_wait => 5 do
          app.deploy do |app|
            expect_successful_maven(jdk_version)
            expect(app.output).to match(%r{Building war: /tmp/.*/target/.*.war})
            expect(app.output).not_to match(%r{Building jar: /tmp/.*/target/.*.jar})

            expect(successful_body(app)).to eq("Hello from Java!")
          end
        end
      end
    end
  end
end
