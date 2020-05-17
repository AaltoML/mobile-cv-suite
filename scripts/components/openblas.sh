#!/bin/bash
# OpenBLAS (SuiteSparse dependency)
CUR_DIR=$WORK_DIR/OpenBLAS

if [[ -d "$CUR_DIR" && $DO_CLEAR == "ON" ]]; then
  rm -r "$CUR_DIR"
fi

mkdir -p "$CUR_DIR"
cd "$CUR_DIR"
$CMAKE $CMAKE_FLAGS $OPENBLAS_CMAKE_FLAGS \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -DUSE_THREAD=OFF \
    "$SRC_DIR/OpenBLAS"
$CMAKE --build . --config Release --target install $CMAKE_MAKE_FLAGS
