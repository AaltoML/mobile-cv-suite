#!/bin/bash
# Remove debug symbols to create debug & release variants
set -eux
STRIP="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip"
: "${DEBUG_BUILD_DIR:=build/android}"
: "${RELEASE_BUILD_DIR:=build/android-release}"
rm -rf "$RELEASE_BUILD_DIR"
cp -R "$DEBUG_BUILD_DIR" "$RELEASE_BUILD_DIR"
find "$RELEASE_BUILD_DIR"/lib/ -type f | xargs -L 1 "$STRIP" -g
