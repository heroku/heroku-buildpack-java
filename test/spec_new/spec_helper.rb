require 'rspec/core'
require 'rspec/retry'
require 'hatchet'
require 'java-properties'

DEFAULT_MAVEN_VERSION="3.6.2"
DEFAULT_OPENJDK_VERSION="1.8"

OPENJDK_VERSIONS_UNDER_TEST=%w(1.8 11 13 14)
MAVEN_VERSIONS_UNDER_TEST=%w(3.2.5 3.3.9 3.5.4 3.6.2)

OPENJDK_VERSIONS={
    "1.8" => "1.8.0_262-heroku-b10",
    "11" => "11.0.8+10",
    "13" => "13.0.4+8",
    "14" => "14.0.2+12"
}

MAVEN_COMMIT_HASHES={
    "3.0.1" => "79af12ffffc777406aba8c3c1252097fc6e2d002",
    "3.0.2" => "70ed9a16cfc5a82999361006c4c370d9b47733b3",
    "3.0.3" => "05e19b6bc21ea11b998e2d6baee2fecbe6bddc24",
    "3.0.4" => "3ad2b6794a8293a8ca6c1590708fb5d3fc795c49",
    "3.0.5" => "01de14724cdef164cd33c7c8c2fe155faf9602da",
    "3.1.0" => "893ca28a1da9d5f51ac03827af98bb730128f9f2",
    "3.1.1" => "0728685237757ffbf44136acec0402957f723d9a",
    "3.2.0" => "9f109b60472979a5865e9d93b72db5c0e2c37232",
    "3.2.1" => "ea8b2b07643dbb1b84b6d16e1f08391b666bc1e9",
    "3.2.2" => "45f7c06d68e745d05611f7fd14efb6594181933e",
    "3.2.3" => "33f8c3e1027c3ddde99d3cdebad2656a31e8fdf4",
    "3.2.4" => "ed0e6acb016d0863e6421932820cf269b618dc3f",
    "3.2.5" => "12a6b3acb947671f09b81f49094c53f426d8cea1",
    "3.3.0" => "b37a7d17765a2bc8dfab63b4e739e7198172fe43",
    "3.3.1" => "cab6659f9874fa96462afef40fcf6bc033d58c1c",
    "3.3.2" => "743903acab9308dc4956b44be17a182abd17a8c0",
    "3.3.3" => "7994120775791599e205a5524ec3e0dfe41d4a06",
    "3.3.4" => "df509db95a565e09ee25edd63b5574f58ba3b077",
    "3.3.5" => "2226900a49396ae834b749ff22c126aed89dbf5a",
    "3.3.6" => "72e1aad6861c2052a65753553d92ecc2a6849ce5",
    "3.3.7" => "d48a49b3539e66e073e35cc6a5137a94d16465f2",
    "3.3.8" => "cdd15915eb4b74ccab621e51aff9ada4f455a627",
    "3.3.9" => "bb52d8502b132ec0a5a3f4c09453c07478323dc5",
    "3.5.0" => "ff8f5e7444045639af65f6095c62210b5713f426",
    "3.5.1" => "094e4e31a5af55bb17be87675da41d9aeca062f3",
    "3.5.2" => "138edd61fd100ec658bfa2d307c43b76940a5d7d",
    "3.5.3" => "3383c37e1f9e9b3bc3df5050c29c8aff9f295297",
    "3.5.4" => "1edded0938998edf8bf061f1ceb3cfdeccf443fe",
    "3.6.0" => "97c98ec64a1fdfee7767ce5ffb20918da4f719f3",
    "3.6.1" => "d66c9c0b3152b2e69ee9bac180bb8fcc8e6af555",
    "3.6.2" => "40f52333136460af0dc0d7232c0dc0bcf0d9e117",
    "3.6.3" => "cecedd343002696d0abb50b32b541b8a6ba2883f"
}

RSpec.configure do |config|
  config.full_backtrace = true
  config.verbose_retry = true
end

def set_java_runtime_version(value)
  properties = {}
  properties = JavaProperties.load("system.properties") if File.file?("system.properties")
  properties["java.runtime.version".to_sym] = value
  JavaProperties.write(properties, "system.properties")
end

def set_maven_version(value)
  properties = {}
  properties = JavaProperties.load("system.properties") if File.file?("system.properties")
  properties["maven.version".to_sym] = value

  JavaProperties.write(properties, "system.properties")
end

def expect_maven_build_success(app)
  expect(app.output).to include("[INFO] BUILD SUCCESS")
end

def expect_maven_version(maven_version, app)
  expect(app.output).to include("-----> Installing Maven #{maven_version}")
  expect(app.output).to match(/\[INFO\] Apache Maven #{Regexp.quote(maven_version)} \(#{Regexp.quote(MAVEN_COMMIT_HASHES[maven_version])}; .*?\)/)
end

def expect_openjdk_version(openjdk_version, fixme, app)
  expect(app.output).to include("-----> Installing JDK #{openjdk_version}")

  # TODO: Mapping from major version to concrete?
  expect(app.run("java -version")).to match(/\(build #{Regexp.quote(fixme)}\)/)

  # TODO: This is weird, why not the full version string?
  expect(app.run("cat .jdk/version")).to match(/^#{Regexp.quote(openjdk_version)}\n*$/)
end

def expect_http_ok(app)
  Excon.get("https://#{app.name}.herokuapp.com", :expects => [200])
end
