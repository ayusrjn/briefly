import org.gradle.api.file.Directory
import org.gradle.api.tasks.Delete
import org.gradle.api.tasks.compile.JavaCompile
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

allprojects {
    repositories {
        google()
        mavenCentral()
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
}

subprojects {
    project.evaluationDependsOn(":app")
}

// 🔽 IMPORTANT: force ALL modules (including :receive_sharing_intent) to use Java 1.8 and Kotlin JVM 1.8

subprojects {
    // Java tasks
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = "1.8"
        targetCompatibility = "1.8"
    }

    // Kotlin tasks (Android modules use KotlinCompile)
    tasks.withType<KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_1_8)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
