#!/bin/bash
# Currently only supports arm64 architecture.
#
# Needs `realpath`, which can be obtained eg with `brew install coreutils`.
#
# Can build only the specified dependencies, see `scripts/build.sh` for details.

set -e

: "${DO_CLEAR:=OFF}"
: "${USE_OPENCV_VIDEO_RECORDING:=OFF}"
export DO_CLEAR
export USE_OPENCV_VIDEO_RECORDING

ROOT_DIR=`pwd`
SRC_DIR=$ROOT_DIR
SCRIPT_DIR=$ROOT_DIR/scripts/components

export CMAKE_MAKE_FLAGS="--"
export IOS_CROSS_COMPILING_HACKS=ON

for TARGET_ARCHITECTURE in arm64; do
  export TARGET_ARCHITECTURE
  INSTALL_PREFIX="$ROOT_DIR/build/$TARGET_ARCHITECTURE"
  BUILD_DIR=$ROOT_DIR/build/$TARGET_ARCHITECTURE
  WORK_DIR=$BUILD_DIR/work

  # The options haven't been tested rigorously, some may be superfluous.
  export CMAKE_FLAGS="-G Xcode
    -DCMAKE_TOOLCHAIN_FILE=$ROOT_DIR/ios-cmake/ios.toolchain.cmake
    -DENABLE_BITCODE=FALSE
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON
    -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED=NO
    -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED=NO
    -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY=""
    -DPLATFORM=OS64
    -DTARGET_ARCH=\"$TARGET_ARCHITECTURE\""

  export CC=$(xcrun --sdk iphoneos --find clang)
  export CXX=$(xcrun --sdk iphoneos --find clang++)
  export C_FLAGS="-arch arm64 -isysroot $(xcrun --sdk iphoneos --show-sdk-path) -miphoneos-version-min=8.0"
  export CXX_FLAGS="$C_FLAGS"
  export LDFLAGS="$C_FLAGS"

  # For suitesparse.
  export SUITESPARSE_CF=$C_FLAGS
  export UNAME=Darwin
  export LAPACK=''

  export OPENCV_DIR=$BUILD_DIR/lib/opencv/build/build-$TARGET_ARCHITECTURE-iphoneos/install

  export USE_SLAM=ON

  # Pangolin visualizations aren't needed
  export BUILD_VISUALIZATIONS=OFF

  # OpenGL with accelerated-arrays not supported yet
  export WITH_OPENGL=OFF

  ./scripts/build.sh "$@"
done
