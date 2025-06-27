use indoc::indoc;
use rusty_hatchet::HerokuStack::Heroku24;
use rusty_hatchet::{
    BuildConfig, BuildResult, TestRunner, assert_contains, assert_contains_match,
    assert_not_contains,
};
use std::fs::Permissions;
use std::os::unix::fs::PermissionsExt;

#[test]
fn maven_wrapper_without_executable_bit() {
    TestRunner::default().build(
        BuildConfig::new(Heroku24, "test/spec/fixtures/repos/simple-http-service")
            .app_dir_preprocessor(|path| {
                let maven_wrapper = path.join("mvnw");

                let permissions = maven_wrapper.metadata().unwrap().permissions();
                let new_permissions = Permissions::from_mode(permissions.mode() | 0o666);

                std::fs::set_permissions(&maven_wrapper, new_permissions).unwrap();
            }),
        |context| {
            assert_contains!(context.build_output, "[INFO] BUILD SUCCESS");
        },
    );
}

#[test]
fn dependency_list() {
    let config = BuildConfig::new(Heroku24, "test/spec/fixtures/repos/simple-http-service");

    TestRunner::default().build(config.clone(), |context| {
        assert_eq!(
            context
                .run_shell_command("cat target/mvn-dependency-list.log")
                .stdout,
            indoc! {"

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

            "}
        );
    });
}

/*
#[test]
fn descriptive_error_message() {
    TestRunner::default().build(
        BuildConfig::new(Heroku24, "test/spec/fixtures/repos/app-with-compile-error")
            .expected_build_result(BuildResult::Failure),
        |context| {
            assert_contains_match!(context.build_output, indoc! {"
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
                remote:  !     ERROR: Failed to build app with Maven
                remote:        We're sorry this build is failing! If you can't find the issue in application code,
                remote:        please submit a ticket so we can help: https://help.heroku.com/
                remote:
                remote:  !     Push rejected, failed to compile Java app.
            "})
        },
    );
}*/
