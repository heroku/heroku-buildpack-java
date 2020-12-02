require_relative "spec_helper"

describe "Heroku's Maven Cloud Native Buildpack" do
  context "with a polyglot Maven app" do
    it "will pass the detect phase and build the app successfully" do
      rapier.app_dir_from_fixture("simple-http-service-groovy-polyglot") do |app_dir|
        rapier.pack_build(app_dir) do |pack_result|
          expect(pack_result.stdout).to include("[INFO] BUILD SUCCESS")
        end
      end
    end
  end
end
