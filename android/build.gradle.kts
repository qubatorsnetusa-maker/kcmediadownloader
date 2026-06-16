// Top-level build file where you can add configuration options common to all sub-projects/modules.
import org.gradle.api.tasks.Delete

allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://storage.googleapis.com/download.flutter.io")
        }
    }
}

// Ensure the build directory is at the project root so Flutter CLI can find artifacts
rootProject.layout.buildDirectory.set(file("${project.projectDir}/../build"))

subprojects {
    project.layout.buildDirectory.set(file("${rootProject.layout.buildDirectory.get()}/${project.name}"))
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
