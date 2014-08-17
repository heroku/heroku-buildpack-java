require_relative 'spec_helper'

describe "Java" do
  it "should not install settings.xml" do
    Hatchet::Runner.new("java-servlets-sample").deploy do |app|
      expect(app.output).to match("Installing OpenJDK 1.7")
      expect(app.output).to match("Installing Maven 3.0.3")
      expect(app.output).not_to match("Installing settings.xml")
    end
  end
end
