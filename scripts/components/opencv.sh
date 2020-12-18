#!/bin/bash
# OpenCV 4

if [[ $IOS_CROSS_COMPILING_HACKS == "ON" ]]; then
  # Build OpenCV from source for iOS. The output is a framework folder.
  # More info at <https://github.com/opencv/opencv/tree/master/platforms/ios> and the python script source code.

  mkdir -p "$BUILD_DIR/lib"
  cd "$BUILD_DIR/lib"

  # Do a release build.
  # This is rather slow because it builds all the modules even though we
  # only need some. See Android and desktop builds for lists of modules
  # needed. Further the script seems to require building at least one
  # simulator arch, which doubles the build time…
  CMAKE_FLAGS="" CC="" CXX="" CXX_FLAGS="" LDFLAGS="" python2 "$ROOT_DIR"/opencv/platforms/ios/build_framework.py --iphoneos_archs $TARGET_ARCHITECTURE --iphonesimulator_archs x86_64 opencv

  # Add minimal configuration for CMake's `find_package(OpenCV)` to work
  # in 3rd party CMakeLists.txt, for instance that of DBoW2's.
  files="OpenCVConfig.cmake OpenCVConfig-version.cmake"
  for file in $files; do
    cp "$ROOT_DIR"/scripts/ios/"$file" $BUILD_DIR/lib/opencv/build/build-"$TARGET_ARCHITECTURE"-iphoneos/install/
  done

elif [[ $ANDROID_CROSS_COMPILING_HACKS == "ON" ]]; then
  # Build OpenCV only once
  if [[ -z $OPENCV_DIR ]]; then
    cd "$ROOT_DIR"
    cp scripts/android/opencv.config.py opencv/platforms/android
    cd opencv/platforms/android
    CMAKE_FLAGS="" CC="" CXX="" CXX_FLAGS="" LDFLAGS="" python2 build_sdk.py --no_samples_build --config="opencv.config.py" "$ROOT_DIR/build/opencv-sdk"
    rm opencv.config.py
    cd "$ROOT_DIR"
    OPENCV_DIR=$ROOT_DIR/build/opencv-sdk/OpenCV-android-sdk/sdk/native/jni
  fi

else
  CUR_DIR=$WORK_DIR/opencv

  if [[ -d "$CUR_DIR" && $DO_CLEAR == "ON" ]]; then
    rm -r "$CUR_DIR"
  fi

  mkdir -p "$CUR_DIR"
  cd "$CUR_DIR"
  # core: Normal stuff like matrices.
  # calib3d: RANSAC-5, undistort.
  # features2d: Feature detection.
  # highgui: UI windows using `imshow`.
  # video: Lukas-Kanade optical flow.
  # videoio: VideoCapture for processing video data.
  #
  # Also drop these (may reduce the number needed system packages)
  #   * Tons of image codecs
  #   * Other unused stuff: Quirc (QR-codes), Protobuf support
  #
  $CMAKE $CMAKE_FLAGS \
    -DCMAKE_PREFIX_PATH="$INSTALL_PREFIX" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -DBUILD_LIST=core,calib3d,features2d,highgui,video,videoio \
    -DWITH_TIFF=OFF -DWITH_JASPER=OFF -DWITH_JPEG=OFF -DWITH_WEBP=OFF -DWITH_OPENEXR=OFF \
    -DWITH_PROTOBUF=OFF -DWITH_QUIRC=OFF \
    "$SRC_DIR/opencv"

  # These options would also be interesting
  # -DWITH_TBB=OFF -DWITH_OPENMP=OFF -DWITH_PTHREADS_PF=OFF # no internal parallelism
  # -DWITH_ITT=OFF -DWITH_IPP=OFF # no Intel-specific stuff
  make -j$NPROC install
  OPENCV_DIR=$INSTALL_PREFIX/lib/cmake/opencv4

fi

if [[ $TARGET_ARCHITECTURE == "host" ]]; then
  cp -R $BUILD_DIR/share/licenses/opencv4 $LICENSE_DIR
fi
