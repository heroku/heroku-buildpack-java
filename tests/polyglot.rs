use rusty_hatchet::HerokuStack::Heroku24;
use rusty_hatchet::{BuildConfig, TestRunner, assert_contains, assert_not_contains};

#[test]
fn non_xml_pom() {
    let config = BuildConfig::new(
        Heroku24,
        "test/spec/fixtures/repos/simple-http-service-groovy-polyglot",
    );

    TestRunner::default().build(config.clone(), |context| {
        assert_contains!(context.build_output, "[INFO] BUILD SUCCESS");
    });
}
