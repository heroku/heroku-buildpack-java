# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Java buildpack detection' do
  it 'shows helpful error message when no Java project files are found' do
    app = Hatchet::Runner.new('non-java-app', allow_failure: true)
    app.deploy do
      expect(clean_output(app.output)).to include(<<~OUTPUT)
        remote:  !     Error: Your app is configured to use the Java buildpack,
        remote:  !     but we couldn't find any supported Java project files.
        remote:  !     
        remote:  !     The Java buildpack only supports Maven projects. It requires a 'pom.xml'
        remote:  !     file or other supported POM format in the root directory of your source code.
        remote:  !     
        remote:  !     Supported POM formats: pom.xml, pom.atom, pom.clj, pom.groovy,
        remote:  !     pom.rb, pom.scala, pom.yaml, pom.yml
        remote:  !     
        remote:  !     IMPORTANT: If your Java project uses a different build tool:
        remote:  !     - For Gradle projects, use the heroku/gradle buildpack instead
        remote:  !     - For sbt projects (including Play! Framework), use the heroku/scala buildpack instead
        remote:  !     
        remote:  !     Currently the root directory of your app contains:
        remote:  !     
        remote:  !     README.md
        remote:  !     
        remote:  !     If your app already has a POM file, check that it:
        remote:  !     
        remote:  !     1. Is in the top level directory (not a subdirectory).
        remote:  !     2. Has the correct spelling (the filenames are case-sensitive).
        remote:  !     3. Isn't listed in '.gitignore' or '.slugignore'.
        remote:  !     4. Has been added to the Git repository using 'git add --all'
        remote:  !        and then committed using 'git commit'.
        remote:  !     
        remote:  !     For help with using Java on Heroku, see:
        remote:  !     https://devcenter.heroku.com/articles/java-support
      OUTPUT
    end
  end
end