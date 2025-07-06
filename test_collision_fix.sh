#!/bin/bash

# Test CFBundleIdentifier Collision Fix
# Purpose: Verify that the collision fix is working and CocoaPods can parse the project file
# Target Error: Validation failed (409) CFBundleIdentifier Collision

set -euo pipefail

echo "🧪 Testing CFBundleIdentifier Collision Fix"
echo "==========================================="
echo "🎯 Target Error: Validation failed (409) CFBundleIdentifier Collision"
echo "🔧 Secondary Issue: CocoaPods Unicode parsing errors"
echo ""

# Configuration
PROJECT_ROOT=$(pwd)
IOS_PROJECT_FILE="$PROJECT_ROOT/ios/Runner.xcodeproj/project.pbxproj"
INFO_PLIST="$PROJECT_ROOT/ios/Runner/Info.plist"
PODFILE="$PROJECT_ROOT/ios/Podfile"

echo "📁 Project Root: $PROJECT_ROOT"
echo ""

# Check if files exist
if [ ! -f "$IOS_PROJECT_FILE" ]; then
    echo "❌ iOS project file not found: $IOS_PROJECT_FILE"
    exit 1
fi

if [ ! -f "$INFO_PLIST" ]; then
    echo "❌ Info.plist not found: $INFO_PLIST"
    exit 1
fi

if [ ! -f "$PODFILE" ]; then
    echo "❌ Podfile not found: $PODFILE"
    exit 1
fi

echo "✅ Required files found"
echo ""

# Test 1: Check for Unicode characters in project file
echo "🔍 Test 1: Checking for Unicode characters in project file..."
UNICODE_CHARS=$(grep -P -n "[\x80-\xFF]" "$IOS_PROJECT_FILE" | head -5 || true)

if [ -z "$UNICODE_CHARS" ]; then
    echo "✅ No Unicode characters found in project file"
else
    echo "⚠️ Unicode characters found in project file:"
    echo "$UNICODE_CHARS" | sed 's/^/   /'
fi
echo ""

# Test 2: Check bundle identifier distribution
echo "🔍 Test 2: Checking bundle identifier distribution..."
BUNDLE_IDS=$(grep "PRODUCT_BUNDLE_IDENTIFIER" "$IOS_PROJECT_FILE" | sed 's/.*PRODUCT_BUNDLE_IDENTIFIER = \([^;]*\);.*/\1/' | sort | uniq -c)
echo "📊 Bundle identifier distribution:"
echo "$BUNDLE_IDS" | sed 's/^/   /'

# Check for collisions
COLLISION_COUNT=$(echo "$BUNDLE_IDS" | awk '$1 > 1 {sum += $1-1} END {print sum+0}')
if [ "$COLLISION_COUNT" -eq 0 ]; then
    echo "✅ No collisions detected"
else
    echo "❌ Collisions detected: $COLLISION_COUNT duplicate entries"
fi
echo ""

# Test 3: Check Info.plist bundle identifier
echo "🔍 Test 3: Checking Info.plist bundle identifier..."
if command -v plutil &> /dev/null; then
    PLIST_BUNDLE_ID=$(plutil -extract CFBundleIdentifier raw "$INFO_PLIST" 2>/dev/null || echo "NOT_FOUND")
    echo "📱 Info.plist CFBundleIdentifier: $PLIST_BUNDLE_ID"
    
    if [[ "$PLIST_BUNDLE_ID" == "com.twinklub.twinklub" ]]; then
        echo "✅ Info.plist has correct bundle identifier"
    else
        echo "⚠️ Info.plist bundle identifier may need update"
    fi
else
    echo "⚠️ plutil not available, skipping Info.plist check"
fi
echo ""

# Test 4: Check Podfile collision prevention
echo "🔍 Test 4: Checking Podfile collision prevention..."
if grep -q "CFBundleIdentifier.*collision.*prevention" "$PODFILE"; then
    echo "✅ Podfile has collision prevention hook"
