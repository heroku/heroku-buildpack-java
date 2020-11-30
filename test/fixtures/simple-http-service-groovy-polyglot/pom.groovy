project {
  modelVersion '4.0.0'
  groupId 'com.heroku'
  artifactId 'simple-http-service'
  version '1.0-SNAPSHOT'
  name 'simple-http-service'
  url 'http://www.example.com'
  properties {
    'maven.compiler.target' '1.8'
    'maven.compiler.source' '1.8'
    'project.build.sourceEncoding' 'UTF-8'
  }
  dependencies {
    dependency {
      groupId 'io.undertow'
      artifactId 'undertow-core'
      version '2.1.1.Final'
    }
    dependency {
      groupId 'com.google.guava'
      artifactId 'guava'
      version '30.0-jre'
    }
    dependency {
      groupId 'junit'
      artifactId 'junit'
      version '4.13.1'
      scope 'test'
    }
  }
  build {
    pluginManagement {
      plugins {
        plugin {
          artifactId 'maven-clean-plugin'
          version '3.1.0'
        }
        plugin {
          artifactId 'maven-resources-plugin'
          version '3.0.2'
        }
        plugin {
          artifactId 'maven-compiler-plugin'
          version '3.8.0'
        }
        plugin {
          artifactId 'maven-surefire-plugin'
          version '2.22.1'
        }
        plugin {
          artifactId 'maven-jar-plugin'
          version '3.0.2'
        }
        plugin {
          artifactId 'maven-install-plugin'
          version '2.5.2'
        }
        plugin {
          artifactId 'maven-deploy-plugin'
          version '2.8.2'
        }
        plugin {
          artifactId 'maven-site-plugin'
          version '3.7.1'
        }
        plugin {
          artifactId 'maven-project-info-reports-plugin'
          version '3.0.0'
        }
      }
    }
    plugins {
      plugin {
        groupId 'com.github.ekryd.echo-maven-plugin'
        artifactId 'echo-maven-plugin'
        version '1.2.0'
        executions {
          execution {
            phase 'package'
            goals {
              goal 'echo'
            }
            configuration {
              message '''${line.separator}
[BUILDPACK INTEGRATION TEST - MAVEN VERSION] ${maven.version}
[BUILDPACK INTEGRATION TEST - SETTINGS TEST VALUE] ${heroku.maven.settings-test.value}
[BUILDPACK INTEGRATION TEST - JDBC_DATABASE_URL] ${env.JDBC_DATABASE_URL}
[BUILDPACK INTEGRATION TEST - JDBC_DATABASE_USERNAME] ${env.JDBC_DATABASE_USERNAME}
[BUILDPACK INTEGRATION TEST - JDBC_DATABASE_PASSWORD] ${env.JDBC_DATABASE_PASSWORD}'''
            }
          }
        }
      }
      plugin {
        artifactId 'maven-dependency-plugin'
        version '3.0.1'
        executions {
          execution {
            id 'copy-dependencies'
            phase 'package'
            goals {
              goal 'copy-dependencies'
            }
          }
        }
      }
    }
  }
}
