require_relative "spec_helper"

describe "Heroku's Java buildpack" do
  context "using OpenJDK #{DEFAULT_OPENJDK_VERSION}" do
    it "supports heroku-javaagent" do
      Hatchet::Runner.new("webapp-runner-sample", stack: ENV["HEROKU_TEST_STACK"]).tap do |app|
        app.before_deploy do
          set_java_version(DEFAULT_OPENJDK_VERSION)

          java_agent_filename="heroku-javaagent-2.0.jar"
          run("curl --fail --retry 3 --retry-connrefused --connect-timeout 5 --silent -O -L https://repo1.maven.org/maven2/com/heroku/agent/heroku-javaagent/2.0/#{java_agent_filename}")
          write_to_procfile("web: java $JAVA_OPTS -javaagent:#{java_agent_filename}=stdout=true,lxmem=true -jar target/dependency/webapp-runner.jar --port $PORT target/*.war")
        end

        app.deploy do
          expect(app.output).to include("BUILD SUCCESS")
          expect(http_get(app)).to eq("Hello from Java!")

          # We need to wait a moment for the logs to show up
          sleep(10)

          expect(run("heroku logs -n 2000 -a #{app.name}"))
              .to include("measure.mem.jvm.heap.used=")
              .and include("measure.mem.jvm.nonheap.used=")
              .and include("measure.threads.jvm.total=")
        end
      end
    end
  end
end
