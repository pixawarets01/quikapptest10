#!/bin/bash

# Test Version Update from Environment Variables
# Purpose: Test if branding_assets.sh correctly updates version from environment variables
# Usage: ./test_version_update.sh

set -e

echo "🧪 Testing Version Update from Environment Variables"
echo "==================================================="

# Check if we're in a Flutter project
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: This script must be run from the root of a Flutter project"
    exit 1
fi

# Backup original pubspec.yaml
if [ -f "pubspec.yaml" ]; then
    cp "pubspec.yaml" "pubspec.yaml.test.backup"
    echo "📋 Backed up original pubspec.yaml"
fi

# Test 1: Test with valid version environment variables
echo ""
echo "🔍 Test 1: Valid Environment Variables"
echo "======================================"

export VERSION_NAME="1.2.3"
export VERSION_CODE="456"
export BUNDLE_ID="com.test.app"
export APP_NAME="Test App"

echo "Setting test environment variables:"
echo "  VERSION_NAME=$VERSION_NAME"
echo "  VERSION_CODE=$VERSION_CODE"
echo "  BUNDLE_ID=$BUNDLE_ID"
echo "  APP_NAME=$APP_NAME"

echo ""
echo "📋 Current pubspec.yaml version before update:"
grep "^version:" "pubspec.yaml" || echo "No version found"

echo ""
echo "🚀 Running branding_assets.sh..."
if ./lib/scripts/ios/branding_assets.sh; then
    echo ""
    echo "✅ branding_assets.sh completed successfully"
    
    echo ""
    echo "📋 pubspec.yaml version after update:"
    new_version=$(grep "^version:" "pubspec.yaml" | cut -d' ' -f2)
    echo "  $new_version"
    
    expected_version="${VERSION_NAME}+${VERSION_CODE}"
    if [ "$new_version" = "$expected_version" ]; then
        echo "✅ SUCCESS: Version correctly updated to $expected_version"
    else
        echo "❌ FAILURE: Expected $expected_version, got $new_version"
    fi
    
    # Check iOS Info.plist if it exists
    if [ -f "ios/Runner/Info.plist" ]; then
        echo ""
        echo "📱 Checking iOS Info.plist updates..."
        if command -v plutil &> /dev/null; then
            bundle_version=$(plutil -extract CFBundleVersion raw "ios/Runner/Info.plist" 2>/dev/null || echo "not found")
            short_version=$(plutil -extract CFBundleShortVersionString raw "ios/Runner/Info.plist" 2>/dev/null || echo "not found")
            
            echo "  CFBundleVersion: $bundle_version"
            echo "  CFBundleShortVersionString: $short_version"
            
            if [ "$bundle_version" = "$VERSION_CODE" ] && [ "$short_version" = "$VERSION_NAME" ]; then
                echo "✅ SUCCESS: iOS Info.plist correctly updated"
            else
                echo "❌ FAILURE: iOS Info.plist not correctly updated"
            fi
        else
            echo "⚠️ plutil not available, cannot check iOS Info.plist"
        fi
    else
        echo "📱 iOS Info.plist not found (this is okay for testing)"
    fi
    
else
    echo "❌ branding_assets.sh failed"
    exit 1
fi

# Test 2: Test without environment variables
echo ""
echo "🔍 Test 2: Missing Environment Variables"
echo "========================================"

# Restore backup and unset variables
cp "pubspec.yaml.test.backup" "pubspec.yaml"
unset VERSION_NAME
unset VERSION_CODE

echo "Unsetting environment variables to test fallback behavior..."
echo ""
echo "🚀 Running branding_assets.sh without VERSION_NAME/VERSION_CODE..."

if ./lib/scripts/ios/branding_assets.sh; then
    echo ""
    echo "✅ branding_assets.sh completed (should skip version update)"
    
    # Check that version wasn't changed
    restored_version=$(grep "^version:" "pubspec.yaml" | cut -d' ' -f2)
    original_version=$(grep "^version:" "pubspec.yaml.test.backup" | cut -d' ' -f2)
    
    if [ "$restored_version" = "$original_version" ]; then
        echo "✅ SUCCESS: Version correctly left unchanged when env vars not set"
    else
        echo "❌ FAILURE: Version was changed when it shouldn't have been"
    fi
else
    echo "❌ branding_assets.sh failed"
fi

# Test 3: Test with invalid version format
echo ""
echo "🔍 Test 3: Invalid Version Format"
echo "================================="

export VERSION_NAME="invalid_version"
export VERSION_CODE="not_a_number"

echo "Setting invalid environment variables:"
echo "  VERSION_NAME=$VERSION_NAME (invalid format)"
echo "  VERSION_CODE=$VERSION_CODE (not a number)"

echo ""
echo "🚀 Running branding_assets.sh with invalid version format..."

if ./lib/scripts/ios/branding_assets.sh; then
    echo "⚠️ Script completed despite invalid format (VERSION_CODE should fail)"
else
    echo "✅ SUCCESS: Script correctly failed with invalid VERSION_CODE"
fi

# Cleanup
echo ""
echo "🧹 Cleanup"
echo "=========="

# Restore original pubspec.yaml
if [ -f "pubspec.yaml.test.backup" ]; then
    cp "pubspec.yaml.test.backup" "pubspec.yaml"
    rm -f "pubspec.yaml.test.backup"
    echo "✅ Restored original pubspec.yaml"
fi

# Clean up backup files
rm -f pubspec.yaml.version.backup
rm -f ios/Runner/Info.plist.version.backup
echo "✅ Cleaned up backup files"

# Unset test environment variables
unset VERSION_NAME VERSION_CODE BUNDLE_ID APP_NAME
echo "✅ Unset test environment variables"

echo ""
echo "🎉 Version Update Testing Complete!"
echo "===================================="
echo ""
echo "📋 To test manually in your build:"
echo "  export VERSION_NAME=\"1.0.6\""
echo "  export VERSION_CODE=\"51\""
echo "  ./lib/scripts/ios/branding_assets.sh"
echo ""
echo "✅ The script will now show detailed logging about version updates!" 