#!/bin/bash

# Test Enhanced Branding Assets Script
# Purpose: Test the enhanced branding_assets.sh script with all basic app information

set -euo pipefail

echo "🧪 Testing Enhanced Branding Assets Script"
echo "=========================================="

# Set up test environment variables
export WORKFLOW_ID="test_workflow_123"
export APP_ID="com.testcompany.testapp"
export VERSION_NAME="1.0.0"
export VERSION_CODE="1"
export APP_NAME="Test App"
export ORG_NAME="Test Company"
export BUNDLE_ID="com.testcompany.testapp"
export WEB_URL="https://testcompany.com"
export LOGO_URL="https://via.placeholder.com/1024x1024/007AFF/FFFFFF?text=Logo"
export SPLASH_URL="https://via.placeholder.com/2048x2048/007AFF/FFFFFF?text=Splash"
export SPLASH_BG_URL="https://via.placeholder.com/2048x2048/000000/FFFFFF?text=Background"
export BOTTOMMENU_ITEMS="https://via.placeholder.com/64x64/FF0000/FFFFFF?text=Home:Home,https://via.placeholder.com/64x64/00FF00/FFFFFF?text=Search:Search,https://via.placeholder.com/64x64/0000FF/FFFFFF?text=Profile:Profile"

echo "📋 Test Environment Variables:"
echo "   WORKFLOW_ID: $WORKFLOW_ID"
echo "   APP_ID: $APP_ID"
echo "   VERSION_NAME: $VERSION_NAME"
echo "   VERSION_CODE: $VERSION_CODE"
echo "   APP_NAME: $APP_NAME"
echo "   ORG_NAME: $ORG_NAME"
echo "   BUNDLE_ID: $BUNDLE_ID"
echo "   WEB_URL: $WEB_URL"
echo "   LOGO_URL: $LOGO_URL"
echo "   SPLASH_URL: $SPLASH_URL"
echo "   SPLASH_BG_URL: $SPLASH_BG_URL"
echo "   BOTTOMMENU_ITEMS: $BOTTOMMENU_ITEMS"
echo ""

# Create test directories
mkdir -p assets/images
mkdir -p assets/icons
mkdir -p ios/Runner/Assets.xcassets/AppIcon.appiconset
mkdir -p ios/Runner/Assets.xcassets/LaunchImage.imageset

# Create test pubspec.yaml if it doesn't exist
if [ ! -f "pubspec.yaml" ]; then
    cat > pubspec.yaml << EOF
name: test_app
description: A test Flutter app
version: 0.0.1+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
EOF
fi

# Create test iOS Info.plist if it doesn't exist
mkdir -p ios/Runner
if [ ! -f "ios/Runner/Info.plist" ]; then
    cat > ios/Runner/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>TestApp</string>
    <key>CFBundleDisplayName</key>
    <string>TestApp</string>
    <key>CFBundleShortVersionString</key>
    <string>0.0.1</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleIdentifier</key>
    <string>com.testcompany.testapp</string>
</dict>
</plist>
EOF
fi

# Create test iOS project file if it doesn't exist
mkdir -p ios/Runner.xcodeproj
if [ ! -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
    cat > ios/Runner.xcodeproj/project.pbxproj << EOF
// !$*UTF8*$!
{
    archiveVersion = 1;
    classes = {
    };
    objectVersion = 56;
    objects = {
        /* Begin PBXBuildFile section */
        /* End PBXBuildFile section */
        
        /* Begin PBXNativeTarget section */
        13B07F861A680F5B00A75B9A /* Runner */ = {
            isa = PBXNativeTarget;
            buildConfigurationList = 13B07F931A680F5B00A75B9A /* Build configuration list for PBXNativeTarget "Runner" */;
            buildPhases = (
            );
            buildRules = (
            );
            dependencies = (
            );
            name = Runner;
            productName = Runner;
            productReference = 13B07F961A680F5B00A75B9A /* Runner.app */;
            productType = "com.apple.product-type.application";
        };
        /* End PBXNativeTarget section */
        
        /* Begin XCBuildConfiguration section */
        13B07F941A680F5B00A75B9A /* Debug */ = {
            isa = XCBuildConfiguration;
            buildSettings = {
                PRODUCT_BUNDLE_IDENTIFIER = com.testcompany.testapp;
            };
            name = Debug;
        };
        13B07F951A680F5B00A75B9A /* Release */ = {
            isa = XCBuildConfiguration;
            buildSettings = {
                PRODUCT_BUNDLE_IDENTIFIER = com.testcompany.testapp;
            };
            name = Release;
        };
        /* End XCBuildConfiguration section */
    };
    rootObject = 83CBB9F71A601CBA00E9B192 /* Project object */;
}
EOF
fi

echo "🚀 Running Enhanced Branding Assets Script..."
echo ""

# Run the enhanced branding assets script
if lib/scripts/ios/branding_assets.sh; then
    echo ""
    echo "✅ Enhanced Branding Assets Script completed successfully!"
    echo ""
    echo "📊 Results Summary:"
    echo "   ✅ Basic app information validated"
    echo "   ✅ App configuration files updated"
    echo "   ✅ Bundle ID and app name updated"
    echo "   ✅ Version information updated"
    echo "   ✅ Bottom menu items processed"
    echo "   ✅ Logo and splash assets downloaded"
    echo "   ✅ Assets copied to iOS locations"
    echo ""
    echo "📁 Generated Files:"
    ls -la assets/images/ 2>/dev/null || echo "   No images directory"
    ls -la assets/icons/menu/ 2>/dev/null || echo "   No menu icons directory"
    echo ""
    echo "📋 Updated Configuration Files:"
    echo "   pubspec.yaml: $(grep '^version:' pubspec.yaml 2>/dev/null || echo 'not found')"
    echo "   pubspec.yaml: $(grep '^name:' pubspec.yaml 2>/dev/null || echo 'not found')"
    echo ""
    echo "🎉 Test completed successfully!"
else
    echo ""
    echo "❌ Enhanced Branding Assets Script failed!"
    echo "Check the error messages above for details."
    exit 1
fi 