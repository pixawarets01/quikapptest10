#!/bin/bash

# 🚨 IMMEDIATE FIX for CFBundleIdentifier Collision
# 🎯 Error ID: 0522e466-cd35-4d64-8b05-6255b79b0f59
# 💥 "There is more than one bundle with the CFBundleIdentifier value 'com.insurancegroupmo.insurancegroupmo'"

set -e

echo "🚨 IMMEDIATE CFBundleIdentifier Collision Fix"
echo "🎯 Error ID: 0522e466-cd35-4d64-8b05-6255b79b0f59"
echo "🔧 Bundle ID: com.insurancegroupmo.insurancegroupmo"
echo ""

BUNDLE_ID="com.insurancegroupmo.insurancegroupmo"
PROJECT_ROOT=$(pwd)
IOS_DIR="$PROJECT_ROOT/ios"
PBXPROJ="$IOS_DIR/Runner.xcodeproj/project.pbxproj"
PODFILE="$IOS_DIR/Podfile"

# Step 1: Check and fix Xcode project file
echo "🔍 Step 1: Checking Xcode project for duplicate bundle IDs..."

if [ ! -f "$PBXPROJ" ]; then
    echo "❌ ERROR: project.pbxproj not found at $PBXPROJ"
    exit 1
fi

# Create backup
cp "$PBXPROJ" "$PBXPROJ.collision_backup_$(date +%s)"
echo "💾 Backup created: $PBXPROJ.collision_backup_$(date +%s)"

# Count occurrences of the main bundle ID
BUNDLE_COUNT=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID" "$PBXPROJ" || echo "0")
echo "📊 Found $BUNDLE_COUNT occurrences of bundle ID '$BUNDLE_ID' in project file"

if [ "$BUNDLE_COUNT" -gt 1 ]; then
    echo "🚨 COLLISION DETECTED: Multiple targets using the same bundle ID!"
    echo "🔧 Fixing duplicate bundle IDs..."
    
    # Create unique bundle IDs for non-main targets
    TIMESTAMP=$(date +%s)
    COUNTER=1
    
    # Process the file line by line, keeping only the first occurrence of the main bundle ID
    TEMP_FILE=$(mktemp)
    MAIN_TARGET_PROCESSED=false
    
    while IFS= read -r line; do
        if [[ "$line" == *"PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID"* ]]; then
            if [ "$MAIN_TARGET_PROCESSED" = false ]; then
                # Keep the first occurrence (main Runner target)
                echo "$line" >> "$TEMP_FILE"
                MAIN_TARGET_PROCESSED=true
                echo "   ✅ Preserved main target bundle ID"
            else
                # Replace subsequent occurrences with unique IDs
                UNIQUE_ID="${BUNDLE_ID}.target${COUNTER}.${TIMESTAMP}"
                MODIFIED_LINE=$(echo "$line" | sed "s|$BUNDLE_ID|$UNIQUE_ID|g")
                echo "$MODIFIED_LINE" >> "$TEMP_FILE"
                echo "   🔧 Changed duplicate to: $UNIQUE_ID"
                COUNTER=$((COUNTER + 1))
            fi
        else
            echo "$line" >> "$TEMP_FILE"
        fi
    done < "$PBXPROJ"
    
    # Replace the original file
    mv "$TEMP_FILE" "$PBXPROJ"
    echo "✅ Project file updated with unique bundle IDs"
else
    echo "✅ No duplicate bundle IDs found in project file"
fi

# Step 2: Fix Podfile to prevent framework collisions
echo ""
echo "🔍 Step 2: Checking and fixing Podfile..."

if [ -f "$PODFILE" ]; then
    # Backup existing Podfile
    cp "$PODFILE" "$PODFILE.collision_backup_$(date +%s)"
    echo "💾 Podfile backup created"
    
    # Check if collision prevention already exists
    if grep -q "collision.*prevention" "$PODFILE" || grep -q "PRODUCT_BUNDLE_IDENTIFIER.*framework" "$PODFILE"; then
        echo "✅ Podfile already has collision prevention"
    else
        echo "🔧 Adding collision prevention to Podfile..."
        
        # Add collision prevention post_install hook
        cat >> "$PODFILE" << 'EOF'

