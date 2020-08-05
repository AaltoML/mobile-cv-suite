#!/bin/bash
# Eigen (used by us and the dependencies)
CUR_DIR=$WORK_DIR/eigen

if [[ -d "$CUR_DIR" && $DO_CLEAR == "ON" ]]; then
  rm -r "$CUR_DIR"
fi

mkdir -p "$CUR_DIR"
cd "$CUR_DIR"
$CMAKE $CMAKE_FLAGS \
    -DCMAKE_PREFIX_PATH="$INSTALL_PREFIX" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -DBUILD_TESTING=OFF \
    "$SRC_DIR/eigen"
$CMAKE --build . --config Release --target install $CMAKE_MAKE_FLAGS
