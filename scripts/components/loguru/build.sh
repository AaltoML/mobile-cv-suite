#!/bin/bash
CUR_DIR=$WORK_DIR/loguru

if [[ -d "$CUR_DIR" && $DO_CLEAR == "ON" ]]; then
  rm -r "$CUR_DIR"
fi

CMAKE_FILE="$SRC_DIR"

mkdir -p "$CUR_DIR"
cd "$CUR_DIR"
$CMAKE $CMAKE_FLAGS \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    "$SRC_DIR/scripts/components/loguru"
$CMAKE --build . --config Release --target install $CMAKE_MAKE_FLAGS

# License: public domain
cp "$SRC_DIR/loguru/README.md" $LICENSE_DIR/Loguru.md
