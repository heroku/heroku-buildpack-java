use indoc::formatdoc;
use rusty_hatchet::HerokuStack::Heroku24;
use rusty_hatchet::{BuildConfig, TestRunner, assert_contains, assert_not_contains};
use std::fs::OpenOptions;
use std::path::Path;

#[test]
fn use_maven_wrapper() {
    TestRunner::default().build(
        BuildConfig::new(
            Heroku24,
            "test/spec/fixtures/repos/github/simple-http-service",
        ),
        |context| {
            assert_contains!(context.build_output, "$ ./mvnw");
            assert_contains!(context.build_output, &format!("[BUILDPACK INTEGRATION TEST - MAVEN VERSION] {SIMPLE_HTTP_SERVICE_MAVEN_WRAPPER_VERSION}"));
        },
    );
}

#[test]
fn maven_wrapper_prioritization() {
    TestRunner::default().build(
        BuildConfig::new(Heroku24, "test/spec/fixtures/repos/simple-http-service")
            .app_dir_preprocessor(|path| {
                set_java_property(
                    path.join("system.properties"),
                    "maven.version",
                    DEFAULT_MAVEN_VERSION,
                );
            }),
        |context| {
            assert_not_contains!(context.build_output, "$ ./mvnw");

            assert_contains!(
                context.build_output,
                &format!("remote: -----> Installing Maven {DEFAULT_MAVEN_VERSION}... done")
            );

            assert_contains!(
                context.build_output,
                &format!("[BUILDPACK INTEGRATION TEST - MAVEN VERSION] {DEFAULT_MAVEN_VERSION}")
            );
        },
    );
}

#[test]
fn maven_wrapper_prioritization_with_unknown_version() {
    TestRunner::default().build(
        BuildConfig::new(
            Heroku24,
            "test/spec/fixtures/repos/simple-http-service",
        )
            .app_dir_preprocessor(|path| {
                set_java_property(path.join("system.properties"), "maven.version", UNKNOWN_MAVEN_VERSION);
            }),
        |context| {
            assert_contains!(
                context.build_output,
                &formatdoc! {"
                    remote: -----> Installing Maven {unknown_version}...
                    remote:  !     ERROR: Error, you have defined an unsupported Maven version in the system.properties file.
                    remote:        The default supported version is {default_version}
                ", unknown_version = UNKNOWN_MAVEN_VERSION, default_version = DEFAULT_MAVEN_VERSION}
            );
        },
    );
}

#[test]
fn install_maven_when_no_wrapper() {
    TestRunner::default().build(
        BuildConfig::new(Heroku24, "test/spec/fixtures/repos/simple-http-service")
            .app_dir_preprocessor(|path| {
                std::fs::remove_file(path.join("mvnw")).unwrap();
            }),
        |context| {
            assert_not_contains!(context.build_output, "$ ./mvnw");
            assert_contains!(
                context.build_output,
                &format!("remote: -----> Installing Maven {DEFAULT_MAVEN_VERSION}... done")
            );
            assert_contains!(
                context.build_output,
                &format!("[BUILDPACK INTEGRATION TEST - MAVEN VERSION] {DEFAULT_MAVEN_VERSION}")
            );
        },
    );
}

#[test]
fn install_maven_unknown_version() {
    TestRunner::default().build(
        BuildConfig::new(Heroku24, "test/spec/fixtures/repos/simple-http-service")
            .app_dir_preprocessor(|path| {
                std::fs::remove_file(path.join("mvnw")).unwrap();
                set_java_property(
                    path.join("system.properties"),
                    "maven.version",
                    UNKNOWN_MAVEN_VERSION,
                );
            }),
        |context| {
            assert_contains!(
                context.build_output,
                &formatdoc! {"
                    remote: -----> Installing Maven {unknown_version}...
                    remote:  !     ERROR: Error, you have defined an unsupported Maven version in the system.properties file.
                    remote:        The default supported version is {default_version}
                ", unknown_version = UNKNOWN_MAVEN_VERSION, default_version = DEFAULT_MAVEN_VERSION}
            );
        },
    );
}

#[test]
fn install_maven_default_version() {
    TestRunner::default().build(
        BuildConfig::new(Heroku24, "test/spec/fixtures/repos/simple-http-service")
            .app_dir_preprocessor(|path| {
                std::fs::remove_file(path.join("mvnw")).unwrap();
            }),
        |context| {
            assert_not_contains!(context.build_output, "$ ./mvnw");
            assert_contains!(
                context.build_output,
                &format!("remote: -----> Installing Maven {DEFAULT_MAVEN_VERSION}... done")
            );
            assert_contains!(
                context.build_output,
                &format!("[BUILDPACK INTEGRATION TEST - MAVEN VERSION] {DEFAULT_MAVEN_VERSION}")
            );
        },
    );
}

#[test]
fn install_maven_configured_version() {
    TestRunner::default().build(
        BuildConfig::new(Heroku24, "test/spec/fixtures/repos/simple-http-service")
            .app_dir_preprocessor(|path| {
                std::fs::remove_file(path.join("mvnw")).unwrap();
                set_java_property(path.join("system.properties"), "maven.version", "3.9.4");
            }),
        |context| {
            assert_not_contains!(context.build_output, "$ ./mvnw");
            assert_contains!(
                context.build_output,
                "remote: -----> Installing Maven 3.9.4... done"
            );
            assert_contains!(
                context.build_output,
                "[BUILDPACK INTEGRATION TEST - MAVEN VERSION] 3.9.4"
            );
        },
    );
}

fn set_java_property(path: impl AsRef<Path>, key: &str, value: &str) {
    let file = OpenOptions::new()
        .read(true)
        .write(true)
        .open(path)
        .unwrap();

    let mut properties = java_properties::read(&file).unwrap();
    properties.insert(String::from(key), String::from(value));
    java_properties::write(&file, &properties).unwrap();
}

const DEFAULT_MAVEN_VERSION: &str = "3.9.4";
const UNKNOWN_MAVEN_VERSION: &str = "1.0.0-unknown-version";
const SIMPLE_HTTP_SERVICE_MAVEN_WRAPPER_VERSION: &str = "3.6.3";
