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
