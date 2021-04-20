#!/bin/bash
CUR_DIR=$WORK_DIR/jsonl-recorder

if [[ -d "$CUR_DIR" && $DO_CLEAR == "ON" ]]; then
  rm -r "$CUR_DIR"
fi

mkdir -p "$CUR_DIR"
cd "$CUR_DIR"
# JSON_MultipleHeaders causes json_fwd.hpp to be installed as part of
# the jsonl-recorder interface
$CMAKE $CMAKE_FLAGS \
    -DBUILD_TESTING=OFF \
    -DJSON_MultipleHeaders=ON \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DUSE_OPENCV_VIDEO_RECORDING="$USE_OPENCV_VIDEO_RECORDING" \
    -DOpenCV_DIR="$OPENCV_DIR" \
    "$SRC_DIR/jsonl-recorder"
$CMAKE --build . --config Release --target install $CMAKE_MAKE_FLAGS

cp "$SRC_DIR/jsonl-recorder/LICENSE" $LICENSE_DIR/jsonl-recorder.txt
cp "$SRC_DIR/json/LICENSE.MIT" $LICENSE_DIR/json.txt
