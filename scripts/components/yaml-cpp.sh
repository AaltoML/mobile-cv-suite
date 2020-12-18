#!/bin/bash
# yaml-cpp
CUR_DIR=$WORK_DIR/yaml-cpp

if [[ -d "$CUR_DIR" && $DO_CLEAR == "ON" ]]; then
  rm -r "$CUR_DIR"
fi

mkdir -p "$CUR_DIR"
cd "$CUR_DIR"
$CMAKE $CMAKE_FLAGS \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -DYAML_CPP_BUILD_TESTS=OFF \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    "$SRC_DIR/yaml-cpp"
$CMAKE --build . --config Release --target install $CMAKE_MAKE_FLAGS

# libyaml-cpp.a can end up in either lib/ or lib64/
if [ -f "$INSTALL_PREFIX/lib64/libyaml-cpp.a" ]; then
  mkdir -p "$INSTALL_PREFIX/lib"
  cp "$INSTALL_PREFIX/lib64/libyaml-cpp.a" "$INSTALL_PREFIX/lib/libyaml-cpp.a"
fi

cp "$SRC_DIR/yaml-cpp/LICENSE" $LICENSE_DIR/yaml-cpp.txt
