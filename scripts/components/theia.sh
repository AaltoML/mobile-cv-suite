#!/bin/bash
# Theia (with reduced features and dependencies)
CUR_DIR=$WORK_DIR/Theia

if [[ -d "$CUR_DIR" && $DO_CLEAR == "ON" ]]; then
  rm -r "$CUR_DIR"
fi

mkdir -p "$CUR_DIR"
cd "$CUR_DIR"
$CMAKE $CMAKE_FLAGS \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
  -DEIGEN3_INCLUDE_DIR="$INSTALL_PREFIX/include/eigen3" \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  "$SRC_DIR/Theia"
$CMAKE --build . --config Release --target install $CMAKE_MAKE_FLAGS

cp "$SRC_DIR/Theia/license.txt" $LICENSE_DIR/Theia.txt
