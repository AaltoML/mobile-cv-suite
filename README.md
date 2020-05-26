A Computer Vision resarch library for mobile phones. A collection of Open Source
libraries that are important building blocks required to test new algorithms
on mobile & embedded devices.

## Usage

First, the library needs to be built for the target system. One of

 * `./scripts/build.sh` the host system (your computer)
 * `./script/android/build.sh` ARM-based Android phones (i.e., not emulators / x86)
 * `./script/ios/build.sh` iOS phones (TODO)

### CMake

```cmake
find_package(mobile-cv-suite REQUIRED PATHS /path/to/this/folder)
# use as a dependency
target_link_libraries(your_target PUBLIC mobile-cv-suite)
```

### Android

Add the dependency to your CMake _external native build_ as instructed above
and also add the following to the `build.gradle` file of your app
```groovy
android {
    // ...
    sourceSets {
        main {
            jniLibs.srcDirs '/PATH/TO/THIS/FOLDER/build/android/lib'
        }
    }

    defaultConfig {
        // ...
        externalNativeBuild {
            cmake {
                // ...

                // The library is not build for emulators or other x86 devices
                // by default so you may also need to add this
                abiFilters "arm64-v8a", "armeabi-v7a"
            }
        }
    }
}
```
An alternative to adding `sourceSets` is simply symlinking the relevant directory
as `jniLibs`:
```sh
cd your-app/src/main
ln -s /PATH/TO/THIS/FOLDER/build/android/lib jniLibs
```

### Copyright

The libraries included in the suite are licensed under various open source licenses.
Most of them are permissive licenses, but some SuiteSparse components are under copy-left licenses such as LGPL,
which generally [cannot be used in published apps on iOS nor Android](https://xebia.com/blog/the-lgpl-on-android/).

If you need to use these parts in commercial apps, check if the relevant SuiteSparse
components can either be removed or try to procure an alternative license from their authors.
