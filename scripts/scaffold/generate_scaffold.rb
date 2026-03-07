#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'optparse'

options = {
  dir: nil,
  toolchain: nil,
}

OptionParser.new do |opts|
  opts.on('--dir DIR') { |v| options[:dir] = v }
  opts.on('--toolchain ID') { |v| options[:toolchain] = v }
end.parse!

abort('--dir is required') unless options[:dir]
abort('--toolchain is required') unless options[:toolchain]

TARGET_DIR = File.expand_path(options[:dir])

def write_file(path, content, executable: false)
  full_path = File.join(TARGET_DIR, path)
  FileUtils.mkdir_p(File.dirname(full_path))
  File.write(full_path, content)
  FileUtils.chmod('+x', full_path) if executable
end

def python_uv
  write_file('pyproject.toml', <<~TOML)
    [project]
    name = "minigit"
    version = "0.1.0"
    requires-python = ">=3.12"
    dependencies = []

    [build-system]
    requires = ["setuptools>=80"]
    build-backend = "setuptools.build_meta"
  TOML

  write_file('minigit', <<~BASH, executable: true)
    #!/usr/bin/env bash
    set -euo pipefail
    exec uv run python src/minigit.py "$@"
  BASH

  write_file('src/minigit.py', <<~PY)
    from __future__ import annotations

    import sys


    def main() -> int:
        print("Not implemented", file=sys.stderr)
        return 1


    if __name__ == "__main__":
        raise SystemExit(main())
  PY
end

def rust_cargo
  write_file('Cargo.toml', <<~TOML)
    [package]
    name = "minigit"
    version = "0.1.0"
    edition = "2024"

    [dependencies]
  TOML

  write_file('build.sh', <<~BASH, executable: true)
    #!/usr/bin/env bash
    set -euo pipefail
    cargo build --quiet
    cp target/debug/minigit minigit
    chmod +x minigit
  BASH

  write_file('src/main.rs', <<~RUST)
    fn main() {
        eprintln!("Not implemented");
        std::process::exit(1);
    }
  RUST
end

def typescript_pnpm
  write_file('package.json', <<~JSON)
    {
      "name": "minigit",
      "version": "0.1.0",
      "private": true,
      "type": "module",
      "scripts": {
        "build": "tsc --pretty false"
      },
      "devDependencies": {
        "typescript": "5.9.2"
      }
    }
  JSON

  write_file('tsconfig.json', <<~JSON)
    {
      "compilerOptions": {
        "target": "ES2024",
        "module": "NodeNext",
        "moduleResolution": "NodeNext",
        "strict": true,
        "outDir": "dist",
        "rootDir": "src",
        "noEmitOnError": true
      },
      "include": ["src/**/*.ts"]
    }
  JSON

  write_file('build.sh', <<~BASH, executable: true)
    #!/usr/bin/env bash
    set -euo pipefail
    pnpm exec tsc --pretty false
    cat > minigit <<'EOF'
    #!/usr/bin/env bash
    set -euo pipefail
    exec node dist/minigit.js "$@"
    EOF
    chmod +x minigit
  BASH

  write_file('src/minigit.ts', <<~TS)
    function main(): number {
      console.error("Not implemented");
      return 1;
    }

    process.exit(main());
  TS
end

def typescript_bun
  write_file('package.json', <<~JSON)
    {
      "name": "minigit",
      "version": "0.1.0",
      "private": true
    }
  JSON

  write_file('build.sh', <<~BASH, executable: true)
    #!/usr/bin/env bash
    set -euo pipefail
    cat > minigit <<'EOF'
    #!/usr/bin/env bash
    set -euo pipefail
    exec bun run src/minigit.ts "$@"
    EOF
    chmod +x minigit
  BASH

  write_file('src/minigit.ts', <<~TS)
    function main(): number {
      console.error("Not implemented");
      return 1;
    }

    process.exit(main());
  TS
end

def go_go
  write_file('go.mod', <<~MOD)
    module example.com/minigit

    go 1.26.0
  MOD

  write_file('build.sh', <<~BASH, executable: true)
    #!/usr/bin/env bash
    set -euo pipefail
    go build -o minigit ./cmd/minigit
  BASH

  write_file('cmd/minigit/main.go', <<~GO)
    package main

    import (
      "fmt"
      "os"
    )

    func main() {
      fmt.Fprintln(os.Stderr, "Not implemented")
      os.Exit(1)
    }
  GO
