require_relative "spec_helper"

describe "Heroku's Maven Cloud Native Buildpack" do
  context "for a Spring Boot app" do
    it "will automatically add a process type for that app" do
      rapier.app_dir_from_fixture("buildpack-java-spring-boot-test") do |app_dir|
        # Note the missing Procfile buildpack in the list of buildpacks
        rapier.pack_build(app_dir, buildpacks: ["heroku/jvm", :this]) do |pack_result|
          pack_result.start_container(expose_ports: 8080) do |container|
            response = Excon.get("http://localhost:#{container.get_host_port(8080)}/", :idempotent => true, :retry_limit => 5, :retry_interval => 1)
            expect(response.body).to eq("Hello from Spring Boot!")
          end
        end
      end
    end
  end
end
