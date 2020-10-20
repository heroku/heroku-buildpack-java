require_relative 'spec_helper'

describe "Java" do

  def expect_successful_maven(app, jdk_version)
    expect(app.output).to include("Installing JDK #{jdk_version}")
    expect(app.output).not_to include("BUILD FAILURE")
    expect(app.output).to include("BUILD SUCCESS")
  end

  ["1.7", "1.8", "11"].each do |jdk_version|
    context "on jdk-#{jdk_version}" do
      it "should reinstall maven" do
        Hatchet::Runner.new("java-servlets-sample", stack: ENV["HEROKU_TEST_STACK"]).tap do |app|
          app.before_deploy do
            set_java_version(Dir.pwd, jdk_version)
          end

          app.deploy do |app|
            expect_successful_maven(app, jdk_version)
            expect(app.output).to include("BUILD SUCCESS")
            expect(successful_body(app)).to eq("Hello from Java!")

            app.commit!
            app.push!

            expect_successful_maven(app, jdk_version)
            expect(app.output).not_to include("Installing Maven")
            expect(app.output).to include("BUILD SUCCESS")

            expect(successful_body(app)).to eq("Hello from Java!")

            expect(app.run("env", { :heroku => { "exit-code" => Hatchet::App::SkipDefaultOption }})). # work around a CLI bug that doesn't allow --exit-code when invoking a process type via "heroku run"
            to include(%q{DATABASE_URL})
          end
        end
      end
    end
  end

  context "korvan" do
    ["1.8", "11", "13", "15"].each do |jdk_version|
      context "on jdk-#{jdk_version}" do
        it "runs commands" do
          Hatchet::Runner.new("korvan", stack: ENV["HEROKU_TEST_STACK"], run_multi: true).tap do |app|
            app.before_deploy do
              set_java_version(Dir.pwd, jdk_version)
            end

            app.deploy do |app|
              expect_successful_maven(app, jdk_version)

              expect(successful_body(app)).to eq("/1")

              expect(app.run('echo $JAVA_OPTS')).
                  to include(%q{-Xmx300m -Xss512k})

              expect(app.run("env", { :heroku => { "exit-code" => Hatchet::App::SkipDefaultOption }})). # work around a CLI bug that doesn't allow --exit-code when invoking a process type via "heroku run"
              not_to include(%q{DATABASE_URL})

              expect(app.run("jce", { :heroku => { "exit-code" => Hatchet::App::SkipDefaultOption }})). # work around a CLI bug that doesn't allow --exit-code when invoking a process type via "heroku run"
              to include(%q{Encrypting, "Test"}).
                  and include(%q{Decrypted: Test})

              expect(app.run("netpatch", { :heroku => { "exit-code" => Hatchet::App::SkipDefaultOption }})). # work around a CLI bug that doesn't allow --exit-code when invoking a process type via "heroku run"
              to include(%q{name:eth0 (eth0)}).
                  and include(%q{name:lo (lo)})

              expect(app.run("https", { :heroku => { "exit-code" => Hatchet::App::SkipDefaultOption }})). # work around a CLI bug that doesn't allow --exit-code when invoking a process type via "heroku run"
              to include("Successfully invoked HTTPS service.").
                  and match(%r{"X-Forwarded-Proto(col)?":\s?"https"})

              # JDK 9, 10, and 11 do not have the jre/lib/ext dir where we drop
              # the pgconfig.jar
              if !jdk_version.match(/^9/) and !jdk_version.match(/^10/) and !jdk_version.match(/^11/)
                expect(app.run("pgssl", { :heroku => { "exit-code" => Hatchet::App::SkipDefaultOption }})). # work around a CLI bug that doesn't allow --exit-code when invoking a process type via "heroku run"
                to include("sslmode: require")
              end
            end
          end
        end
      end
    end
  end

  %w{1.7 1.8}.each do |jdk_version|
    context "#{jdk_version} with webapp-runner" do
      context "and expanded war" do
        it "expands war", :retry => 3, :retry_wait => 5 do
          Hatchet::Runner.new("webapp-runner-sample").tap do |app|
            app.before_deploy do
              set_java_version(Dir.pwd, jdk_version)

              File.open('Procfile', 'w') do |f|
                f.puts <<-EOF
                web: java $JAVA_OPTS -jar target/dependency/webapp-runner.jar --expand-war --port $PORT target/*.war
                EOF
              end
              `git commit -am "adding --expand-war to Procfile"`
            end

            app.deploy
              expect_successful_maven(app, jdk_version)
              expect(app.output).to match(%r{Building war: /tmp/.*/target/.*.war})
              expect(app.output).not_to match(%r{Building jar: /tmp/.*/target/.*.jar})

              expect(successful_body(app)).to eq("Hello from Java!")
            end
          end
        end
      end
  end

  %w{1.8 11 13 15}.each do |jdk_version|
    context "#{jdk_version} libpng test" do
      it "returns a successful response", :retry => 3, :retry_wait => 5 do
        Hatchet::Runner.new("libpng-test").tap do |app|
          app.before_deploy do
            set_java_version(Dir.pwd, jdk_version)
          end

          app.deploy do |app|
            expect_successful_maven(app, jdk_version)
            expect(successful_body(app)).to eq("All Good!!!")
          end
        end
      end
    end
  end
end
