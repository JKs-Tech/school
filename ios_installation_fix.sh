#!/bin/bash

echo "🔧 Fixing iOS Installation Error..."
echo "==================================="

# Clean Flutter
echo "1. Cleaning Flutter..."
flutter clean

# Get dependencies
echo "2. Getting Flutter dependencies..."
flutter pub get

# Clean iOS build
echo "3. Cleaning iOS build..."
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
rm -rf Flutter/Generated.xcconfig

# Clean Xcode derived data
echo "4. Cleaning Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*

# Install pods
echo "5. Installing CocoaPods..."
pod install --repo-update

# Go back to root
cd ..

# Regenerate Flutter files
echo "6. Regenerating Flutter files..."
flutter pub get

echo "✅ iOS installation fix completed!"
echo ""
echo "Next steps:"
echo "1. Open ios/Runner.xcworkspace in Xcode"
echo "2. Go to Runner target → Signing & Capabilities"
echo "3. Ensure 'Automatically manage signing' is checked"
echo "4. Select your team"
echo "5. Clean build folder: Product → Clean Build Folder"
echo "6. Build and run on device"
echo ""
echo "If you still get errors:"
echo "- Check that your device is properly connected"
echo "- Verify your Apple Developer account is active"
echo "- Try deleting the app from device and reinstalling" 