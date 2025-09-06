#!/bin/bash

echo "🧹 Cleaning iOS build..."
echo "================================"

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

# Install pods
echo "4. Installing CocoaPods..."
pod install --repo-update

# Go back to root
cd ..

# Clean derived data (optional - uncomment if needed)
# echo "5. Cleaning Xcode derived data..."
# rm -rf ~/Library/Developer/Xcode/DerivedData

echo "✅ iOS build cleaned successfully!"
echo ""
echo "Next steps:"
echo "1. Open ios/Runner.xcworkspace in Xcode"
echo "2. Select your target device (not simulator)"
echo "3. Build and run the project"
echo ""
echo "If you still see issues:"
echo "- Check Xcode console for specific error messages"
echo "- Ensure Firebase configuration is correct"
echo "- Try running on a different iOS device" 