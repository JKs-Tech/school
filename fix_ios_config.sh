#!/bin/bash

echo "🔧 Fixing iOS Configuration Warning..."
echo "======================================"

# Go to iOS directory
cd ios

# Clean up any existing issues
echo "1. Cleaning up existing configuration..."
rm -rf Pods
rm -rf Podfile.lock

# Install pods again
echo "2. Installing pods..."
pod install

# Check if Profile.xcconfig exists
if [ ! -f "Flutter/Profile.xcconfig" ]; then
    echo "3. Creating missing Profile.xcconfig..."
    echo '#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.profile.xcconfig"' > Flutter/Profile.xcconfig
    echo '#include "Generated.xcconfig"' >> Flutter/Profile.xcconfig
fi

echo "4. Configuration files status:"
echo "   - Debug.xcconfig: $(ls -la Flutter/Debug.xcconfig)"
echo "   - Release.xcconfig: $(ls -la Flutter/Release.xcconfig)"
echo "   - Profile.xcconfig: $(ls -la Flutter/Profile.xcconfig)"

echo ""
echo "✅ Configuration fix completed!"
echo ""
echo "Next steps:"
echo "1. Open ios/Runner.xcworkspace in Xcode"
echo "2. Go to Runner target → Build Settings"
echo "3. Search for 'Config' and ensure all configurations are set:"
echo "   - Debug: Debug"
echo "   - Release: Release"
echo "   - Profile: Profile"
echo "4. Clean and build the project"
echo ""
echo "Note: The warning about firebase_app_id_file.json is normal and won't affect functionality." 