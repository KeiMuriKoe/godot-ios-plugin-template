#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

PLUGIN_NAME="GodotPlugin"
WORKSPACE="${PLUGIN_NAME}.xcworkspace"
SCHEME="${PLUGIN_NAME}"

TMP_BUILD="$PWD/.build_tmp"
OUT_DIR="$PWD/${PLUGIN_NAME}"

rm -rf "$TMP_BUILD" "$OUT_DIR"
mkdir -p "$TMP_BUILD" "$OUT_DIR"

pod install

#####################
# BUILD DEBUG
#####################
xcodebuild build \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -sdk iphoneos \
  BUILD_DIR="$TMP_BUILD" \
  BUILD_ROOT="$TMP_BUILD"

#####################
# BUILD RELEASE
#####################
xcodebuild build \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -configuration Release \
  -sdk iphoneos \
  BUILD_DIR="$TMP_BUILD" \
  BUILD_ROOT="$TMP_BUILD"

#####################
# CREATE XCFRAMEWORKS
#####################
xcodebuild -create-xcframework \
  -library "$TMP_BUILD/Debug-iphoneos/lib${PLUGIN_NAME}.a" \
  -output "$OUT_DIR/${PLUGIN_NAME}.debug.xcframework"

xcodebuild -create-xcframework \
  -library "$TMP_BUILD/Release-iphoneos/lib${PLUGIN_NAME}.a" \
  -output "$OUT_DIR/${PLUGIN_NAME}.release.xcframework"

#####################
# CLEAN TEMP BUILD
#####################
rm -rf "$TMP_BUILD"

echo "✅ Plugin SDK ready:"
echo " - ${OUT_DIR}/${PLUGIN_NAME}.debug.xcframework"
echo " - ${OUT_DIR}/${PLUGIN_NAME}.release.xcframework"