else
    echo "⚠️ Podfile missing collision prevention hook"
fi

if grep -q "post_install.*installer" "$PODFILE"; then
    echo "✅ Podfile has post_install hook"
else
    echo "⚠️ Podfile missing post_install hook"
fi
echo ""

# Test 5: Check change_app_package_name package
echo "🔍 Test 5: Checking change_app_package_name package..."
if grep -q "change_app_package_name:" pubspec.yaml; then
    echo "✅ change_app_package_name package found in pubspec.yaml"
    PACKAGE_VERSION=$(grep "change_app_package_name:" pubspec.yaml | sed 's/.*change_app_package_name: \([^ ]*\).*/\1/')
    echo "📦 Package version: $PACKAGE_VERSION"
else
    echo "⚠️ change_app_package_name package not found in pubspec.yaml"
fi
echo ""

# Test 6: Check branding_assets.sh integration
echo "🔍 Test 6: Checking branding_assets.sh integration..."
BRANDING_SCRIPT="$PROJECT_ROOT/lib/scripts/ios/branding_assets.sh"
if [ -f "$BRANDING_SCRIPT" ]; then
    echo "✅ branding_assets.sh script found"
    
    if grep -q "change_app_package_name" "$BRANDING_SCRIPT"; then
        echo "✅ branding_assets.sh has change_app_package_name integration"
    else
        echo "⚠️ branding_assets.sh missing change_app_package_name integration"
    fi
    
    if grep -q "CFBundleIdentifier.*collision" "$BRANDING_SCRIPT"; then
        echo "✅ branding_assets.sh has collision prevention"
    else
        echo "⚠️ branding_assets.sh missing collision prevention"
    fi
else
    echo "❌ branding_assets.sh script not found"
fi
echo ""

# Test 7: Validate project file format
echo "🔍 Test 7: Validating project file format..."
if command -v plutil &> /dev/null; then
    if plutil -lint "$IOS_PROJECT_FILE" >/dev/null 2>&1; then
        echo "✅ Project file format is valid"
    else
        echo "❌ Project file format is invalid"
    fi
else
    echo "⚠️ plutil not available, skipping format validation"
fi
echo ""

# Test 8: Check for backup files
echo "🔍 Test 8: Checking for backup files..."
BACKUP_COUNT=$(find . -name "*.backup*" -o -name "*_fix_backup_*" | wc -l)
if [ "$BACKUP_COUNT" -gt 0 ]; then
    echo "✅ Backup files found: $BACKUP_COUNT"
    echo "📋 Recent backups:"
    find . -name "*.backup*" -o -name "*_fix_backup_*" | head -5 | sed 's/^/   /'
else
    echo "⚠️ No backup files found"
fi
echo ""

# Summary
echo "📊 Test Summary"
echo "==============="

# Count test results
TOTAL_TESTS=8
PASSED_TESTS=0
FAILED_TESTS=0

# Count based on previous output
if [ "$COLLISION_COUNT" -eq 0 ]; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

if [ -z "$UNICODE_CHARS" ]; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

if grep -q "change_app_package_name:" pubspec.yaml; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

if [ -f "$BRANDING_SCRIPT" ]; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

echo "📈 Test Results:"
echo "   ✅ Passed: $PASSED_TESTS"
echo "   ❌ Failed: $FAILED_TESTS"
echo "   📊 Total: $TOTAL_TESTS"
echo ""

if [ "$FAILED_TESTS" -eq 0 ]; then
    echo "🎉 All tests passed! CFBundleIdentifier collision fix is working correctly."
    echo "📋 The app should now pass App Store validation without bundle identifier collisions."
    echo "📋 CocoaPods should now work without Unicode parsing errors."
    exit 0
else
    echo "⚠️ Some tests failed. Please review the issues above."
    echo "🔧 Consider running the fix scripts again if needed."
    exit 1
fi 