use rusty_hatchet;
use rusty_hatchet::{assert_contains, BuildConfig, TestRunner};
use rusty_hatchet::HerokuStack::Heroku24;

#[test]
fn sprint_boot_automatic_process_type() {
    TestRunner::default().build(BuildConfig::new(Heroku24, "test/spec/fixtures/repos/buildpack-java-spring-boot-test"), |context| {
        assert_eq!(context.http_request("/").unwrap(), "Hello from Spring Boot!");
    });
}
