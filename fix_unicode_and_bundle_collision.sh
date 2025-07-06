#!/bin/bash

# Fix Unicode Characters and Bundle Collision
# Purpose: Remove Unicode characters from project file and fix bundle identifier collisions
# Target Error: Invalid character "\xF0" in unquoted string

set -euo pipefail

echo "🔧 Fixing Unicode Characters and Bundle Collision"
echo "================================================="
echo "🎯 Target Error: Invalid character \"\\xF0\" in unquoted string"
echo ""

# Configuration - Dynamic from environment variables
PROJECT_ROOT=$(pwd)
IOS_PROJECT_FILE="$PROJECT_ROOT/ios/Runner.xcodeproj/project.pbxproj"
INFO_PLIST="$PROJECT_ROOT/ios/Runner/Info.plist"
NEW_BUNDLE_ID="${BUNDLE_ID:-${PKG_NAME:-com.example.app}}"
TIMESTAMP=$(date +%s)

echo "📁 Project Root: $PROJECT_ROOT"
echo "📱 New Bundle ID: $NEW_BUNDLE_ID"
echo "⏰ Timestamp: $TIMESTAMP"
echo ""

# Step 1: Create backup
echo "📋 Step 1: Creating backup..."
cp "$IOS_PROJECT_FILE" "${IOS_PROJECT_FILE}.unicode_fix_backup_${TIMESTAMP}"
cp "$INFO_PLIST" "${INFO_PLIST}.unicode_fix_backup_${TIMESTAMP}"
echo "✅ Backups created"

# Step 2: Remove all Unicode characters from project file
echo "📋 Step 2: Removing Unicode characters..."
# Remove all non-ASCII characters (including emojis)
LC_ALL=C sed -i.tmp 's/[^\x00-\x7F]//g' "$IOS_PROJECT_FILE"
rm -f "${IOS_PROJECT_FILE}.tmp"
echo "✅ Unicode characters removed"

# Step 3: Fix bundle identifier collisions
echo "📋 Step 3: Fixing bundle identifier collisions..."

# Read the project file and update bundle identifiers
{
    local line_number=0
    local target_count=0
    
    while IFS= read -r line; do
        line_number=$((line_number + 1))
        
        if [[ "$line" =~ PRODUCT_BUNDLE_IDENTIFIER[[:space:]]*=[[:space:]]*[^;]* ]]; then
            target_count=$((target_count + 1))
            
            # Determine target type based on context
            if [[ "$line" =~ \.tests ]]; then
                # Test target
                NEW_ID="${NEW_BUNDLE_ID}.tests"
                echo "   Target $target_count (Test): $NEW_ID"
            elif [[ "$line" =~ \.framework ]]; then
                # Framework target
                NEW_ID="${NEW_BUNDLE_ID}.framework.${TIMESTAMP}"
                echo "   Target $target_count (Framework): $NEW_ID"
            elif [[ "$line" =~ \.extension ]]; then
                # Extension target
                NEW_ID="${NEW_BUNDLE_ID}.extension.${TIMESTAMP}"
                echo "   Target $target_count (Extension): $NEW_ID"
            else
                # Main app target
                NEW_ID="$NEW_BUNDLE_ID"
                echo "   Target $target_count (Main App): $NEW_ID"
            fi
            
            # Replace the bundle identifier (CLEAN - NO UNICODE)
            echo "$line" | sed "s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_ID;/g"
        else
            echo "$line"
        fi
    done < "$IOS_PROJECT_FILE"
} > "${IOS_PROJECT_FILE}.tmp"

# Replace the original file
mv "${IOS_PROJECT_FILE}.tmp" "$IOS_PROJECT_FILE"

echo "✅ Bundle identifiers updated for $target_count targets"

# Step 4: Update Info.plist
echo "📋 Step 4: Updating Info.plist..."
if [ -f "$INFO_PLIST" ]; then
    # Remove Unicode characters from Info.plist
    LC_ALL=C sed -i.tmp 's/[^\x00-\x7F]//g' "$INFO_PLIST"
    
    # Update CFBundleIdentifier
    if command -v plutil &> /dev/null; then
        plutil -replace CFBundleIdentifier -string "$NEW_BUNDLE_ID" "$INFO_PLIST" 2>/dev/null || {
            echo "⚠️ plutil failed, trying manual update..."
            sed -i.tmp "s/<key>CFBundleIdentifier<\/key>.*<string>.*<\/string>/<key>CFBundleIdentifier<\/key><string>$NEW_BUNDLE_ID<\/string>/g" "$INFO_PLIST"
        }
    else
        sed -i.tmp "s/<key>CFBundleIdentifier<\/key>.*<string>.*<\/string>/<key>CFBundleIdentifier<\/key><string>$NEW_BUNDLE_ID<\/string>/g" "$INFO_PLIST"
    fi
    
    rm -f "${INFO_PLIST}.tmp"
    echo "✅ Info.plist updated"
