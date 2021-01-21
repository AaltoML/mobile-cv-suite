#!/bin/bash
set -ex
: "${BUILD_EIGEN:=ON}"
: "${USE_SLAM:=ON}"

export USE_SLAM

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    : "${ANDROID_HOME:=$HOME/Android/Sdk}"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    : "${ANDROID_HOME:=$HOME/Library/Android/sdk}"
else
    echo "unrecognized OSTYPE $OSTYPE"
    exit 1
fi
export ANDROID_HOME
export ANDROID_SDK="$ANDROID_HOME"
# not always installed into this default directory in, e.g., CI environments
: "${ANDROID_NDK:=$ANDROID_HOME/ndk-bundle}"
export ANDROID_NDK

# Build Eigen
# TODO: Move to component/eigen.sh
if [[ $BUILD_EIGEN == "ON" ]]; then
  ./scripts/build.sh eigen
fi

ROOT_DIR=`pwd`

export BUILD_VISUALIZATIONS=OFF
export ANDROID_CROSS_COMPILING_HACKS=ON

# Then build the other dependencies for each architecture
export CMAKE=($ANDROID_HOME/cmake/*/bin/cmake)
for TARGET_ARCHITECTURE in arm64-v8a armeabi-v7a; do
  INSTALL_PREFIX="$ROOT_DIR/build/$TARGET_ARCHITECTURE"

  export TARGET_ARCHITECTURE
  export CMAKE_FLAGS="-DANDROID_ABI=$TARGET_ARCHITECTURE
    -DCMAKE_BUILD_TYPE=Release
    -DANDROID_PLATFORM=android-23
    -DANDROID_NDK=$ANDROID_NDK
    -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake
    -DCMAKE_FIND_ROOT_PATH=\"$ANDROID_NDK;$INSTALL_PREFIX;$OPENCV_DIR\"
    -DANDROID_TOOLCHAIN=clang"

  FLAGS_FILE=`mktemp`
  python scripts/android/extract_cmake_flags.py > "$FLAGS_FILE"
  source "$FLAGS_FILE"
  cat "$FLAGS_FILE"
  rm "$FLAGS_FILE"
  export CC
  export CXX
  #export ARCHIVE=$AR
  export RANLIB
  export SUITESPARSE_CF=$CXX_FLAGS
  export EXTRA_INCLUDE_DIR=$CPP_INCLUDE_DIR

  export ACCELERATED_ARRAYS_CMAKE_FLAGS="-DWITH_OPENGL_ES=ON"
  export OPENBLAS_CMAKE_FLAGS="-DNOFORTRAN=1"
  # Suitesparse compilation uses this and adds incorrect stuff
  # when cross-compiling, if this is Linux or Darwin
  export UNAME=Android
  export LAPACK=''

  ./scripts/build.sh "$@"
done

./scripts/android/combine.sh
source ./scripts/android/strip.sh