end

def java_maven
  write_file('pom.xml', <<~XML)
    <project xmlns="http://maven.apache.org/POM/4.0.0"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
      <modelVersion>4.0.0</modelVersion>
      <groupId>bench</groupId>
      <artifactId>minigit</artifactId>
      <version>0.1.0</version>
      <properties>
        <maven.compiler.release>25</maven.compiler.release>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
      </properties>
    </project>
  XML

  write_file('build.sh', <<~BASH, executable: true)
    #!/usr/bin/env bash
    set -euo pipefail
    mvn -q -DskipTests compile
    cat > minigit <<'EOF'
    #!/usr/bin/env bash
    set -euo pipefail
    exec java -cp target/classes minigit.Main "$@"
    EOF
    chmod +x minigit
  BASH

  write_file('src/main/java/minigit/Main.java', <<~JAVA)
    package minigit;

    public final class Main {
      private Main() {}

      public static void main(String[] args) {
        System.err.println("Not implemented");
        System.exit(1);
      }
    }
  JAVA
end

def ruby_bundler
  write_file('Gemfile', <<~RUBY)
    source "https://rubygems.org"
  RUBY

  write_file('minigit', <<~BASH, executable: true)
    #!/usr/bin/env bash
    set -euo pipefail
    exec bundle exec ruby exe/minigit "$@"
  BASH

  write_file('exe/minigit', <<~RUBY, executable: true)
    #!/usr/bin/env ruby
    # frozen_string_literal: true

    $LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
    require "minigit"

    exit Minigit.main(ARGV)
  RUBY

  write_file('lib/minigit.rb', <<~RUBY)
    # frozen_string_literal: true

    module Minigit
      module_function

      def main(_argv)
        warn "Not implemented"
        1
      end
    end
  RUBY
end

def scala_sbt
  write_file('build.sbt', <<~SCALA)
    ThisBuild / scalaVersion := "3.3.7"
    ThisBuild / version := "0.1.0"

    lazy val writeRuntimeClasspath = taskKey[File]("Write the runtime classpath for the benchmark launcher.")

    lazy val root = (project in file("."))
      .settings(
        name := "minigit",
        Compile / mainClass := Some("minigit.Main"),
        writeRuntimeClasspath := {
          val out = target.value / "runtime-classpath.txt"
          val cp = (Compile / fullClasspath).value.files.map(_.getAbsolutePath).mkString(java.io.File.pathSeparator)
          IO.write(out, cp + System.lineSeparator())
          out
        }
      )
  SCALA

  write_file('project/build.properties', <<~TXT)
    sbt.version=1.12.5
  TXT

  write_file('build.sh', <<~BASH, executable: true)
    #!/usr/bin/env bash
    set -euo pipefail
    sbt --batch compile writeRuntimeClasspath
    cat > minigit <<'EOF'
    #!/usr/bin/env bash
    set -euo pipefail
    CP="$(cat target/runtime-classpath.txt)"
    exec java -cp "$CP" minigit.Main "$@"
    EOF
    chmod +x minigit
  BASH

  write_file('src/main/scala/minigit/Main.scala', <<~SCALA)
    package minigit

    object Main {
      def main(args: Array[String]): Unit = {
        System.err.println("Not implemented")
        sys.exit(1)
      }
    }
  SCALA
end

