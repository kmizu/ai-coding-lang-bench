import org.gradle.api.tasks.SourceSetContainer

plugins {
  java
  application
}

group = "bench"
version = "0.1.0"

java {
  toolchain {
    languageVersion = JavaLanguageVersion.of(25)
  }
}

application {
  mainClass = "minigit.Main"
}

tasks.register("writeRuntimeClasspath") {
  doLast {
    val sourceSets = project.extensions.getByType(SourceSetContainer::class.java)
    val outFile = layout.buildDirectory.file("runtime-classpath.txt").get().asFile
    outFile.parentFile.mkdirs()
    outFile.writeText(sourceSets.getByName("main").runtimeClasspath.asPath + System.lineSeparator())
  }
}
