#!/bin/bash
set -ex

cd "$(dirname "$0")"
cd ../

mkdir -p bin
pod install

xcodebuild archive \
  -workspace GodotPlugin.xcworkspace \
  -scheme GodotPlugin \
  -archivePath bin/ios_debug.xcarchive \
  -sdk iphoneos \
  -configuration Debug

xcodebuild archive \
  -workspace GodotPlugin.xcworkspace \
  -scheme GodotPlugin \
  -archivePath bin/ios_release.xcarchive \
  -sdk iphoneos \
  -configuration Release