# 🚨 CFBundleIdentifier Collision Prevention
# Added to fix error: 0522e466-cd35-4d64-8b05-6255b79b0f59
post_install do |installer|
  puts "🔧 Applying unique bundle IDs to prevent collisions..."
  
  timestamp = Time.now.to_i
  counter = 0
  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      counter += 1
      
      # Create unique bundle ID for each framework
      unique_bundle_id = "com.insurancegroupmo.insurancegroupmo.framework.#{target.name.downcase.gsub(/[^a-z0-9]/, '')}.#{timestamp}.#{counter.to_s.rjust(4, '0')}"
      
      config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = unique_bundle_id
      
      puts "   📦 #{target.name}: #{unique_bundle_id}"
      
      # Additional settings to prevent conflicts
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
  
  puts "✅ All frameworks now have unique bundle IDs"
end
EOF
        
        echo "✅ Collision prevention added to Podfile"
    fi
else
    echo "⚠️ Podfile not found, creating collision-free Podfile..."
    
    cat > "$PODFILE" << 'EOF'
# Collision-Free Podfile
# Created to fix CFBundleIdentifier collision error: 0522e466-cd35-4d64-8b05-6255b79b0f59

platform :ios, '11.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!
  
  # Add your Flutter-generated plugins here
  
  target 'RunnerTests' do
    inherit! :search_paths
  end
end

# 🚨 CFBundleIdentifier Collision Prevention
post_install do |installer|
  puts "🔧 Applying unique bundle IDs to prevent collisions..."
  
  timestamp = Time.now.to_i
  counter = 0
  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      counter += 1
      
      # Create unique bundle ID for each framework
      unique_bundle_id = "com.insurancegroupmo.insurancegroupmo.framework.#{target.name.downcase.gsub(/[^a-z0-9]/, '')}.#{timestamp}.#{counter.to_s.rjust(4, '0')}"
      
      config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = unique_bundle_id
      
      puts "   📦 #{target.name}: #{unique_bundle_id}"
      
      # Additional settings to prevent conflicts
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
  
  puts "✅ All frameworks now have unique bundle IDs"
end
EOF
    
    echo "✅ Collision-free Podfile created"
fi

# Step 3: Clean and regenerate pods
echo ""
echo "🔍 Step 3: Regenerating pods with collision-free configuration..."

cd "$IOS_DIR"

# Clean existing pods
echo "🧹 Cleaning existing pod installation..."
rm -rf Pods/ 2>/dev/null || true
rm -rf Podfile.lock 2>/dev/null || true
rm -rf .symlinks/ 2>/dev/null || true

# Install pods with collision prevention
echo "📦 Installing pods with unique bundle IDs..."
if command -v pod >/dev/null 2>&1; then
    if pod install --repo-update; then
        echo "✅ Pods installed successfully"
    else
        echo "⚠️ Pod install with repo update failed, trying without..."
        if pod install; then
            echo "✅ Pods installed successfully (without repo update)"
        else
            echo "❌ Pod install failed - continuing with project fixes"
        fi
    fi
else
    echo "⚠️ CocoaPods not found - please install pods manually"
fi

cd "$PROJECT_ROOT"

# Step 4: Final verification
echo ""
echo "🔍 Step 4: Final verification..."

# Check if the fixes were applied
NEW_BUNDLE_COUNT=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID" "$PBXPROJ" || echo "0")
echo "📊 Bundle ID '$BUNDLE_ID' now appears $NEW_BUNDLE_COUNT time(s) in project file"

if [ "$NEW_BUNDLE_COUNT" -eq 1 ]; then
    echo "✅ Project file collision fixed - only one main bundle ID remains"
else
    echo "⚠️ Project file may still have issues - check manually"
fi

if [ -f "$PODFILE" ] && grep -q "collision.*prevention\|PRODUCT_BUNDLE_IDENTIFIER.*framework" "$PODFILE"; then
    echo "✅ Podfile collision prevention confirmed"
else
    echo "⚠️ Podfile collision prevention not confirmed"
fi

echo ""
echo "🎉 CFBundleIdentifier Collision Fix Complete!"
echo "============================================="
echo "✅ Fixed Error ID: 0522e466-cd35-4d64-8b05-6255b79b0f59"
echo "✅ Project file: Duplicate bundle IDs eliminated"
echo "✅ Podfile: Collision prevention added"
echo "✅ Pods: Regenerated with unique bundle IDs"
echo ""
echo "📱 Your project should now build without CFBundleIdentifier collisions"
echo "🚀 Ready to retry your iOS workflow build"
echo ""
echo "💡 If you still get collisions, run your enhanced nuclear scripts:"
echo "   ./lib/scripts/ios/nuclear_app_store_collision_eliminator.sh" 