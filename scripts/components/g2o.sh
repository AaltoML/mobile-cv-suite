#!/bin/bash
# g2o
CUR_DIR=$WORK_DIR/g2o

if [[ -d "$CUR_DIR" && $DO_CLEAR == "ON" ]]; then
  rm -r "$CUR_DIR"
fi

mkdir -p "$CUR_DIR"
cd "$CUR_DIR"
# NOTE: do not set the build type to RelWithDebInfo or OpenVSLAM won't find it
SUITE_SPARSE_ROOT="$INSTALL_PREFIX" $CMAKE $CMAKE_FLAGS \
    -DCMAKE_PREFIX_PATH="$INSTALL_PREFIX" \
    -DCMAKE_LIBRARY_PATH="$INSTALL_PREFIX/lib" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DBUILD_UNITTESTS=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DG2O_BUILD_EXAMPLES=OFF \
    -DG2O_BUILD_APPS=OFF \
    -DG2O_USE_CHOLMOD=OFF \
    -DG2O_USE_OPENGL=OFF \
    -DEIGEN3_INCLUDE_DIR="$INSTALL_PREFIX/include/eigen3" \
    -DEIGEN3_VERSION_OK=ON \
    -DINCLUDE_INSTALL_DIR="$INSTALL_PREFIX/include" \
    "$SRC_DIR/g2o"
$CMAKE --build . --config Release --target install $CMAKE_MAKE_FLAGS

if [ $IOS_CROSS_COMPILING_HACKS ]; then
  # Fix dynamic library paths for iOS.
  cd $INSTALL_PREFIX/lib
  install_name_tool -id @rpath/libg2o_csparse_extension.dylib libg2o_csparse_extension.dylib
fi

cp "$SRC_DIR/g2o/doc/license-bsd.txt" $LICENSE_DIR/g2o.txt
