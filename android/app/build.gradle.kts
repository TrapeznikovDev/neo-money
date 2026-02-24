plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "neomoney.app.neomoney.neomoney"
    // ↑↑ FIX: required by flutter_secure_storage (compileSdk 36)
    compileSdk = 36

    // ↑↑ FIX: required by multiple plugins (NDK 27.0.12077973)
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "soyamarket.app.soyamarket_flutter"

        // ↑↑ FIX: manifest merger error from flutter_secure_storage (minSdk >= 24)
        minSdk = 24

        // ↑↑ keep in sync with compileSdk for modern plugins
        targetSdk = 36

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
