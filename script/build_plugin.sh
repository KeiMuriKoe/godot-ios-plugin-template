##build_plugin.sh
#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

# === CONFIG (ШАБЛОН) ===
PLUGIN_NAME="GodotPlugin"
WORKSPACE="${PLUGIN_NAME}.xcworkspace"
SCHEME="${PLUGIN_NAME}"

BUILD_DIR="$PWD/bin/build"
XC_OUT="$PWD/bin/xcframework"

rm -rf "$BUILD_DIR" "$XC_OUT"
mkdir -p "$BUILD_DIR" "$XC_OUT"

pod install

#####################
# BUILD DEBUG
#####################
xcodebuild build \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -sdk iphoneos \
  BUILD_DIR="$BUILD_DIR" \
  BUILD_ROOT="$BUILD_DIR"

DEBUG_A="$BUILD_DIR/Debug-iphoneos/lib${PLUGIN_NAME}.a"

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
# CREATE XCFRAMEWORKS
#####################
xcodebuild -create-xcframework \
  -library "$DEBUG_A" \
  -output "$XC_OUT/${PLUGIN_NAME}.debug.xcframework"

xcodebuild -create-xcframework \
  -library "$RELEASE_A" \
  -output "$XC_OUT/${PLUGIN_NAME}.release.xcframework"

#####################
# CREATE FINAL (FOR GODOT)
#####################
rm -rf "$XC_OUT/${PLUGIN_NAME}.xcframework"
cp -R "$XC_OUT/${PLUGIN_NAME}.release.xcframework" \
      "$XC_OUT/${PLUGIN_NAME}.xcframework"

echo "✅ XCFrameworks generated:"
echo " - ${PLUGIN_NAME}.debug.xcframework"
echo " - ${PLUGIN_NAME}.release.xcframework"
echo " - ${PLUGIN_NAME}.xcframework (used by .gdip)"