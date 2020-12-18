#!/bin/bash
# DBoW2
CUR_DIR=$WORK_DIR/DBoW2

if [[ -d "$CUR_DIR" && $DO_CLEAR == "ON" ]]; then
  rm -r "$CUR_DIR"
fi

mkdir -p "$CUR_DIR"
cd "$CUR_DIR"
$CMAKE $CMAKE_FLAGS $IOS_FLAGS \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DOpenCV_DIR="$OPENCV_DIR" \
    -DEigen3_DIR="$INSTALL_PREFIX/share/eigen3/cmake" \
    -DBUILD_SHARED_LIBS=OFF \
    "$SRC_DIR/DBoW2"
$CMAKE --build . --config Release --target install $CMAKE_MAKE_FLAGS

cp "$SRC_DIR/DBoW2/LICENSE.txt" $LICENSE_DIR/DBoW2.txt
