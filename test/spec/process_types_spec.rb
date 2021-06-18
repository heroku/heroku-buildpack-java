require_relative "spec_helper"

describe "Heroku's Java Buildpack" do
  context "for a Spring Boot app" do
    it "will automatically add a process type for that app" do
      new_default_hatchet_runner("test/fixtures/buildpack-java-spring-boot-test").tap do |app|
        app.deploy do |app|
          response = Excon.get("https://#{app.name}.herokuapp.com/", :idempotent => true, :retry_limit => 5, :retry_interval => 1)
          expect(response.body).to eq("Hello from Spring Boot!")
        end
      end
    end
  end
end
