require_relative 'spec_helper'

describe "JavaAgent" do

  %w{1.7 1.8}.each do |version|
    context "on #{version}" do
      let(:app) { @app }

      before(:all) do
        @app = Hatchet::Runner.new("webapp-runner-sample")
        init_app(@app)
        javaagent="heroku-javaagent-1.5.jar"
        Dir.chdir(@app.directory) do
          `curl --silent -O -L http://repo1.maven.org/maven2/com/heroku/agent/heroku-javaagent/1.5/#{javaagent}`
          `git add #{javaagent}`

          # edit the procfile
          File.open('Procfile', 'w') do |f|
            f.puts <<-EOF
web: java $JAVA_OPTS -javaagent:#{javaagent}=stdout=true,lxmem=true -jar target/dependency/webapp-runner.jar --port $PORT target/*.war
EOF
          end
          `git add Procfile`
          `git commit -m "adding java agent"`
        end
        @app.deploy
      end

      after(:all) do
        @app.teardown!
      end

      it "deploys successfully" do
        expect(app.output).to include("BUILD SUCCESS")
        sleep(10) # :( for the logs really
        expect(successful_body(app)).to eq("Hello from Java!")
        expect(app).to be_deployed
      end

      it "logs memory usage", :retry => 5, :retry_wait => 5 do
        logs = `heroku logs -a #{app.name}`
        expect(logs).
            to include("measure.mem.jvm.heap.used=").
            and include("measure.mem.jvm.nonheap.used=").
            and include("measure.threads.jvm.total=")
      end
    end
  end
end
