#!/bin/bash
# Build OpenCV from source for iOS. The output is a framework folder.
# More info at <https://github.com/opencv/opencv/tree/master/platforms/ios> and the python script source code.

set -e

TARGET_ARCHITECTURE=arm64

ROOT_DIR=`pwd`

BUILD_DIR="$ROOT_DIR"/build/"$TARGET_ARCHITECTURE"/lib
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Do a release build.
# This is rather slow because it builds all the modules even though we
# only need some. See Android and desktop builds for lists of modules
# needed. Further the script seems to require building at least one
# simulator arch, which doubles the build time…
python2 "$ROOT_DIR"/opencv/platforms/ios/build_framework.py --iphoneos_archs $TARGET_ARCHITECTURE --iphonesimulator_archs x86_64 opencv

# Add minimal configuration for CMake's `find_package(OpenCV)` to work
# in 3rd party CMakeLists.txt, for instance that of DBoW2's.
files="OpenCVConfig.cmake OpenCVConfig-version.cmake"
for file in $files; do
  cp "$ROOT_DIR"/scripts/ios/"$file" $BUILD_DIR/opencv/build/build-"$TARGET_ARCHITECTURE"-iphoneos/install/
done
