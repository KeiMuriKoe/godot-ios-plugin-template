#!/bin/bash
set -ex

cd "$(dirname "$0")"
cd ../

mkdir -p bin
pod install

xcodebuild build \
  -workspace GodotPlugin.xcworkspace \
  -scheme GodotPlugin \
  -configuration Debug \
  -sdk iphoneos \
  BUILD_DIR="$PWD/bin"

xcodebuild build \
  -workspace GodotPlugin.xcworkspace \
  -scheme GodotPlugin \
  -configuration Release \
  -sdk iphoneos \
  BUILD_DIR="$PWD/bin"
