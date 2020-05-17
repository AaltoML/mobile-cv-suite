#!/bin/bash
# OpenCV (used by us and the dependencies)
CUR_DIR=$WORK_DIR/opencv

if [[ -d "$CUR_DIR" && $DO_CLEAR == "ON" ]]; then
  rm -r "$CUR_DIR"
fi

mkdir -p "$CUR_DIR"
cd "$CUR_DIR"
# core: Normal stuff like matrices.
# calib3d: RANSAC-5, undistort.
# features2d: Feature detection.
# highgui: UI windows using `imshow`.
# video: Lukas-Kanade optical flow.
# videoio: VideoCapture for processing video data.
#
# Also drop these (may reduce the number needed system packages)
#   * Tons of image codecs
#   * Other unused stuff: Quirc (QR-codes), Protobuf support
#
$CMAKE $CMAKE_FLAGS \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
  -DBUILD_LIST=core,calib3d,features2d,highgui,video,videoio \
  -DWITH_TIFF=OFF -DWITH_JASPER=OFF -DWITH_JPEG=OFF -DWITH_WEBP=OFF -DWITH_OPENEXR=OFF \
  -DWITH_PROTOBUF=OFF -DWITH_QUIRC=OFF \
  "$SRC_DIR/opencv"

# These options would also be interesting
# -DWITH_TBB=OFF -DWITH_OPENMP=OFF -DWITH_PTHREADS_PF=OFF # no internal parallelism
# -DWITH_ITT=OFF -DWITH_IPP=OFF # no Intel-specific stuff
make -j$NPROC install
OPENCV_DIR=$INSTALL_PREFIX/lib/cmake/opencv4
