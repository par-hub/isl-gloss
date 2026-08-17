allprojects {
    repositories {
        google()
        mavenCentral()
        flatDir {
            dirs(file("${rootProject.projectDir}/app/libs/aars"), file("${project.projectDir}/libs/aars"))
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

    val configureOptions = {
        val android = project.extensions.findByName("android")
        if (android != null) {
            val getNamespace = try { android.javaClass.getMethod("getNamespace") } catch (e: Exception) { null }
            val setNamespace = try { android.javaClass.getMethod("setNamespace", String::class.java) } catch (e: Exception) { null }
            if (getNamespace != null && setNamespace != null) {
                if (getNamespace.invoke(android) == null) {
                    val fallbackNamespace = "com.example." + project.name.replace("-", "_")
                    setNamespace.invoke(android, fallbackNamespace)
                }
            }
            (android as? com.android.build.gradle.BaseExtension)?.compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }

    if (state.executed) {
        configureOptions()
    } else {
        afterEvaluate {
            configureOptions()
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

