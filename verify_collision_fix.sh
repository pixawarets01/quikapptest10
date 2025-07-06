#!/bin/bash

# 🔍 CFBundleIdentifier Collision Verification Script
# 🎯 Target Error ID: 6a8ab053-6a99-4c5c-bc5e-e8d3ed1cbb46

echo "🔍 CFBundleIdentifier Collision Verification"
echo "============================================"
echo "🎯 Target Error ID: 6a8ab053-6a99-4c5c-bc5e-e8d3ed1cbb46"
echo ""

# Set your bundle ID (or use the one from environment)
BUNDLE_ID="${BUNDLE_ID:-com.insurancegroupmo.insurancegroupmo}"
echo "📱 Checking for collisions with Bundle ID: $BUNDLE_ID"
echo ""

# Check if iOS project exists
if [ ! -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
    echo "❌ iOS project not found. Make sure you're in the Flutter project root."
    exit 1
fi

# Check main project file
echo "🔍 Checking main project file..."
MAIN_PROJECT="ios/Runner.xcodeproj/project.pbxproj"
MAIN_BUNDLE_COUNT=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID;" "$MAIN_PROJECT" 2>/dev/null || echo "0")
TEST_BUNDLE_COUNT=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID.tests;" "$MAIN_PROJECT" 2>/dev/null || echo "0")

echo "   📊 Main app configurations: $MAIN_BUNDLE_COUNT"
echo "   📊 Test configurations: $TEST_BUNDLE_COUNT"

if [ "$MAIN_BUNDLE_COUNT" -gt 0 ] && [ "$TEST_BUNDLE_COUNT" -gt 0 ]; then
    echo "   ✅ Main project bundle identifiers look correct"
else
    echo "   ⚠️ Main project bundle identifiers may need attention"
fi

# Check Pods project if it exists
if [ -f "ios/Pods/Pods.xcodeproj/project.pbxproj" ]; then
    echo ""
    echo "🔍 Checking Pods project for collisions..."
    PODS_PROJECT="ios/Pods/Pods.xcodeproj/project.pbxproj"
    COLLISION_COUNT=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID;" "$PODS_PROJECT" 2>/dev/null || echo "0")
    TOTAL_PODS_BUNDLES=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = " "$PODS_PROJECT" 2>/dev/null || echo "0")
    
    echo "   📊 Total pod bundle identifiers: $TOTAL_PODS_BUNDLES"
    echo "   📊 Collisions with main app: $COLLISION_COUNT"
    
    if [ "$COLLISION_COUNT" -eq 0 ]; then
        echo "   ✅ No collisions detected in Pods project"
    else
        echo "   💥 Found $COLLISION_COUNT potential collisions!"
        echo "   🔧 Run your ios-workflow to fix these collisions"
    fi
else
    echo ""
    echo "⚠️ Pods project not found. Run 'pod install' in ios/ directory first."
fi

# Check Info.plist
echo ""
echo "🔍 Checking Info.plist configuration..."
if [ -f "ios/Runner/Info.plist" ]; then
    INFO_BUNDLE_ID=$(grep -A1 "CFBundleIdentifier" "ios/Runner/Info.plist" | tail -n1 | sed 's/.*<string>\(.*\)<\/string>.*/\1/')
    echo "   📱 Info.plist CFBundleIdentifier: $INFO_BUNDLE_ID"
    
    if [ "$INFO_BUNDLE_ID" = "\$(PRODUCT_BUNDLE_IDENTIFIER)" ]; then
        echo "   ✅ Info.plist correctly uses project configuration"
    else
        echo "   ⚠️ Info.plist should use \$(PRODUCT_BUNDLE_IDENTIFIER)"
    fi
else
    echo "   ❌ Info.plist not found"
fi

echo ""
echo "🎯 Verification Summary:"
echo "========================"

if [ "$COLLISION_COUNT" -eq 0 ] && [ "$MAIN_BUNDLE_COUNT" -gt 0 ]; then
    echo "✅ No CFBundleIdentifier collisions detected!"
    echo "📱 Your project should be ready for App Store Connect upload"
else
    echo "⚠️ Potential issues detected"
    echo "🔧 Run your updated ios-workflow in Codemagic to fix collisions"
    echo "📋 The workflow includes automatic collision prevention"
fi

echo ""
echo "🚀 Next steps:"
echo "   1. Commit your updated codemagic.yaml"
echo "   2. Run ios-workflow in Codemagic"
echo "   3. Check build logs for collision prevention messages"
echo "   4. Upload the generated IPA to App Store Connect" 