def scala_sbt_server
  write_file('build.sbt', <<~SCALA)
    ThisBuild / scalaVersion := "3.3.7"
    ThisBuild / version := "0.1.0"

    // Keep the sbt server alive throughout the benchmark session (no idle timeout)
    Global / serverIdleTimeout := None

    lazy val writeRuntimeClasspath = taskKey[File]("Write the runtime classpath for the benchmark launcher.")

    lazy val root = (project in file("."))
      .settings(
        name := "minigit",
        Compile / mainClass := Some("minigit.Main"),
        writeRuntimeClasspath := {
          val out = target.value / "runtime-classpath.txt"
          val cp = (Compile / fullClasspath).value.files.map(_.getAbsolutePath).mkString(java.io.File.pathSeparator)
          IO.write(out, cp + System.lineSeparator())
          out
        }
      )
  SCALA

  write_file('project/build.properties', <<~TXT)
    sbt.version=1.12.5
  TXT

  write_file('build.sh', <<~BASH, executable: true)
    #!/usr/bin/env bash
    set -euo pipefail
    sbt compile writeRuntimeClasspath
    cat > minigit <<'EOF'
    #!/usr/bin/env bash
    set -euo pipefail
    CP="$(cat target/runtime-classpath.txt)"
    exec java -cp "$CP" minigit.Main "$@"
    EOF
    chmod +x minigit
  BASH

  write_file('src/main/scala/minigit/Main.scala', <<~SCALA)
    package minigit

    object Main {
      def main(args: Array[String]): Unit = {
        System.err.println("Not implemented")
        sys.exit(1)
      }
    }
  SCALA
end

def scala_scala_cli
  write_file('build.sh', <<~BASH, executable: true)
    #!/usr/bin/env bash
    set -euo pipefail
    cat > minigit <<'EOF'
    #!/usr/bin/env bash
    set -euo pipefail
    exec scala-cli run src/main/scala/minigit/Main.scala -- "$@"
    EOF
    chmod +x minigit
  BASH

  write_file('src/main/scala/minigit/Main.scala', <<~SCALA)
    //> using scala 3.3.7

    package minigit

    object Main:
      def main(args: Array[String]): Unit =
        System.err.println("Not implemented")
        sys.exit(1)
  SCALA
end

def kotlin_gradle
  write_file('build.gradle.kts', <<~KOTLIN)
    import org.gradle.api.tasks.SourceSetContainer

    plugins {
      kotlin("jvm") version "2.3.10"
      application
    }

    group = "bench"
    version = "0.1.0"

    repositories {
      mavenCentral()
    }

    kotlin {
      jvmToolchain(25)
    }

    application {
      mainClass = "minigit.MainKt"
    }

    tasks.register("writeRuntimeClasspath") {
      doLast {
        val sourceSets = project.extensions.getByType(SourceSetContainer::class.java)
        val outFile = layout.buildDirectory.file("runtime-classpath.txt").get().asFile
        outFile.parentFile.mkdirs()
        outFile.writeText(sourceSets.getByName("main").runtimeClasspath.asPath + System.lineSeparator())
      }
    }
  KOTLIN

  write_file('settings.gradle.kts', <<~KOTLIN)
    rootProject.name = "minigit"
  KOTLIN

  write_file('build.sh', <<~BASH, executable: true)
    #!/usr/bin/env bash
    set -euo pipefail
    gradle -q classes writeRuntimeClasspath
    cat > minigit <<'EOF'
    #!/usr/bin/env bash
    set -euo pipefail
    CP="$(cat build/runtime-classpath.txt)"
    exec java -cp "$CP" minigit.MainKt "$@"
    EOF
    chmod +x minigit
  BASH

  write_file('src/main/kotlin/minigit/Main.kt', <<~KOTLIN)
    package minigit

    fun main(args: Array<String>) {
        System.err.println("Not implemented")
        kotlin.system.exitProcess(1)
    }
  KOTLIN
end

def kotlin_maven
  write_file('pom.xml', <<~XML)
    <project xmlns="http://maven.apache.org/POM/4.0.0"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
      <modelVersion>4.0.0</modelVersion>
      <groupId>bench</groupId>
      <artifactId>minigit</artifactId>
      <version>0.1.0</version>
      <properties>
        <kotlin.version>2.3.10</kotlin.version>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.release>25</maven.compiler.release>
      </properties>
      <dependencies>
        <dependency>
          <groupId>org.jetbrains.kotlin</groupId>
          <artifactId>kotlin-stdlib</artifactId>
          <version>${kotlin.version}</version>
        </dependency>
      </dependencies>
      <build>
        <sourceDirectory>src/main/kotlin</sourceDirectory>
        <plugins>
          <plugin>
            <groupId>org.jetbrains.kotlin</groupId>
            <artifactId>kotlin-maven-plugin</artifactId>
            <version>${kotlin.version}</version>
            <executions>
              <execution>
                <id>compile</id>
                <phase>compile</phase>
                <goals>
                  <goal>compile</goal>
                </goals>
              </execution>
            </executions>
            <configuration>
              <jvmTarget>25</jvmTarget>
            </configuration>
          </plugin>
        </plugins>
      </build>
    </project>
  XML

  write_file('build.sh', <<~BASH, executable: true)
    #!/usr/bin/env bash
    set -euo pipefail
    mvn -q -DskipTests compile
    cat > minigit <<'EOF'
    #!/usr/bin/env bash
    set -euo pipefail
    exec java -cp target/classes minigit.MainKt "$@"
    EOF
    chmod +x minigit
  BASH

  write_file('src/main/kotlin/minigit/Main.kt', <<~KOTLIN)
    package minigit

    fun main(args: Array<String>) {
        System.err.println("Not implemented")
        kotlin.system.exitProcess(1)
    }
  KOTLIN
