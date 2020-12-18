#!/bin/bash
# Pangolin - a 3D visualization library
CUR_DIR=$WORK_DIR/Pangolin

if [[ -d "$CUR_DIR" && $DO_CLEAR == "ON" ]]; then
  rm -r "$CUR_DIR"
fi

mkdir -p "$CUR_DIR"
cd "$CUR_DIR"
$CMAKE $CMAKE_FLAGS -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" "$SRC_DIR/Pangolin"
make -j$NPROC install

cp "$SRC_DIR/Pangolin/LICENCE" $LICENSE_DIR/Pangolin.txt
