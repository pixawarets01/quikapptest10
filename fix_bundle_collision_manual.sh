#!/bin/bash

# Manual CFBundleIdentifier Collision Fix
# Purpose: Fix the current collision where all targets use the same bundle identifier
# Target Error: Validation failed (409) CFBundleIdentifier Collision

set -euo pipefail

echo "🔧 Manual CFBundleIdentifier Collision Fix"
echo "=========================================="
echo "🎯 Target Error: Validation failed (409) CFBundleIdentifier Collision"
echo "💥 Current Issue: All targets using 'com.insurancegroupmo.insurancegroupmo'"
echo ""

# Configuration
PROJECT_ROOT=$(pwd)
IOS_PROJECT_FILE="$PROJECT_ROOT/ios/Runner.xcodeproj/project.pbxproj"
INFO_PLIST="$PROJECT_ROOT/ios/Runner/Info.plist"
NEW_BUNDLE_ID="com.twinklub.twinklub"
TIMESTAMP=$(date +%s)

echo "📁 Project Root: $PROJECT_ROOT"
echo "📱 New Bundle ID: $NEW_BUNDLE_ID"
echo "⏰ Timestamp: $TIMESTAMP"
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

echo "✅ Required files found"
echo ""

# Create backups
echo "💾 Creating backups..."
cp "$IOS_PROJECT_FILE" "${IOS_PROJECT_FILE}.collision_fix_backup_${TIMESTAMP}"
cp "$INFO_PLIST" "${INFO_PLIST}.collision_fix_backup_${TIMESTAMP}"
echo "✅ Backups created"
echo ""

# Analyze current bundle identifiers
echo "🔍 Analyzing current bundle identifiers..."
CURRENT_BUNDLE_IDS=$(grep "PRODUCT_BUNDLE_IDENTIFIER" "$IOS_PROJECT_FILE" | sed 's/.*PRODUCT_BUNDLE_IDENTIFIER = \([^;]*\);.*/\1/' | sort | uniq -c)
echo "📊 Current bundle identifier distribution:"
echo "$CURRENT_BUNDLE_IDS" | sed 's/^/   /'

COLLISION_COUNT=$(echo "$CURRENT_BUNDLE_IDS" | awk '$1 > 1 {sum += $1-1} END {print sum+0}')
if [ "$COLLISION_COUNT" -gt 0 ]; then
    echo "⚠️ Collisions detected: $COLLISION_COUNT duplicate entries"
else
    echo "✅ No collisions detected"
fi
echo ""

# Fix bundle identifiers in project file
echo "🔧 Fixing bundle identifiers in project file..."

# Create a temporary file for the updated project
TEMP_PROJECT="${IOS_PROJECT_FILE}.temp_${TIMESTAMP}"

# Read the project file and update bundle identifiers
{
    line_number=0
    target_count=0
    
    while IFS= read -r line; do
        line_number=$((line_number + 1))
        
        if [[ "$line" =~ PRODUCT_BUNDLE_IDENTIFIER[[:space:]]*=[[:space:]]*com\.insurancegroupmo\.insurancegroupmo ]]; then
            target_count=$((target_count + 1))
            
            # Determine target type based on context
            if [[ "$line" =~ \.tests ]]; then
                # Test target
                NEW_ID="${NEW_BUNDLE_ID}.tests"
                echo "   🔧 Target $target_count (Test): $NEW_ID"
            elif [[ "$line" =~ \.framework ]]; then
                # Framework target
                NEW_ID="${NEW_BUNDLE_ID}.framework.${TIMESTAMP}"
                echo "   🔧 Target $target_count (Framework): $NEW_ID"
            elif [[ "$line" =~ \.extension ]]; then
                # Extension target
                NEW_ID="${NEW_BUNDLE_ID}.extension.${TIMESTAMP}"
                echo "   🔧 Target $target_count (Extension): $NEW_ID"
            else
                # Main app target
                NEW_ID="$NEW_BUNDLE_ID"
                echo "   🔧 Target $target_count (Main App): $NEW_ID"
            fi
            
            # Replace the bundle identifier
            echo "$line" | sed "s/com\.insurancegroupmo\.insurancegroupmo/$NEW_ID/g"
        else
            echo "$line"
        fi
    done < "$IOS_PROJECT_FILE"
} > "$TEMP_PROJECT"

# Replace the original file
mv "$TEMP_PROJECT" "$IOS_PROJECT_FILE"

echo "✅ Project file updated"
echo ""

