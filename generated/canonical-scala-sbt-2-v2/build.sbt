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
