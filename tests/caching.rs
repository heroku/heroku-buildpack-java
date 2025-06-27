use rusty_hatchet::{assert_contains, assert_not_contains, BuildConfig, TestRunner};
use rusty_hatchet::HerokuStack::Heroku24;

#[test]
fn sprint_boot_automatic_process_type() {
    let config = BuildConfig::new(Heroku24, "test/spec/fixtures/repos/simple-http-service");

    TestRunner::default().build(config.clone(), |context| {
        assert_contains!(context.build_output, "Downloading from central");

        context.rebuild(config, |context| {
            assert_not_contains!(context.build_output, "Downloading from central");
        });
    });
}
