require_relative 'spec_helper'

describe "Heroku's Java Buildpack" do
  it "xxx" do
    Hatchet::Runner.new("test/spec_new/fixtures/repos/simple-maven-app", stack: ENV["HEROKU_TEST_STACK"]).tap do |app|
      app.deploy do
        # Put even indicies first, odd ones last. This means we will have one version downgrade.
        shuffled_maven_versions = MAVEN_VERSIONS_UNDER_TEST.partition.with_index { |_, index| index.even? }.flatten

        shuffled_maven_versions.each do |maven_version|
          set_maven_version(maven_version)
          app.commit!
          app.push!

          expect_maven_version(maven_version, app)
          expect_maven_build_success(app)
          expect_http_ok(app)
        end
      end
    end
  end
end
