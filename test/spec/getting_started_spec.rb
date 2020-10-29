describe "A Java application" do
  it "works with the getting started guide" do
    Hatchet::Runner.new("java-getting-started").tap do |app|
      app.deploy do
        #deploy works
      end
    end
  end
end
