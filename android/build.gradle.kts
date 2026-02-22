plugins {
    id("com.google.gms.google-services") version "4.4.1" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }

    // This block correctly patches dependencies that are missing a namespace.
    afterEvaluate {
        if (plugins.hasPlugin("com.android.library")) {
            val android = extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
            if (android != null && android.namespace == null) {
                val sanitizedName = name.replace("-", "_")
                android.namespace = "com.lumixo.generated.$sanitizedName"
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
