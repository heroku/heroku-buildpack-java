require_relative "spec_helper"

describe "Heroku's Java Buildpack" do
  context "with a polyglot Maven app" do
    it "will pass the detect phase and build the app successfully" do
      new_default_hatchet_runner("test/fixtures/simple-http-service-groovy-polyglot") do |app|
        app.deploy do |app|
          expect(app.output).to include("[INFO] BUILD SUCCESS")
        end
      end
    end
  end
end
