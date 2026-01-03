#build_plugin.sh
#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

# === CONFIG ===
PLUGIN_EXPORT_NAME="GodotPlugin"
PLUGIN_BINARY_NAME="godot_plugin"

WORKSPACE="${PLUGIN_BINARY_NAME}.xcworkspace"
SCHEME="${PLUGIN_BINARY_NAME}"

BIN_DIR="$PWD/bin"
BUILD_DIR="$BIN_DIR/build"

OUTPUT_ROOT="$BIN_DIR/${PLUGIN_EXPORT_NAME}"
OUTPUT_LIBS="$OUTPUT_ROOT/${PLUGIN_BINARY_NAME}"

echo "🧹 Cleaning bin directory..."
rm -rf "$BIN_DIR"
mkdir -p "$BUILD_DIR" "$OUTPUT_LIBS"

if [ -f "Podfile" ]; then
    echo "📦 Installing Pods..."
    pod install
fi

#####################
# 1. BUILD DEBUG 
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
  SYMROOT="$BUILD_DIR"

DEBUG_LIB="$BUILD_DIR/Debug-iphoneos/lib${PLUGIN_BINARY_NAME}.a"

#####################
# 2. BUILD RELEASE
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
  SYMROOT="$BUILD_DIR"

RELEASE_LIB="$BUILD_DIR/Release-iphoneos/lib${PLUGIN_BINARY_NAME}.a"

#####################
# CREATE XCFRAMEWORKS
#####################
echo "📦 Packaging XCFrameworks..."

xcodebuild -create-xcframework \
  -library "$DEBUG_LIB" \
  -output "$OUTPUT_LIBS/${PLUGIN_BINARY_NAME}.debug.xcframework"

xcodebuild -create-xcframework \
  -library "$RELEASE_LIB" \
  -output "$OUTPUT_LIBS/${PLUGIN_BINARY_NAME}.release.xcframework"

#####################
# 4. COPY GDIP
#####################

GDIP_SOURCE="config/${PLUGIN_BINARY_NAME}.gdip"
GDIP_DEST="$OUTPUT_ROOT/${PLUGIN_BINARY_NAME}.gdip"

if [ -f "$GDIP_SOURCE" ]; then
    echo "📄 Copying .gdip file..."
    cp "$GDIP_SOURCE" "$GDIP_DEST"
else
    echo "⚠️ Warning: .gdip file not found at $GDIP_SOURCE"
fi

rm -rf "$BUILD_DIR"

echo "✅ Done!"
echo "📂 Output structure:"
ls -R "$OUTPUT_ROOT"