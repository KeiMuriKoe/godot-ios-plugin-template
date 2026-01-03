#build_plugin.sh
#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

# === CONFIG ===
PLUGIN_NAME="GodotPlugin"
WORKSPACE="${PLUGIN_NAME}.xcworkspace"
SCHEME="${PLUGIN_NAME}"

BUILD_DIR="$PWD/bin/build"

OUTPUT_DIR="$PWD/bin/${PLUGIN_NAME}"

rm -rf "$BUILD_DIR" "$OUTPUT_DIR"
mkdir -p "$BUILD_DIR" "$OUTPUT_DIR"

if [ -f "Podfile" ]; then
    echo "📦 Installing Pods..."
    pod install
fi

#####################
# 1. BUILD DEBUG (DEVICE ONLY)
#####################
echo "🛠 Building Debug (iphoneos)..."
xcodebuild build \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  BUILD_DIR="$BUILD_DIR" \
  BUILD_ROOT="$BUILD_DIR" \
  SYMROOT="$BUILD_DIR" \
  > /dev/null


DEBUG_LIB="$BUILD_DIR/Debug-iphoneos/lib${PLUGIN_NAME}.a"

#####################
# 2. BUILD RELEASE (DEVICE ONLY)
#####################
echo "🚀 Building Release (iphoneos)..."
xcodebuild build \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -configuration Release \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  BUILD_DIR="$BUILD_DIR" \
  BUILD_ROOT="$BUILD_DIR" \
  SYMROOT="$BUILD_DIR" \
  > /dev/null


RELEASE_LIB="$BUILD_DIR/Release-iphoneos/lib${PLUGIN_NAME}.a"

#####################
# 3. CREATE XCFRAMEWORKS
#####################
echo "📦 Packaging XCFrameworks..."


xcodebuild -create-xcframework \
  -library "$DEBUG_LIB" \
  -output "$OUTPUT_DIR/${PLUGIN_NAME}.debug.xcframework"


xcodebuild -create-xcframework \
  -library "$RELEASE_LIB" \
  -output "$OUTPUT_DIR/${PLUGIN_NAME}.release.xcframework"


rm -rf "$BUILD_DIR"

echo "✅ Done!"
echo "📂 Output structure in bin/${PLUGIN_NAME}:"
ls -1 "$OUTPUT_DIR"