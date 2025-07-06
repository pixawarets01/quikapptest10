#!/bin/bash

# iOS Icon Transparency Validator
# Purpose: Check all iOS app icons for transparency issues that cause App Store rejection
# Fixes: Validation failed (409) Invalid large app icon transparency error

set -e

echo "🔍 iOS App Icon Transparency Validator"
echo "======================================="
echo "Checking for App Store validation error (409): Invalid large app icon transparency"
echo ""

# Check if we're in a Flutter project
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: This script must be run from the root of a Flutter project"
    exit 1
fi

# Check if iOS app icon directory exists
ICON_DIR="ios/Runner/Assets.xcassets/AppIcon.appiconset"
if [ ! -d "$ICON_DIR" ]; then
    echo "❌ Error: iOS app icon directory not found: $ICON_DIR"
    echo "💡 Run flutter_launcher_icons first to generate iOS icons"
    exit 1
fi

echo "📁 Checking directory: $ICON_DIR"
echo ""

# Variables for tracking
total_icons=0
compliant_icons=0
non_compliant_icons=0
critical_issue=false

# Check all PNG files
echo "🔍 Analyzing iOS app icons for transparency..."
echo "=============================================="

find "$ICON_DIR" -name "*.png" | sort | while read -r icon_file; do
    if [ -f "$icon_file" ]; then
        filename=$(basename "$icon_file")
        total_icons=$((total_icons + 1))
        
        echo -n "📋 Checking: $filename ... "
        
        if command -v file &> /dev/null; then
            file_info=$(file "$icon_file")
            
            if echo "$file_info" | grep -q "with alpha\|RGBA"; then
                echo "❌ HAS TRANSPARENCY (App Store will reject!)"
                non_compliant_icons=$((non_compliant_icons + 1))
                
                # Check if this is the critical 1024x1024 icon
                if [[ "$filename" == *"1024x1024"* ]]; then
                    echo "   🚨 CRITICAL: This is the 1024x1024 marketing icon!"
                    echo "   🚨 App Store error: Invalid large app icon transparency"
                    critical_issue=true
                fi
            else
                echo "✅ COMPLIANT (no transparency)"
                compliant_icons=$((compliant_icons + 1))
            fi
            
            # Show detailed file properties
            echo "   📋 Properties: $file_info"
        else
            echo "⚠️ Cannot check (file command not available)"
        fi
        
        echo ""
    fi
done

echo "📊 VALIDATION SUMMARY"
echo "===================="
echo "Total icons checked: $total_icons"
echo "Compliant icons: $compliant_icons"
echo "Non-compliant icons: $non_compliant_icons"
echo ""

# Special focus on critical 1024x1024 icon
echo "🔍 CRITICAL ICON CHECK: 1024x1024 Marketing Icon"
echo "================================================"

critical_icon="$ICON_DIR/Icon-App-1024x1024@1x.png"
if [ -f "$critical_icon" ]; then
    echo "📋 Found: Icon-App-1024x1024@1x.png"
    
    if command -v file &> /dev/null; then
        critical_info=$(file "$critical_icon")
        echo "📋 Properties: $critical_info"
        
        if echo "$critical_info" | grep -q "with alpha\|RGBA"; then
            echo "❌ CRITICAL FAILURE: 1024x1024 icon has transparency!"
            echo "❌ App Store will reject with error (409)"
            echo "❌ Error message: 'Invalid large app icon. The large app icon in the asset catalog in \"Runner.app\" can't be transparent or contain an alpha channel.'"
            critical_issue=true
        else
            echo "✅ SUCCESS: 1024x1024 icon is App Store compliant!"
        fi
    fi
else
    echo "❌ CRITICAL: 1024x1024 icon not found!"
    critical_issue=true
fi

echo ""
echo "🎯 FINAL RESULT"
echo "==============="

if [ "$critical_issue" = true ] || [ "$non_compliant_icons" -gt 0 ]; then
    echo "❌ VALIDATION FAILED"
    echo "❌ App Store will reject this build with error (409)"
    echo "❌ Transparency must be removed from ALL iOS icons"
    echo ""
    echo "🔧 SOLUTIONS:"
    echo "1. Run: ./generate_ios_icons.sh (standalone fix)"
    echo "2. Or rebuild with ios-workflow (automatic fix)"
    echo "3. Or run flutter_launcher_icons with remove_alpha_ios: true"
    exit 1
else
    echo "✅ VALIDATION PASSED"
    echo "✅ All iOS icons are App Store compliant"
    echo "✅ No transparency issues detected"
    echo "✅ Ready for App Store submission"
    echo ""
    echo "🎉 SUCCESS: No more 'Invalid large app icon' errors!"
fi 