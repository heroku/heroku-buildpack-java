use indoc::{formatdoc, indoc};
use rusty_hatchet::HerokuStack::Heroku24;
use rusty_hatchet::{BuildConfig, BuildResult, TestRunner, assert_contains, assert_not_contains};
use std::path::Path;

#[test]
fn settings_xml_url() {
    TestRunner::default().build(
        BuildConfig::new(Heroku24, "test/spec/fixtures/repos/simple-http-service")
            .env("MAVEN_SETTINGS_URL", SETTINGS_XML_URL),
        |context| {
            assert_contains!(
                context.build_output,
                &format!(
                    "[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] {SETTINGS_XML_URL_VALUE}"
                )
            );
        },
    );
}

#[test]
fn settings_xml_url_failure() {
    TestRunner::default().build(BuildConfig::new(Heroku24, "test/spec/fixtures/repos/simple-http-service")
                                    .env("MAVEN_SETTINGS_URL", SETTINGS_XML_URL_404)
                                    .expected_build_result(BuildResult::Failure), |context| {
        assert_contains!(
            context.build_output,
            indoc! {"
                remote: -----> Executing Maven
                remote:        $ ./mvnw -DskipTests clean dependency:list install
                remote:        [ERROR] Error executing Maven.
                remote:        [ERROR] 1 problem was encountered while building the effective settings
                remote:        [FATAL] Non-parseable settings /tmp/codon/tmp/cache/.m2/settings.xml: only whitespace content allowed before start tag and not N (position: START_DOCUMENT seen N... @1:1)  @ /tmp/codon/tmp/cache/.m2/settings.xml, line 1, column 1
            "}
        );

        assert_contains!(
            context.build_output,
            indoc! {"
                remote:  !     ERROR: Failed to build app with Maven
                remote:        We're sorry this build is failing! If you can't find the issue in application code,
                remote:        please submit a ticket so we can help: https://help.heroku.com/
            "}
        );

        assert_contains!(context.build_output, "remote:  !     Push rejected, failed to compile Java app.");
    });
}

#[test]
fn settings_xml_path() {
    let settings_xml_filename = "forgreatjustice.xml";
    let settings_xml_test_value = "Take off every 'ZIG'!!";

    TestRunner::default().build(
        BuildConfig::new(Heroku24, "test/spec/fixtures/repos/simple-http-service")
            .env("MAVEN_SETTINGS_PATH", settings_xml_filename)
            .app_dir_preprocessor(move |path| {
                write_settings_xml(&path.join(settings_xml_filename), settings_xml_test_value);
            }),
        |context| {
            assert_contains!(
                context.build_output,
                &format!(
                    "[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] {settings_xml_test_value}"
                )
            );
        },
    );
}

#[test]
fn settings_xml_path_and_url() {
    let settings_xml_filename = "zerowing.xml";
    let settings_xml_test_value = "We get signal.";

    TestRunner::default().build(
        BuildConfig::new(Heroku24, "test/spec/fixtures/repos/simple-http-service")
            .env("MAVEN_SETTINGS_PATH", settings_xml_filename)
            .env("MAVEN_SETTINGS_URL", SETTINGS_XML_URL)
            .app_dir_preprocessor(move |path| {
                write_settings_xml(&path.join(settings_xml_filename), settings_xml_test_value);
            }),
        |context| {
            // MAVEN_SETTINGS_PATH should take precedence
            assert_contains!(
                context.build_output,
                &format!(
                    "[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] {settings_xml_test_value}"
                )
            );
        },
    );
}

#[test]
fn automatic_settings_xml() {
    let settings_xml_filename = "settings.xml";
    let settings_xml_test_value = "Somebody set up us the bomb.";

    TestRunner::default().build(
        BuildConfig::new(Heroku24, "test/spec/fixtures/repos/simple-http-service")
            .app_dir_preprocessor(move |path| {
                write_settings_xml(&path.join(settings_xml_filename), settings_xml_test_value);
            }),
        |context| {
            assert_contains!(
                context.build_output,
                &format!(
                    "[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] {settings_xml_test_value}"
                )
            );
        },
    );
}

#[test]
fn settings_xml_path_and_settings_xml() {
    let settings_xml_filename = "settings.xml";
    let settings_xml_test_value = "Somebody set up us the bomb.";
    let zero_wing_filename = "zerowing.xml";
    let zero_wing_test_value = "How are you gentlemen !!";

    TestRunner::default().build(
        BuildConfig::new(Heroku24, "test/spec/fixtures/repos/simple-http-service")
            .env("MAVEN_SETTINGS_PATH", zero_wing_filename)
            .app_dir_preprocessor(move |path| {
                write_settings_xml(&path.join(settings_xml_filename), settings_xml_test_value);
                write_settings_xml(&path.join(zero_wing_filename), zero_wing_test_value);
            }),
        |context| {
            assert_contains!(
                context.build_output,
                &format!(
                    "[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] {zero_wing_test_value}"
                )
            );
        },
    );
}

#[test]
fn settings_xml_url_and_settings_xml() {
    let settings_xml_filename = "settings.xml";
    let settings_xml_test_value = "Somebody set up us the bomb.";

    TestRunner::default().build(
        BuildConfig::new(Heroku24, "test/spec/fixtures/repos/simple-http-service")
            .env("MAVEN_SETTINGS_URL", SETTINGS_XML_URL)
            .app_dir_preprocessor(move |path| {
                write_settings_xml(&path.join(settings_xml_filename), settings_xml_test_value);
            }),
        |context| {
            assert_contains!(
                context.build_output,
                &format!(
                    "[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] {SETTINGS_XML_URL_VALUE}"
                )
            );
        },
    );
}

fn write_settings_xml(path: &Path, test_value: &str) {
    std::fs::write(
        path,
        formatdoc! {"
            <settings xmlns=\"http://maven.apache.org/SETTINGS/1.0.0\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
                xsi:schemaLocation=\"http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd\">
                <profiles>
                    <profile>
                        <activation>
                            <activeByDefault>true</activeByDefault>
                        </activation>
                        <properties>
                            <heroku.maven.settings-test.value>{test_value}</heroku.maven.settings-test.value>
                        </properties>
                    </profile>
                </profiles>
            </settings>
    ", test_value = test_value},
    ).unwrap();
}

const SETTINGS_XML_URL: &str = "https://gist.githubusercontent.com/Malax/d47323823a3d59249cbb5593c4f1b764/raw/83f196719d2c4d56aec6720964ba7d7c86b71727/download-settings.xml";
const SETTINGS_XML_URL_VALUE: &str = "Main screen turn on.";
const SETTINGS_XML_URL_404: &str = "https://gist.githubusercontent.com/Malax/settings.xml";
