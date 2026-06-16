pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
}

rootProject.name = "nexus_media_downloader"

include(":app")
project(":app").projectDir = file("android/app")

// Manually include Flutter plugins because the loader might be looking in the wrong place
val pluginsFile = file(".flutter-plugins-dependencies")
if (pluginsFile.exists()) {
    val json = pluginsFile.readText()
    val androidPluginsRegex = "\"name\":\"([^\"]+)\",\"path\":\"([^\"]+)\"[^}]*\"native_build\":true".toRegex()
    androidPluginsRegex.findAll(json).forEach { match ->
        val name = match.groups[1]?.value
        val path = match.groups[2]?.value?.replace("\\\\", "/")
        if (name != null && path != null) {
            val projectPath = ":$name"
            include(projectPath)
            project(projectPath).projectDir = file("${path}android")
        }
    }
}