end

def ocaml_dune
  write_file('dune-project', <<~TXT)
    (lang dune 3.21)
    (name minigit)
  TXT

  write_file('bin/dune', <<~TXT)
    (executable
      (name main))
  TXT

  write_file('build.sh', <<~BASH, executable: true)
    #!/usr/bin/env bash
    set -euo pipefail
    dune build ./bin/main.exe
    cp _build/default/bin/main.exe minigit
    chmod +x minigit
  BASH

  write_file('bin/main.ml', <<~OCAML)
    let () =
      prerr_endline "Not implemented";
      exit 1
  OCAML
end

def haskell_cabal
  write_file('minigit.cabal', <<~CABAL)
    cabal-version: 3.8
    name: minigit
    version: 0.1.0.0
    build-type: Simple

    executable minigit
      main-is: Main.hs
      hs-source-dirs: app
      default-language: Haskell2010
      ghc-options: -Wall
  CABAL

  write_file('cabal.project', <<~TXT)
    packages: .
  TXT

  write_file('build.sh', <<~BASH, executable: true)
    #!/usr/bin/env bash
    set -euo pipefail
    cabal build exe:minigit >/dev/null
    BIN="$(cabal list-bin exe:minigit)"
    cp "$BIN" minigit
    chmod +x minigit
  BASH

  write_file('app/Main.hs', <<~HS)
    module Main where

    import System.Exit (exitFailure)
    import System.IO (hPutStrLn, stderr)

    main :: IO ()
    main = do
      hPutStrLn stderr "Not implemented"
      exitFailure
  HS
end

def scheme_guile
  write_file('minigit', <<~BASH, executable: true)
    #!/usr/bin/env bash
    set -euo pipefail
    exec guile -s src/minigit.scm -- "$@"
  BASH

  write_file('src/minigit.scm', <<~SCM)
    (display "Not implemented\n" (current-error-port))
    (exit 1)
  SCM
end

def perl_raw
  write_file('minigit', <<~PERL, executable: true)
    #!/usr/bin/env perl
    use strict;
    use warnings;

    print STDERR "Not implemented\n";
    exit 1;
  PERL
end

def lua_raw
  write_file('minigit', <<~LUA, executable: true)
    #!/usr/bin/env lua
    io.stderr:write("Not implemented\n")
    os.exit(1)
  LUA
end

FileUtils.mkdir_p(TARGET_DIR)

case options[:toolchain]
when 'python-uv' then python_uv
when 'rust-cargo' then rust_cargo
when 'typescript-pnpm' then typescript_pnpm
when 'typescript-bun' then typescript_bun
when 'go-go' then go_go
when 'java-maven' then java_maven
when 'ruby-bundler' then ruby_bundler
when 'scala-sbt' then scala_sbt
when 'scala-sbt-server' then scala_sbt_server
when 'scala-scala-cli' then scala_scala_cli
when 'kotlin-gradle' then kotlin_gradle
when 'kotlin-maven' then kotlin_maven
when 'ocaml-dune' then ocaml_dune
when 'haskell-cabal' then haskell_cabal
when 'scheme-guile' then scheme_guile
when 'perl-raw' then perl_raw
when 'lua-raw' then lua_raw
else
  abort("Unsupported toolchain: #{options[:toolchain]}")
end
