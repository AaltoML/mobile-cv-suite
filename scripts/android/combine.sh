# Combine the build artefacts from different sources into one,
# Android-friendly directory structure
set -eux
: "${BUILD_DIR:=build}"
: "${TARGET_DIR:=build/android}"
OPENCV_BUILD_DIR="$BUILD_DIR/opencv-sdk/OpenCV-android-sdk/sdk/native"

rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"
# it does not matter which arch is selected for the h files
cp -R "$BUILD_DIR/arm64-v8a/include" "$TARGET_DIR/include"
cp -R "$OPENCV_BUILD_DIR/jni/include/"* "$TARGET_DIR/include/"
mkdir "$TARGET_DIR/lib"
for arch in arm64-v8a armeabi-v7a; do
  TARGET_LIB_DIR="$TARGET_DIR/lib/$arch"
  mkdir "$TARGET_LIB_DIR"
  cp -R "$BUILD_DIR/$arch/lib/"*.a "$TARGET_LIB_DIR/"
  cp -R "$BUILD_DIR/$arch/lib/"*.so "$TARGET_LIB_DIR/"
  cp -R "$OPENCV_BUILD_DIR/3rdparty/libs/$arch/"* "$TARGET_LIB_DIR/"
  cp -R "$OPENCV_BUILD_DIR/staticlibs/$arch/"* "$TARGET_LIB_DIR/"
done
