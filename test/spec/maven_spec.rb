require_relative "spec_helper"

describe "Heroku's Java buildpack" do
  context "using OpenJDK #{DEFAULT_OPENJDK_VERSION}" do
    it "supports Maven polyglot" do
      Hatchet::Runner.new("maven-polyglot", stack: ENV["HEROKU_TEST_STACK"]).tap do |app|
        app.before_deploy do
          set_java_version(DEFAULT_OPENJDK_VERSION)
        end

        app.deploy do
          expect(app.output).to include("Installing OpenJDK #{DEFAULT_OPENJDK_VERSION}")
          expect(app.output).to include(".polyglot.pom.yaml")
          expect(app.output).not_to include("BUILD FAILURE")
          expect(app.output).to include("BUILD SUCCESS")
          expect(http_get(app)).to eq("Hello from Java!")
        end
      end
    end

    it "handles Maven upgrades and downgrades correctly" do
      Hatchet::Runner.new("java-servlets-sample", stack: ENV["HEROKU_TEST_STACK"]).tap do |app|
        app.before_deploy do
          set_java_version(DEFAULT_OPENJDK_VERSION)
          set_maven_version("3.2.5")
        end

        app.deploy do
          expect(app.output).to include("Installing Maven 3.2.5")
          expect(app.output).not_to include("BUILD FAILURE")
          expect(app.output).to include("BUILD SUCCESS")
          expect(http_get(app)).to eq("Hello from Java!")

          %w(3.6.2 3.5.4 3.3.9).each do |maven_version|
            set_maven_version(maven_version)
            app.commit!
            app.push!

            expect(app.output).to include("Installing Maven #{maven_version}")
            expect(app.output).to include("BUILD SUCCESS")
            expect(http_get(app)).to eq("Hello from Java!")
          end
        end
      end
    end
  end
end
