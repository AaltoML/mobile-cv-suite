A Computer Vision research library for mobile phones. A collection of Open Source
libraries that are important building blocks required to test new algorithms
on mobile & embedded devices.

## Usage

### Pre-built library (Android only)

This is the recommended method, when available, since it can dramatically
reduce the build time of the dependent application.

Example usage in `MakeLists.txt`:
```CMake
set(MCS_VERSION 1.1.1) # The library version you wish to use (see "releases")
set(MCS_TARGET_DIR ${ROOT_DIR}/app/.cxx/mobile-cv-suite-${MCS_VERSION})
if(NOT EXISTS ${MCS_TARGET_DIR})
    set(MCS_ARCHIVE_FN ${CMAKE_CURRENT_BINARY_DIR}/mobile-cv-suite.tar-${MCS_VERSION}.gz)
    file(DOWNLOAD https://github.com/AaltoML/mobile-cv-suite/releases/download/${MCS_VERSION}/mobile-cv-suite.tar.gz ${MCS_ARCHIVE_FN} SHOW_PROGRESS)
    file(MAKE_DIRECTORY ${MCS_TARGET_DIR})
    execute_process(COMMAND ${CMAKE_COMMAND} -E tar -xf ${MCS_ARCHIVE_FN} WORKING_DIRECTORY ${MCS_TARGET_DIR})
endif()
set(mobile-cv-suite_DIR "${MCS_TARGET_DIR}")

find_package(mobile-cv-suite)

# use as a dependency
target_link_libraries(your_target PUBLIC mobile-cv-suite)
```

### Building from source

You most likely need to install these Linux packages: `gfortran libglfw3-dev clang`
and on some systems, you may also need some or all of the following to build the full suite, including visualizations:

    libgtk2.0-dev
    libgstreamer1.0-dev
    libvtk6-dev
    libavresample-dev
    libopengl-dev # or mesa-common-dev
    libglew-dev
    libxkbcommon-dev
    wayland-protocols
    python3-distutils
    python3-dev

(Another option is using `BUILD_VISUALIZATIONS=OFF ./scripts/build.sh` to disable the visualizations)

The library needs to be built for the target system. One of

 * `./scripts/build.sh` the host system (your computer)
 * `./script/android/build.sh` ARM-based Android phones (i.e., not emulators / x86)
 * `./script/ios/build.sh` iOS phones

Then the library suite can be linked to a CMake project as follows

```CMake
find_package(mobile-cv-suite REQUIRED PATHS /path/to/this/folder)
# use as a dependency
target_link_libraries(your_target PUBLIC mobile-cv-suite)
```

## Copyright

The libraries included in the suite are licensed under various open source licenses.
Most of them are permissive licenses, but some SuiteSparse components are under copy-left licenses such as LGPL,
which generally [cannot be used in published apps on iOS nor Android](https://xebia.com/blog/the-lgpl-on-android/).

If you need to use these parts in commercial apps, check if the relevant SuiteSparse
components can either be removed or try to procure an alternative license from their authors.

The build scripts (that is `scripts` folder) in this repository are licensed under Apache 2.0.
The pre-built Android version `tar.gz`  file includes a copy of each license.
