#!/bin/bash
# PoseLib <https://github.com/vlarsson/PoseLib>
CUR_DIR=$WORK_DIR/PoseLib

if [ $ANDROID_CROSS_COMPILING_HACKS ]; then
  # NOTE Android build requires removing `-march=native` from PoseLib CMakeLists.txt,
  # and possibly also `-ffast-math`: <https://github.com/vlarsson/PoseLib/issues/13>.
  echo "Skipping PoseLib build"
else
  if [[ -d "$CUR_DIR" && $DO_CLEAR == "ON" ]]; then
    rm -r "$CUR_DIR"
  fi

  mkdir -p "$CUR_DIR"
  cd "$CUR_DIR"
  $CMAKE $CMAKE_FLAGS $IOS_FLAGS \
      -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
      -DEigen3_DIR="$INSTALL_PREFIX/share/eigen3/cmake" \
      "$SRC_DIR/PoseLib"
  $CMAKE --build . --config Release --target install $CMAKE_MAKE_FLAGS

  cp "$SRC_DIR/PoseLib/LICENSE" $LICENSE_DIR/PoseLib.txt
fi
