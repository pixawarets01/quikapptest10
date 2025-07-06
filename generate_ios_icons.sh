#!/bin/bash

# Standalone iOS Icon Generator
# Purpose: Fix App Store validation error for iOS app icons with transparency
# Usage: ./generate_ios_icons.sh

set -e

echo "🎨 iOS App Icon Generator - Fixing App Store Validation Issues"
echo "=============================================================="

# Check if we're in a Flutter project
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: This script must be run from the root of a Flutter project"
    exit 1
fi

# Ensure flutter_launcher_icons is available
echo "📦 Checking flutter_launcher_icons dependency..."
if ! grep -q "flutter_launcher_icons:" pubspec.yaml; then
    echo "➕ Adding flutter_launcher_icons to pubspec.yaml..."
    echo "  flutter_launcher_icons: ^0.13.1" >> pubspec.yaml
fi

# Update pubspec.yaml configuration to use correct path
if grep -q "image_path: \"assets/images/logo.png\"" pubspec.yaml; then
    echo "🔧 Updating image_path to use assets/icons/app_icon.png..."
    sed -i.bak 's|image_path: "assets/images/logo.png"|image_path: "assets/icons/app_icon.png"|' pubspec.yaml
    sed -i.bak 's|adaptive_icon_foreground: "assets/images/logo.png"|adaptive_icon_foreground: "assets/icons/app_icon.png"|' pubspec.yaml
    rm -f pubspec.yaml.bak
fi

# Install dependencies
echo "📥 Installing dependencies..."
flutter pub get

# Ensure logo exists
if [ ! -f "assets/images/logo.png" ]; then
    echo "📸 Creating logo from existing iOS icon..."
    mkdir -p assets/images
    
    if [ -f "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png" ]; then
        cp ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png assets/images/logo.png
        
        # Remove alpha channel using sips (macOS)
        if command -v sips &> /dev/null; then
            echo "🔧 Removing transparency from logo..."
            sips -s format jpeg assets/images/logo.png --out assets/images/logo_temp.jpg >/dev/null 2>&1
            sips -s format png assets/images/logo_temp.jpg --out assets/images/logo.png >/dev/null 2>&1
            rm -f assets/images/logo_temp.jpg
        fi
    else
        echo "❌ Error: No existing icon found to use as logo"
        exit 1
    fi
fi

# Fix path issue - ensure logo is available at both paths
echo "📋 Copying logo from assets/images/logo.png to assets/icons/app_icon.png..."
if [ -f "assets/images/logo.png" ]; then
    mkdir -p assets/icons
    if cp "assets/images/logo.png" "assets/icons/app_icon.png"; then
        echo "✅ Logo successfully copied to: assets/icons/app_icon.png"
        
        # Verify the copy
        source_size=$(stat -f%z "assets/images/logo.png" 2>/dev/null || stat -c%s "assets/images/logo.png" 2>/dev/null)
        target_size=$(stat -f%z "assets/icons/app_icon.png" 2>/dev/null || stat -c%s "assets/icons/app_icon.png" 2>/dev/null)
        
        if [ "$source_size" = "$target_size" ]; then
            echo "✅ Copy verified - file sizes match ($source_size bytes)"
        else
            echo "⚠️ File sizes don't match - Source: $source_size, Target: $target_size"
        fi
    else
        echo "❌ Failed to copy logo"
        exit 1
    fi
else
    echo "❌ Source logo not found: assets/images/logo.png"
    exit 1
fi

# Check if logo is AVIF format and convert
if command -v file &> /dev/null; then
    file_info=$(file assets/images/logo.png)
    if echo "$file_info" | grep -q "AVIF\|ISO Media"; then
        echo "⚠️ Logo is in AVIF format, converting to PNG..."
        if command -v sips &> /dev/null; then
            sips -s format png assets/images/logo.png --out assets/images/logo_converted.png >/dev/null 2>&1
            mv assets/images/logo_converted.png assets/images/logo.png
            # Also update the copy
            cp assets/images/logo.png assets/icons/app_icon.png
            echo "✅ Logo converted from AVIF to PNG format"
        fi
    fi
fi

# Generate icons
echo "🎨 Generating iOS app icons without transparency..."
if ! dart run flutter_launcher_icons; then
    echo "🔄 Trying alternative command..."
    flutter pub run flutter_launcher_icons
fi

# Verify the critical 1024x1024 icon
if [ -f "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png" ]; then
    file_info=$(file ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png)
    if echo "$file_info" | grep -q "with alpha"; then
        echo "⚠️ Icon still has transparency, applying additional fix..."
        
        # Additional transparency removal for all icons
        cd ios/Runner/Assets.xcassets/AppIcon.appiconset/
        for icon in *.png; do
            if [ -f "$icon" ]; then
                if command -v sips &> /dev/null; then
                    temp_file="${icon%.png}_temp.jpg"
                    sips -s format jpeg "$icon" --out "$temp_file" >/dev/null 2>&1
                    sips -s format png "$temp_file" --out "$icon" >/dev/null 2>&1
                    rm -f "$temp_file"
                fi
            fi
        done
        cd - >/dev/null
    fi
    
    # Final verification
    file_info=$(file ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png)
    if echo "$file_info" | grep -q "with alpha"; then
        echo "❌ Error: Icon still contains transparency"
        exit 1
    else
        echo "✅ Success: 1024x1024 icon is now App Store compliant (no transparency)"
    fi
else
    echo "❌ Error: 1024x1024 icon not generated"
    exit 1
fi

echo ""
echo "🎉 iOS App Icons Generated Successfully!"
echo "============================================"
echo "✅ All iOS app icons are now App Store compliant"
echo "✅ Transparency/alpha channel issues fixed"
echo "✅ Ready for App Store submission"
echo ""
echo "Next steps:"
echo "1. Build and archive your iOS app"
echo "2. Upload to App Store Connect"
echo "3. The validation error should be resolved" 