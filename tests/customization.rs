use rusty_hatchet::HerokuStack::Heroku24;
use rusty_hatchet::{BuildConfig, TestRunner, assert_contains, assert_not_contains};

#[test]
fn maven_custom_goals() {
    TestRunner::default().build(
        BuildConfig::new(Heroku24, "test/spec/fixtures/repos/simple-http-service")
            .env("MAVEN_CUSTOM_GOALS", "site"),
        |context| {
            assert_contains!(context.build_output, "./mvnw -DskipTests site");
            assert_contains!(
                context.build_output,
                "[INFO] --- maven-site-plugin:3.7.1:site (default-site) @ simple-http-service ---"
            );
        },
    );
}

#[test]
fn maven_custom_opts() {
    TestRunner::default().build(
        BuildConfig::new(Heroku24, "test/spec/fixtures/repos/simple-http-service")
            .env("MAVEN_CUSTOM_OPTS", "-X"),
        |context| {
            assert_contains!(
                context.build_output,
                "./mvnw -X clean dependency:list install"
            );

            assert_contains!(context.build_output, "[DEBUG] -- end configuration --");

            // -DskipTests is part of the default Maven options. We expect it to be overridden by MAVEN_CUSTOM_OPTS and
            // therefore expect Maven to run tests.
            assert_contains!(
                context.build_output,
                "[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0"
            );
        },
    );
}
