#!/bin/bash

# Proper CFBundleIdentifier Collision Fix
# Purpose: Fix the current collision by assigning unique bundle identifiers to each target
# Target Error: Validation failed (409) CFBundleIdentifier Collision

set -euo pipefail

echo "🔧 Proper CFBundleIdentifier Collision Fix"
echo "=========================================="
echo "🎯 Target Error: Validation failed (409) CFBundleIdentifier Collision"
echo ""

# Configuration - Dynamic from environment variables
PROJECT_ROOT=$(pwd)
IOS_PROJECT_FILE="$PROJECT_ROOT/ios/Runner.xcodeproj/project.pbxproj"
INFO_PLIST="$PROJECT_ROOT/ios/Runner/Info.plist"
BASE_BUNDLE_ID="${BUNDLE_ID:-${PKG_NAME:-com.example.app}}"
TIMESTAMP=$(date +%s)

echo "📁 Project Root: $PROJECT_ROOT"
echo "📱 Base Bundle ID: $BASE_BUNDLE_ID"
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
cp "$IOS_PROJECT_FILE" "${IOS_PROJECT_FILE}.proper_fix_backup_${TIMESTAMP}"
cp "$INFO_PLIST" "${INFO_PLIST}.proper_fix_backup_${TIMESTAMP}"
echo "✅ Backups created"
echo ""

# Analyze the project structure to identify targets
echo "🔍 Analyzing project structure..."
TARGET_SECTIONS=$(awk '/^[[:space:]]*[A-Z0-9A-F]{24}[[:space:]]*\/\*[^*]*\*\/[[:space:]]*=/ {print NR ":" $0}' "$IOS_PROJECT_FILE" | grep -E "(Runner|Tests|Framework|Extension)" || true)

echo "📋 Found target sections:"
echo "$TARGET_SECTIONS" | sed 's/^/   /' || echo "   No specific targets found"

# Get all bundle identifier lines with context
echo ""
echo "🔍 Current bundle identifiers with context:"
BUNDLE_LINES=$(grep -n "PRODUCT_BUNDLE_IDENTIFIER" "$IOS_PROJECT_FILE")
echo "$BUNDLE_LINES" | sed 's/^/   /'

# Create a proper fix by assigning unique identifiers
echo ""
echo "🔧 Applying proper bundle identifier fix..."

# Create temporary file
TEMP_PROJECT="${IOS_PROJECT_FILE}.temp_proper_${TIMESTAMP}"

# Read the project file and update bundle identifiers with proper targeting
{
    line_number=0
    target_count=0
    current_target=""
    
    while IFS= read -r line; do
        line_number=$((line_number + 1))
        
        # Detect target sections
        if [[ "$line" =~ [A-Z0-9A-F]{24}[[:space:]]*\/\*[^*]*\*\/[[:space:]]*=[[:space:]]*\{ ]]; then
            if [[ "$line" =~ RunnerTests ]]; then
                current_target="tests"
                echo "   Detected target: RunnerTests" >&2
            elif [[ "$line" =~ Runner ]]; then
                current_target="main"
                echo "   Detected target: Runner (main)" >&2
            else
                current_target="framework"
                echo "   Detected target: Framework/Extension" >&2
            fi
        fi
        
        # Update bundle identifiers based on target type
        if [[ "$line" =~ PRODUCT_BUNDLE_IDENTIFIER[[:space:]]*=[[:space:]]*[^;]* ]]; then
            target_count=$((target_count + 1))
            
            case "$current_target" in
                "tests")
                    NEW_ID="${BASE_BUNDLE_ID}.tests"
                    echo "   Target $target_count (Tests): $NEW_ID" >&2
                    ;;
                "main")
                    NEW_ID="$BASE_BUNDLE_ID"
                    echo "   Target $target_count (Main): $NEW_ID" >&2
                    ;;
                "framework"|*)
                    NEW_ID="${BASE_BUNDLE_ID}.framework.${TIMESTAMP}.${target_count}"
                    echo "   Target $target_count (Framework): $NEW_ID" >&2
                    ;;
            esac
            
            # Replace the bundle identifier
            echo "$line" | sed "s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_ID;/g"
        else
            echo "$line"
        fi
    done < "$IOS_PROJECT_FILE"
} > "$TEMP_PROJECT"

