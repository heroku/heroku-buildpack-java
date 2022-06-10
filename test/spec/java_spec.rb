require_relative "spec_helper"

describe "Heroku's Java buildpack" do
  OPENJDK_VERSIONS.each do |openjdk_version|
    context "using OpenJDK #{openjdk_version}" do
      it "should not reinstall Maven" do
        Hatchet::Runner.new("java-servlets-sample", stack: ENV["HEROKU_TEST_STACK"]).tap do |app|
          app.before_deploy do
            set_java_version(openjdk_version)
          end

          app.deploy do
            expect(app.output).to include("Installing OpenJDK #{openjdk_version}")
            expect(app.output).to include("BUILD SUCCESS")
            # Commit ed358d63b384bc7c8cf96be61ada768f4cc55a19 on the example app added Maven Wrapper to
            # the project, bypassing Maven installation entirely.
            # expect(app.output).to include("Installing Maven")
            expect(app.output).not_to include("BUILD FAILURE")
            expect(http_get(app)).to eq("Hello from Java!")

            app.commit!
            app.push!

            expect(app.output).to include("Installing OpenJDK #{openjdk_version}")
            expect(app.output).to include("BUILD SUCCESS")
            expect(app.output).not_to include("BUILD FAILURE")
            expect(app.output).not_to include("Installing Maven")
            expect(http_get(app)).to eq("Hello from Java!")
          end
        end
      end

      it "builds and executes Korvan test commands successfully" do
        Hatchet::Runner.new("korvan", stack: ENV["HEROKU_TEST_STACK"], run_multi: true).tap do |app|
          app.before_deploy do
            set_java_version(openjdk_version)
          end

          app.deploy do
            expect(app.output).to include("Installing OpenJDK #{openjdk_version}")
            expect(app.output).to include("BUILD SUCCESS")
            expect(app.output).not_to include("BUILD FAILURE")
            expect(http_get(app)).to eq("/1")

            app.run_multi("echo $JAVA_OPTS") do |out, status|
              expect(status.success?).to be_truthy
              expect(out).to include("-Xmx300m -Xss512k")
            end

            app.run_multi("env") do |out, status|
              expect(status.success?).to be_truthy
              expect(out).not_to include("DATABASE_URL")
            end

            app.run_multi("java -cp target/app.jar JCE") do |out, status|
              expect(status.success?).to be_truthy
              expect(out)
                  .to include("Encrypting, \"Test\"")
                  .and include("Decrypted: Test")
            end

            app.run_multi("java -cp target/app.jar NetPatch") do |out, status|
              expect(status.success?).to be_truthy
              expect(out)
                  .to include("name:eth0 (eth0)")
                  .and include("name:lo (lo)")
            end

            app.run_multi("java -cp target/app.jar Https") do |out, status|
              expect(status.success?).to be_truthy
              expect(out)
                  .to include("Successfully invoked HTTPS service.")
                  .and match(%r{"X-Forwarded-Proto(col)?":\s?"https"})
            end

            # OpenJDK versions > 9 do not have the jre/lib/ext directory where we drop the pgconfig.jar
            if openjdk_version.match(%r{^(1\.7|1\.8)$})
              app.run_multi("java -cp target/app.jar PostgresSSLTest") do |out, status|
                expect(status.success?).to be_truthy
                expect(out).to include("sslmode: require")
              end
            end
          end
        end
      end

      it "work correctly when libpng dependent features are used" do
        Hatchet::Runner.new("libpng-test", stack: ENV["HEROKU_TEST_STACK"]).tap do |app|
          app.before_deploy do
            set_java_version(openjdk_version)
          end

          app.deploy do
            expect(app.output).to include("Installing OpenJDK #{openjdk_version}")
            expect(app.output).to include("BUILD SUCCESS")
            expect(app.output).not_to include("BUILD FAILURE")
            expect(http_get(app)).to eq("All Good!!!")
          end
        end
      end

      it "works correctly with --expand-war option on webapp-runner" do
        Hatchet::Runner.new("webapp-runner-sample").tap do |app|
          app.before_deploy do
            set_java_version(openjdk_version)
            write_to_procfile("web: java $JAVA_OPTS -jar target/dependency/webapp-runner.jar --expand-war --port $PORT target/*.war")
          end

          app.deploy do
            expect(app.output).to include("Installing OpenJDK #{openjdk_version}")
            expect(app.output).to include("BUILD SUCCESS")
            expect(app.output).not_to include("BUILD FAILURE")

            expect(app.output).to match(%r{Building war: /tmp/.*/target/.*.war})
            expect(app.output).not_to match(%r{Building jar: /tmp/.*/target/.*.jar})

            expect(http_get(app)).to eq("Hello from Java!")
          end
        end
      end
    end
  end
end
