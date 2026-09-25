import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val signingPropertiesFile = rootProject.file("key.properties")
val signingProperties = Properties()
if (signingPropertiesFile.exists()) {
    signingPropertiesFile.inputStream().use(signingProperties::load)
}

val releaseSigningKeys = listOf(
    "storeFile",
    "storePassword",
    "keyAlias",
    "keyPassword",
)
val missingReleaseSigningKeys = releaseSigningKeys.filter { key ->
    signingProperties.getProperty(key)?.trim().isNullOrEmpty()
}
val releaseBuildRequested = gradle.startParameter.taskNames.any { task ->
    task.contains("release", ignoreCase = true)
}

if (releaseBuildRequested && missingReleaseSigningKeys.isNotEmpty()) {
    throw GradleException(
        "Release signing is not configured. Create android/key.properties " +
            "with: ${missingReleaseSigningKeys.joinToString()}",
    )
}

fun releaseSigningProperty(name: String): String =
    signingProperties.getProperty(name).trim()

android {
    namespace = "com.ink.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.ink.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (missingReleaseSigningKeys.isEmpty()) {
            create("release") {
                storeFile = file(releaseSigningProperty("storeFile"))
                storePassword = releaseSigningProperty("storePassword")
                keyAlias = releaseSigningProperty("keyAlias")
                keyPassword = releaseSigningProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (missingReleaseSigningKeys.isEmpty()) {
                signingConfigs.getByName("release")
            } else {
                null
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
