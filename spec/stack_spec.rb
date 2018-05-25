require_relative 'spec_helper'

describe "Stacks" do

  def expect_successful_maven(jdk_version)
    expect(app.output).to include("Installing JDK #{jdk_version}")
    expect(app.output).not_to include("BUILD FAILURE")
    expect(app.output).to include("BUILD SUCCESS")
  end

  before(:each) do
    set_java_version(app.directory, jdk_version)
    init_app(app, test_stack)
  end

  context "korvan" do
    ["1.8", "9", "10"].each do |version|
      ["heroku-18"].each do |stack|
        let(:app) { Hatchet::Runner.new("korvan") }
        context "on #{stack} with jdk-#{version}" do
          let(:jdk_version) { version }
          let(:test_stack) { stack }
          it "runs commands" do
            app.deploy do |app|
              expect_successful_maven(jdk_version)

              expect(successful_body(app)).to eq("/1")

              expect(app.run("echo \$JAVA_OPTS")).
                  to include(%q{-Xmx300m -Xss512k})

              sleep 1
              expect(app.run("env")).
                 not_to include(%q{DATABASE_URL})

              sleep 1 # make sure the dynos don't overlap
              expect(app.run("jce")).
                  to include(%q{Encrypting, "Test"}).
                  and include(%q{Decrypted: Test})

              sleep 1 # make sure the dynos don't overlap
              expect(app.run("netpatch")).
                  to include(%q{name:eth0 (eth0)}).
                  and include(%q{name:lo (lo)})

              sleep 1 # make sure the dynos don't overlap
              expect(app.run("https")).
                  to include("Successfully invoked HTTPS service.").
                  and match(%r{"X-Forwarded-Proto(col)?":\s?"https"})
            end
          end
        end
      end
    end
  end
end