else
    echo "⚠️ Info.plist not found: $INFO_PLIST"
fi

# Step 5: Update Podfile for collision prevention
echo "📋 Step 5: Updating Podfile for collision prevention..."
PODFILE="$PROJECT_ROOT/ios/Podfile"
if [ -f "$PODFILE" ]; then
    # Create backup
    cp "$PODFILE" "${PODFILE}.unicode_fix_backup_${TIMESTAMP}"
    
    # Remove Unicode characters from Podfile
    LC_ALL=C sed -i.tmp 's/[^\x00-\x7F]//g' "$PODFILE"
    
    # Add collision prevention post_install hook if not already present
    if ! grep -q "CFBundleIdentifier.*collision.*prevention" "$PODFILE"; then
        cat >> "$PODFILE" << 'EOF'

# CFBundleIdentifier Collision Prevention
# Added by fix_unicode_and_bundle_collision.sh to prevent App Store validation errors
post_install do |installer|
  puts "Applying CFBundleIdentifier collision prevention..."
  
  # Use dynamic bundle ID from environment
  main_bundle_id = ENV['BUNDLE_ID'] || ENV['PKG_NAME'] || 'com.example.app'
  timestamp = Time.now.to_i
  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Skip the main Runner target
      next if target.name == 'Runner'
      
      # Generate unique bundle ID for each framework/pod
      unique_bundle_id = "#{main_bundle_id}.framework.#{target.name.downcase.gsub(/[^a-z0-9]/, '')}.#{timestamp}"
      
      config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = unique_bundle_id
      
      puts "   #{target.name}: #{unique_bundle_id}"
    end
  end
  
  puts "All frameworks now have unique bundle identifiers"
end
EOF
        echo "✅ Podfile updated with collision prevention"
    else
        echo "✅ Podfile already has collision prevention"
    fi
    
    rm -f "${PODFILE}.tmp"
else
    echo "⚠️ Podfile not found: $PODFILE"
fi

# Step 6: Verify the fix
echo "📋 Step 6: Verifying the fix..."

# Check for Unicode characters
unicode_chars=$(grep -n '[^\x00-\x7F]' "$IOS_PROJECT_FILE" | head -5 || true)
if [ -z "$unicode_chars" ]; then
    echo "✅ No Unicode characters found in project file"
else
    echo "⚠️ Unicode characters still found:"
    echo "$unicode_chars" | sed 's/^/   /'
fi

# Check bundle identifiers
bundle_ids=$(grep "PRODUCT_BUNDLE_IDENTIFIER" "$IOS_PROJECT_FILE" | sed 's/.*PRODUCT_BUNDLE_IDENTIFIER = \([^;]*\);.*/\1/' | sort | uniq -c)
collision_count=$(echo "$bundle_ids" | awk '$1 > 1 {sum += $1-1} END {print sum+0}')

echo "📊 Bundle identifier distribution:"
echo "$bundle_ids" | sed 's/^/   /'

if [ "$collision_count" -eq 0 ]; then
    echo "✅ No collisions detected - Fix successful!"
else
    echo "⚠️ Still have $collision_count collisions"
fi

# Check Info.plist
if [ -f "$INFO_PLIST" ]; then
    plist_bundle_id=$(plutil -extract CFBundleIdentifier raw "$INFO_PLIST" 2>/dev/null || echo "NOT_FOUND")
    if [ "$plist_bundle_id" = "$NEW_BUNDLE_ID" ]; then
        echo "✅ Info.plist bundle identifier updated correctly"
    else
        echo "⚠️ Info.plist bundle identifier: $plist_bundle_id (expected: $NEW_BUNDLE_ID)"
    fi
fi

echo ""
echo "🎉 Unicode and Bundle Collision Fix completed!"
echo "📋 Summary:"
echo "   - Unicode characters removed from project files"
echo "   - Bundle identifiers updated for all targets"
echo "   - Collision prevention applied"
echo "   - Backups created with timestamp: $TIMESTAMP"
echo ""
echo "📋 Files updated:"
echo "   - $IOS_PROJECT_FILE"
echo "   - $INFO_PLIST"
echo "   - $PODFILE"
echo ""
echo "📋 Backups created:"
echo "   - ${IOS_PROJECT_FILE}.unicode_fix_backup_${TIMESTAMP}"
echo "   - ${INFO_PLIST}.unicode_fix_backup_${TIMESTAMP}"
echo "   - ${PODFILE}.unicode_fix_backup_${TIMESTAMP}"

exit 0 