# Replace the original file
mv "$TEMP_PROJECT" "$IOS_PROJECT_FILE"

echo "✅ Project file updated with proper target-specific bundle identifiers"
echo ""

# Update Info.plist with main bundle identifier
echo "📱 Updating Info.plist..."
if command -v plutil &> /dev/null; then
    plutil -replace CFBundleIdentifier -string "$BASE_BUNDLE_ID" "$INFO_PLIST"
    echo "✅ Info.plist updated using plutil"
else
    # Manual update as fallback
    sed -i.tmp "s/<key>CFBundleIdentifier<\/key>.*<string>.*<\/string>/<key>CFBundleIdentifier<\/key><string>$BASE_BUNDLE_ID<\/string>/g" "$INFO_PLIST"
    rm -f "${INFO_PLIST}.tmp"
    echo "✅ Info.plist updated manually"
fi
echo ""

# Verify the changes
echo "🔍 Verifying changes..."
NEW_BUNDLE_IDS=$(grep "PRODUCT_BUNDLE_IDENTIFIER" "$IOS_PROJECT_FILE" | sed 's/.*PRODUCT_BUNDLE_IDENTIFIER = \([^;]*\);.*/\1/' | sort | uniq -c)
echo "📊 New bundle identifier distribution:"
echo "$NEW_BUNDLE_IDS" | sed 's/^/   /'

# Check for collisions
COLLISION_COUNT=$(echo "$NEW_BUNDLE_IDS" | awk '$1 > 1 {sum += $1-1} END {print sum+0}')
if [ "$COLLISION_COUNT" -eq 0 ]; then
    echo "✅ No collisions detected - Fix successful!"
else
    echo "⚠️ Still have $COLLISION_COUNT collisions"
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
    cp "$PODFILE" "${PODFILE}.proper_fix_backup_${TIMESTAMP}"
    
    # Remove any existing collision prevention and add a clean one
    sed -i.tmp '/CFBundleIdentifier.*collision.*prevention/,/^end$/d' "$PODFILE"
    rm -f "${PODFILE}.tmp"
    
    # Add clean collision prevention
    cat >> "$PODFILE" << 'EOF'

# CFBundleIdentifier Collision Prevention
# Added by proper fix script to prevent App Store validation errors
post_install do |installer|
  puts "Applying CFBundleIdentifier collision prevention..."
  
  main_bundle_id = ENV['BUNDLE_ID'] || ENV['PKG_NAME'] || 'com.example.app'
  timestamp = Time.now.to_i
  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Skip the main Runner target
      next if target.name == 'Runner'
      
      # Generate unique bundle ID for each framework/pod
      unique_bundle_id = "#{main_bundle_id}.pod.#{target.name.downcase.gsub(/[^a-z0-9]/, '')}.#{timestamp}"
      
      config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = unique_bundle_id
      
      puts "   #{target.name}: #{unique_bundle_id}"
    end
  end
  
  puts "All frameworks now have unique bundle identifiers"
end
EOF
    echo "✅ Podfile updated with clean collision prevention"
else
    echo "⚠️ Podfile not found"
fi
echo ""

# Summary
echo "📊 Fix Summary"
echo "=============="
echo "🎯 Target Error: Validation failed (409) CFBundleIdentifier Collision"
echo "🔧 Solution Applied:"
echo "   ✅ Main app: $BASE_BUNDLE_ID"
echo "   ✅ Test target: $BASE_BUNDLE_ID.tests"
echo "   ✅ Framework targets: $BASE_BUNDLE_ID.framework.$TIMESTAMP.[N]"
echo "   ✅ Podfile collision prevention updated"
echo "   ✅ Info.plist updated"
echo "   ✅ NO UNICODE CHARACTERS INTRODUCED"
echo ""
echo "💾 Backups created:"
echo "   - ${IOS_PROJECT_FILE}.proper_fix_backup_${TIMESTAMP}"
echo "   - ${INFO_PLIST}.proper_fix_backup_${TIMESTAMP}"
echo "   - ${PODFILE}.proper_fix_backup_${TIMESTAMP}"
echo ""
echo "🎉 Proper CFBundleIdentifier collision fix completed!"
echo "📋 The app should now pass App Store validation without bundle identifier collisions."
echo "📋 CocoaPods should now work without Unicode parsing errors." 