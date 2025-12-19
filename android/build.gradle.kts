allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    afterEvaluate {
        if (project.name == "on_audio_query_android") {
            val android = project.extensions.findByName("android")
            if (android != null) {
                try {
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    setNamespace.invoke(android, "com.lucasjosino.on_audio_query")
                } catch (e: Exception) {
                }
            }
        }
        
        // Force JVM target 17 for consistency across all subprojects
        if (project.hasProperty("android")) {
             val android = project.extensions.getByName("android")
            try {
                val compileOptions = android.javaClass.getMethod("getCompileOptions").invoke(android)
                compileOptions.javaClass.getMethod("setSourceCompatibility", JavaVersion::class.java).invoke(compileOptions, JavaVersion.VERSION_17)
                compileOptions.javaClass.getMethod("setTargetCompatibility", JavaVersion::class.java).invoke(compileOptions, JavaVersion.VERSION_17)
            } catch (e: Exception) {}
        }

        // Fix dependency conflict for AGP 8.2.1
        configurations.all {
            resolutionStrategy {
                force("androidx.browser:browser:1.8.0")
                force("androidx.core:core-ktx:1.13.1")
                force("androidx.core:core:1.13.1")
            }
        }
    }
}

// Global task configuration to force JVM target
allprojects {
    tasks.configureEach {
        if (this.javaClass.name.contains("KotlinCompile")) {
            try {
                val getKotlinOptions = this.javaClass.getMethod("getKotlinOptions")
                val kotlinOptions = getKotlinOptions.invoke(this)
                val setJvmTarget = kotlinOptions.javaClass.getMethod("setJvmTarget", String::class.java)
                setJvmTarget.invoke(kotlinOptions, "17")
            } catch (e: Exception) {}
        }
    }
}


tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}