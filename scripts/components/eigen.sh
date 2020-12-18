#!/bin/bash
# Eigen
if [ $ANDROID_CROSS_COMPILING_HACKS ]; then
  # Eigen CMake will break if your Fortran compiler does not work, which it
  # does not if it's located in /usr/bin and you are cross-compiling for ARM.

  # This is almost the same thing
  rm -rf "$INSTALL_PREFIX/include/eigen3"
  mkdir -p "$INSTALL_PREFIX/include/eigen3/unsupported"
  cp -R "$SRC_DIR/eigen/Eigen" "$INSTALL_PREFIX/include/eigen3/Eigen"
  cp -R "$SRC_DIR/eigen/unsupported/Eigen" "$INSTALL_PREFIX/include/eigen3/unsupported/Eigen"

  # ...but all the libraries have their own brew of "FindEigen.cmake" which may
  # not work unless the Eigen cmake files exists too. They consist of ~200
  # lines of CMake scripts to specify the Eigen version and the single folder
  # in which all the eigen header files are located

  # hack: let's just copy that from the host build... This works beacuse
  # the files seem to use relative paths that mostly look like ../../../
  mkdir -p "$INSTALL_PREFIX/share/eigen3/"
  cp -R "$ROOT_DIR/build/host/share/eigen3/cmake" "$INSTALL_PREFIX/share/eigen3/"
else
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
fi

mkdir -p $LICENSE_DIR/Eigen
cp "$SRC_DIR/eigen/COPYING.MPL2" $LICENSE_DIR/Eigen
cp "$SRC_DIR/eigen/COPYING.MINPACK" $LICENSE_DIR/Eigen # stuff in the unsupported/ dir
# warning: there is an LGPL-licensed header included: Eigen/src/IterativeLinearSolvers/IncompleteLUT.h
cp "$SRC_DIR/eigen/COPYING.LGPL" $LICENSE_DIR/Eigen
