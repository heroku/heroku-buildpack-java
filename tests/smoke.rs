use rusty_hatchet::HerokuStack::Heroku24;
use rusty_hatchet::{BuildConfig, TestRunner, assert_contains};

#[test]
fn getting_started_app() {
    TestRunner::default().build(
        BuildConfig::new(
            Heroku24,
            "test/spec/fixtures/repos/github/java-getting-started",
        ),
        |context| {
            assert_contains!(
                context.http_request("/").unwrap(),
                "Java Getting Started on Heroku"
            );
        },
    );
}
