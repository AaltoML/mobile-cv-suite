#!/bin/bash
CUR_DIR=$WORK_DIR/accelerated-arrays

if [[ -d "$CUR_DIR" && $DO_CLEAR == "ON" ]]; then
  rm -r "$CUR_DIR"
fi

mkdir -p "$CUR_DIR"
cd "$CUR_DIR"
$CMAKE $CMAKE_FLAGS \
    -DWITH_OPENGL_ES=ON \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    "$SRC_DIR/accelerated-arrays"
$CMAKE --build . --config Release --target install $CMAKE_MAKE_FLAGS

cp "$SRC_DIR/accelerated-arrays/LICENSE" $LICENSE_DIR/accelerated-arrays.txt