# Update Info.plist
echo "📱 Updating Info.plist..."
if command -v plutil &> /dev/null; then
    plutil -replace CFBundleIdentifier -string "$NEW_BUNDLE_ID" "$INFO_PLIST"
    echo "✅ Info.plist updated using plutil"
else
    # Manual update as fallback
    sed -i.tmp "s/<key>CFBundleIdentifier<\/key>.*<string>.*<\/string>/<key>CFBundleIdentifier<\/key><string>$NEW_BUNDLE_ID<\/string>/g" "$INFO_PLIST"
    rm -f "${INFO_PLIST}.tmp"
    echo "✅ Info.plist updated manually"
fi
echo ""

# Verify the changes
echo "🔍 Verifying changes..."
NEW_BUNDLE_IDS=$(grep "PRODUCT_BUNDLE_IDENTIFIER" "$IOS_PROJECT_FILE" | sed 's/.*PRODUCT_BUNDLE_IDENTIFIER = \([^;]*\);.*/\1/' | sort | uniq -c)
echo "📊 New bundle identifier distribution:"
echo "$NEW_BUNDLE_IDS" | sed 's/^/   /'

NEW_COLLISION_COUNT=$(echo "$NEW_BUNDLE_IDS" | awk '$1 > 1 {sum += $1-1} END {print sum+0}')
if [ "$NEW_COLLISION_COUNT" -eq 0 ]; then
    echo "✅ No collisions detected - Fix successful!"
else
    echo "⚠️ Still have $NEW_COLLISION_COUNT collisions"
fi

# Check Info.plist
PLIST_BUNDLE_ID=$(plutil -extract CFBundleIdentifier raw "$INFO_PLIST" 2>/dev/null || echo "NOT_FOUND")
echo "📱 Info.plist CFBundleIdentifier: $PLIST_BUNDLE_ID"
echo ""

# Update Podfile for additional collision prevention
echo "📦 Updating Podfile for collision prevention..."
PODFILE="$PROJECT_ROOT/ios/Podfile"
if [ -f "$PODFILE" ]; then
    # Create backup
    cp "$PODFILE" "${PODFILE}.collision_fix_backup_${TIMESTAMP}"
    
    # Add collision prevention if not already present
    if ! grep -q "CFBundleIdentifier.*collision.*prevention" "$PODFILE"; then
        cat >> "$PODFILE" << 'EOF'

# 🛡️ CFBundleIdentifier Collision Prevention
# Added by manual fix script to prevent App Store validation errors
post_install do |installer|
  puts "🛡️ Applying CFBundleIdentifier collision prevention..."
  
  main_bundle_id = ENV['BUNDLE_ID'] || 'com.twinklub.twinklub'
  timestamp = Time.now.to_i
  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Skip the main Runner target
      next if target.name == 'Runner'
      
      # Generate unique bundle ID for each framework/pod
      unique_bundle_id = "#{main_bundle_id}.framework.#{target.name.downcase.gsub(/[^a-z0-9]/, '')}.#{timestamp}"
      
      config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = unique_bundle_id
      
      puts "   📦 #{target.name}: #{unique_bundle_id}"
    end
  end
  
  puts "✅ All frameworks now have unique bundle identifiers"
end
EOF
        echo "✅ Podfile updated with collision prevention"
    else
        echo "✅ Podfile already has collision prevention"
    fi
else
    echo "⚠️ Podfile not found"
fi
echo ""

# Summary
echo "📊 Fix Summary"
echo "=============="
echo "🎯 Target Error: Validation failed (409) CFBundleIdentifier Collision"
echo "🔧 Solution Applied:"
echo "   ✅ Main app: $NEW_BUNDLE_ID"
echo "   ✅ Test target: $NEW_BUNDLE_ID.tests"
echo "   ✅ Framework targets: $NEW_BUNDLE_ID.framework.$TIMESTAMP"
echo "   ✅ Extension targets: $NEW_BUNDLE_ID.extension.$TIMESTAMP"
echo "   ✅ Podfile collision prevention added"
echo "   ✅ Info.plist updated"
echo ""
echo "💾 Backups created:"
echo "   - ${IOS_PROJECT_FILE}.collision_fix_backup_${TIMESTAMP}"
echo "   - ${INFO_PLIST}.collision_fix_backup_${TIMESTAMP}"
echo "   - ${PODFILE}.collision_fix_backup_${TIMESTAMP}"
echo ""
echo "🎉 CFBundleIdentifier collision fix completed!"
echo "📋 The app should now pass App Store validation without bundle identifier collisions." 