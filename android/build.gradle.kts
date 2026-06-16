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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
