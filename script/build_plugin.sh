#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

PLUGIN_NAME="usercentrics"
WORKSPACE="GodotPlugin.xcworkspace"
SCHEME="GodotPlugin"

BUILD_DIR="$PWD/bin/build"
OUT_DIR="$PWD/bin/plugin"

rm -rf "$BUILD_DIR" "$OUT_DIR"
mkdir -p "$BUILD_DIR" "$OUT_DIR"

pod install

#####################
# BUILD RELEASE
#####################
xcodebuild build \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -configuration Release \
  -sdk iphoneos \
  BUILD_DIR="$BUILD_DIR" \
  BUILD_ROOT="$BUILD_DIR"

RELEASE_A="$BUILD_DIR/Release-iphoneos/lib${PLUGIN_NAME}.a"

#####################
# CREATE XCFRAMEWORK
#####################
xcodebuild -create-xcframework \
  -library "$RELEASE_A" \
  -output "$OUT_DIR/${PLUGIN_NAME}.xcframework"

#####################
# CLEAN BUILD
#####################
rm -rf "$BUILD_DIR"

echo "✅ Plugin ready:"
echo " - ${OUT_DIR}/${PLUGIN_NAME}.xcframework"