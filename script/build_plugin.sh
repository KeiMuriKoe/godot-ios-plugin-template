#!/bin/bash
set -ex
cd "$(dirname "$0")"
cd ../ios-plugin
mkdir -p bin
pod install

xcodebuild archive -workspace YourPlugin.xcworkspace -scheme YourPlugin -archivePath bin/ios_debug.xcarchive -sdk iphoneos -configuration Debug
xcodebuild archive -workspace YourPlugin.xcworkspace -scheme YourPlugin -archivePath bin/ios_release.xcarchive -sdk iphoneos -configuration Release
