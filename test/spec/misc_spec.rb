# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Maven buildpack' do
  it 'can build an app, even when the Maven wrapper is not executable' do
    app = Hatchet::Runner.new('simple-http-service')

    app.before_deploy do
      `chmod -x mvnw`
    end

    app.deploy do
      expect(app.output).to include('[INFO] BUILD SUCCESS')
    end
  end

  it 'creates a dependency list in the target directory' do
    app = Hatchet::Runner.new('simple-http-service')

    app.deploy do
      expect(app.run('cat target/mvn-dependency-list.log')).to eq(<<~OUTPUT)
        
        The following files have been resolved:
           io.undertow:undertow-core:jar:2.3.17.Final:compile
           org.jboss.logging:jboss-logging:jar:3.4.3.Final:compile
           org.jboss.xnio:xnio-api:jar:3.8.16.Final:compile
           org.wildfly.common:wildfly-common:jar:1.5.4.Final:compile
           org.wildfly.client:wildfly-client-config:jar:1.0.1.Final:compile
           org.jboss.xnio:xnio-nio:jar:3.8.16.Final:runtime
           org.jboss.threads:jboss-threads:jar:3.5.0.Final:compile
           com.google.guava:guava:jar:32.0.0-jre:compile
           com.google.guava:failureaccess:jar:1.0.1:compile
           com.google.guava:listenablefuture:jar:9999.0-empty-to-avoid-conflict-with-guava:compile
           com.google.code.findbugs:jsr305:jar:3.0.2:compile
           org.checkerframework:checker-qual:jar:3.33.0:compile
           com.google.errorprone:error_prone_annotations:jar:2.18.0:compile
           com.google.j2objc:j2objc-annotations:jar:2.8:compile
           junit:junit:jar:4.13.1:test
           org.hamcrest:hamcrest-core:jar:1.3:test
        
      OUTPUT
    end
  end

  it 'does not log internal arguments to Maven' do
    app = Hatchet::Runner.new('simple-http-service')

    app.deploy do
      expect(app.output).not_to include('-Dmaven.repo.local=')
      expect(app.output).not_to include('-Duser.home=')
      expect(app.output).not_to include('-DoutputFile=target/mvn-dependency-list.log')
    end
  end

  it 'fails with a descriptive error message on a failed build' do
    app = Hatchet::Runner.new('app-with-compile-error', allow_failure: true)
    app.deploy do
      expect(clean_output(app.output)).to match(Regexp.new(<<~REGEX, Regexp::MULTILINE))
        remote:        \\[INFO\\] ------------------------------------------------------------------------
        remote:        \\[INFO\\] BUILD FAILURE
        remote:        \\[INFO\\] ------------------------------------------------------------------------
        remote:        \\[INFO\\] Total time:  [0-9\\.]+ s
        remote:        \\[INFO\\] Finished at: [^ ]+
        remote:        \\[INFO\\] ------------------------------------------------------------------------
        remote:        \\[ERROR\\] Failed to execute goal org.apache.maven.plugins:maven-compiler-plugin:3.11.0:compile \\(default-compile\\) on project app-with-compile-error: Compilation failure
        remote:        \\[ERROR\\] /tmp/build_[^ ]+/src/main/java/com/heroku/App.java:\\[5,28\\] ';' expected
        remote:        \\[ERROR\\] -> \\[Help 1\\]
        remote:        \\[ERROR\\] 
        remote:        \\[ERROR\\] To see the full stack trace of the errors, re-run Maven with the -e switch.
        remote:        \\[ERROR\\] Re-run Maven using the -X switch to enable full debug logging.
        remote:        \\[ERROR\\] 
        remote:        \\[ERROR\\] For more information about the errors and possible solutions, please read the following articles:
        remote:        \\[ERROR\\] \\[Help 1\\] http://cwiki.apache.org/confluence/display/MAVEN/MojoFailureException
        remote: 
        remote:  !     Error: Maven build failed.
        remote:  !     
        remote:  !     An error occurred during the Maven build process. This usually
        remote:  !     indicates an issue with your application's dependencies, configuration,
        remote:  !     or source code.
        remote:  !     
        remote:  !     First, check the build output above for specific error messages
        remote:  !     from Maven that might indicate what went wrong. Common issues include:
        remote:  !     
        remote:  !     - Missing or incompatible dependencies in your POM
        remote:  !     - Compilation errors in your application source code
        remote:  !     - Test failures \\(if tests are enabled during the build\\)
        remote:  !     - Invalid Maven configuration or settings
        remote:  !     - Using an incompatible OpenJDK version for your project
        remote:  !     
        remote:  !     If you're unable to determine the cause from the Maven output,
        remote:  !     try building your application locally with the same Maven command
        remote:  !     to reproduce and debug the issue.
        remote: 
        remote:  !     Push rejected, failed to compile Java app.
      REGEX
    end
  end
end
