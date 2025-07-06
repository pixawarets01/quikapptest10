#!/bin/bash

# Fix iOS Export Issues with Framework Signing
# This script handles the common issue where frameworks don't support provisioning profiles

set -euo pipefail

echo "🔧 Fixing iOS Export Issues with Framework Signing..."

# Load environment variables
if [ -f "$CM_ENV" ]; then
    set -a
    source "$CM_ENV"
    set +a
fi

# Use the actual certificate name if available, otherwise fallback to Apple Distribution
SIGNING_CERT="${CERT_NAME:-Apple Distribution}"
echo "🔍 Using signing certificate: $SIGNING_CERT"

# Create export directory
mkdir -p "$CM_BUILD_DIR/ios_output"

# Create ExportOptions.plist based on PROFILE_TYPE for proper distribution
echo "🎯 Creating ExportOptions.plist for PROFILE_TYPE: ${PROFILE_TYPE:-app-store}"

# Determine export method and settings based on profile type
case "${PROFILE_TYPE:-app-store}" in
    "app-store")
        EXPORT_METHOD="app-store"
        UPLOAD_SYMBOLS="true"
        UPLOAD_BITCODE="false"
        ;;
    "ad-hoc")
        EXPORT_METHOD="ad-hoc"
        UPLOAD_SYMBOLS="false"
        UPLOAD_BITCODE="false"
        ;;
    "enterprise")
        EXPORT_METHOD="enterprise"
        UPLOAD_SYMBOLS="false"
        UPLOAD_BITCODE="false"
        ;;
    "development")
        EXPORT_METHOD="development"
        UPLOAD_SYMBOLS="false"
        UPLOAD_BITCODE="false"
        ;;
    *)
        echo "⚠️ Unknown PROFILE_TYPE: ${PROFILE_TYPE}, defaulting to app-store"
        EXPORT_METHOD="app-store"
        UPLOAD_SYMBOLS="true"
        UPLOAD_BITCODE="false"
        ;;
esac

echo "📋 Export Configuration:"
echo "  - Method: $EXPORT_METHOD"
echo "  - Upload Symbols: $UPLOAD_SYMBOLS"
echo "  - Upload Bitcode: $UPLOAD_BITCODE"

cat > ExportOptions.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>$EXPORT_METHOD</string>
  <key>signingStyle</key>
  <string>automatic</string>
  <key>teamID</key>
  <string>$APPLE_TEAM_ID</string>
  <key>compileBitcode</key>
  <false/>
  <key>stripSwiftSymbols</key>
  <true/>
  <key>signingCertificate</key>
  <string>$SIGNING_CERT</string>
  <key>uploadBitcode</key>
  <$UPLOAD_BITCODE/>
  <key>uploadSymbols</key>
  <$UPLOAD_SYMBOLS/>
  <key>thinning</key>
  <string>&lt;none&gt;</string>
  <key>distributionBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>generateAppStoreInformation</key>
  <$([ "$EXPORT_METHOD" = "app-store" ] && echo "true" || echo "false")/>
  <key>manageVersionAndBuildNumber</key>
  <false/>
  <key>embedOnDemandResourcesProvisioningProfiles</key>
  <false/>
  <key>skipProvisioningProfiles</key>
  <false/>
  <key>provisioningProfiles</key>
  <dict>
    <key>$BUNDLE_ID</key>
    <string>$PROFILE_NAME</string>
  </dict>
EOF

# Add App Store specific configurations
if [ "$EXPORT_METHOD" = "app-store" ]; then
    cat >> ExportOptions.plist <<EOF
  <key>uploadToAppStore</key>
  <false/>
  <key>destination</key>
  <string>export</string>
EOF
fi

cat >> ExportOptions.plist <<EOF
</dict>
</plist>
EOF

echo "📋 ExportOptions.plist created:"
cat ExportOptions.plist

# Export with framework signing handling
echo "🔧 Starting export with framework signing handling..."

# First attempt: Try with automatic signing
if xcodebuild -exportArchive \
  -archivePath "$CM_BUILD_DIR/Runner.xcarchive" \
  -exportPath "$CM_BUILD_DIR/ios_output" \
  -exportOptionsPlist ExportOptions.plist \
  -allowProvisioningUpdates \
  -verbose 2>&1 | tee export.log; then
  
  echo "✅ Export completed successfully!"
  exit 0
fi

echo "⚠️ First export attempt failed, checking for framework warnings..."

# Check if the failure is due to bundle identifier collision
if grep -q "CFBundleIdentifier Collision" export.log || grep -q "There is more than one bundle with the CFBundleIdentifier" export.log; then
  echo "🔧 Bundle identifier collision detected! Applying comprehensive fixes..."
  
  # Run the bundle identifier collision fix script
  if [ -f "lib/scripts/ios/fix_bundle_identifier_collision_v2.sh" ]; then
    chmod +x lib/scripts/ios/fix_bundle_identifier_collision_v2.sh
    ./lib/scripts/ios/fix_bundle_identifier_collision_v2.sh
  elif [ -f "lib/scripts/ios/fix_bundle_identifier_collision.sh" ]; then
    chmod +x lib/scripts/ios/fix_bundle_identifier_collision.sh
    ./lib/scripts/ios/fix_bundle_identifier_collision.sh
  fi
  
  # Re-run pod install to apply the bundle identifier fixes
  echo "🔄 Re-running pod install after bundle identifier fixes..."
  cd ios
  pod install --repo-update
  cd ..
  
  # Rebuild the archive with fixed bundle identifiers
  echo "🔄 Rebuilding archive with fixed bundle identifiers..."
  xcodebuild -workspace "$XCODE_WORKSPACE" \
    -scheme "$XCODE_SCHEME" \
    -archivePath "$CM_BUILD_DIR/Runner.xcarchive" \
    -sdk iphoneos \
    -configuration Release \
    archive \
    DEVELOPMENT_TEAM="$APPLE_TEAM_ID" \
    PROVISIONING_PROFILE_SPECIFIER="$PROFILE_NAME" \
    CODE_SIGN_IDENTITY="$SIGNING_CERT" \
    PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID"
  
  # Try export again
  if xcodebuild -exportArchive \
    -archivePath "$CM_BUILD_DIR/Runner.xcarchive" \
    -exportPath "$CM_BUILD_DIR/ios_output" \
    -exportOptionsPlist ExportOptions.plist \
    -allowProvisioningUpdates \
    -verbose 2>&1 | tee export_after_fix.log; then
    
    echo "✅ Export completed successfully after bundle identifier fixes!"
    exit 0
  fi
  
  echo "⚠️ Export still failed after bundle identifier fixes, trying alternative approaches..."
fi

# Check if the failure is due to framework provisioning profiles
if grep -q "does not support provisioning profiles" export.log; then
  echo "🔧 Framework provisioning profile issue detected, trying alternative approaches..."
  
  # Try with manual signin g
  echo "🔄 Attempting manual signing approach..."
  
  cat > ExportOptions_manual.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>$EXPORT_METHOD</string>
  <key>signingStyle</key>
  <string>manual</string>
  <key>teamID</key>
  <string>$APPLE_TEAM_ID</string>
  <key>compileBitcode</key>
  <false/>
  <key>stripSwiftSymbols</key>
  <true/>
  <key>signingCertificate</key>
  <string>$SIGNING_CERT</string>
  <key>uploadBitcode</key>
  <$UPLOAD_BITCODE/>
  <key>uploadSymbols</key>
  <$UPLOAD_SYMBOLS/>
  <key>thinning</key>
  <string>&lt;none&gt;</string>
  <key>distributionBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>generateAppStoreInformation</key>
  <$([ "$EXPORT_METHOD" = "app-store" ] && echo "true" || echo "false")/>
  <key>manageVersionAndBuildNumber</key>
  <false/>
  <key>embedOnDemandResourcesProvisioningProfiles</key>
  <false/>
  <key>skipProvisioningProfiles</key>
  <false/>
  <key>provisioningProfiles</key>
  <dict>
    <key>$BUNDLE_ID</key>
    <string>$PROFILE_NAME</string>
  </dict>
$([ "$EXPORT_METHOD" = "app-store" ] && echo "  <key>uploadToAppStore</key>
  <false/>
  <key>destination</key>
  <string>export</string>")
</dict>
</plist>
EOF
  
  if xcodebuild -exportArchive \
    -archivePath "$CM_BUILD_DIR/Runner.xcarchive" \
    -exportPath "$CM_BUILD_DIR/ios_output" \
    -exportOptionsPlist ExportOptions_manual.plist \
    -allowProvisioningUpdates \
    -verbose 2>&1 | tee export_manual.log; then
    
    echo "✅ Manual signing export completed successfully!"
    exit 0
  fi
  
  echo "⚠️ Manual signing also failed, trying minimal configuration..."
  
  # Try with minimal configuration (no provisioning profiles)
  cat > ExportOptions_minimal.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>$EXPORT_METHOD</string>
  <key>teamID</key>
  <string>$APPLE_TEAM_ID</string>
  <key>compileBitcode</key>
  <false/>
  <key>stripSwiftSymbols</key>
  <true/>
  <key>uploadBitcode</key>
  <$UPLOAD_BITCODE/>
  <key>uploadSymbols</key>
  <$UPLOAD_SYMBOLS/>
  <key>thinning</key>
  <string>&lt;none&gt;</string>
$([ "$EXPORT_METHOD" = "app-store" ] && echo "  <key>generateAppStoreInformation</key>
  <true/>
  <key>uploadToAppStore</key>
  <false/>
  <key>destination</key>
  <string>export</string>")
</dict>
</plist>
EOF
  
  if xcodebuild -exportArchive \
    -archivePath "$CM_BUILD_DIR/Runner.xcarchive" \
    -exportPath "$CM_BUILD_DIR/ios_output" \
    -exportOptionsPlist ExportOptions_minimal.plist \
    -allowProvisioningUpdates \
    -verbose 2>&1 | tee export_minimal.log; then
    
    echo "✅ Minimal configuration export completed successfully!"
    exit 0
  fi
  
  echo "⚠️ All export attempts failed, trying with framework signing disabled..."
  
  # Final attempt: Try with framework signing completely disabled
  cat > ExportOptions_framework_fix.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>$EXPORT_METHOD</string>
  <key>teamID</key>
  <string>$APPLE_TEAM_ID</string>
  <key>compileBitcode</key>
  <false/>
  <key>stripSwiftSymbols</key>
  <true/>
  <key>uploadBitcode</key>
  <$UPLOAD_BITCODE/>
  <key>uploadSymbols</key>
  <$UPLOAD_SYMBOLS/>
  <key>thinning</key>
  <string>&lt;none&gt;</string>
  <key>signingStyle</key>
  <string>automatic</string>
  <key>signingCertificate</key>
  <string>$SIGNING_CERT</string>
  <key>provisioningProfiles</key>
  <dict>
    <key>$BUNDLE_ID</key>
    <string>$PROFILE_NAME</string>
  </dict>
  <key>embedOnDemandResourcesProvisioningProfiles</key>
  <false/>
  <key>skipProvisioningProfiles</key>
  <false/>
$([ "$EXPORT_METHOD" = "app-store" ] && echo "  <key>generateAppStoreInformation</key>
  <true/>
  <key>uploadToAppStore</key>
  <false/>
  <key>destination</key>
  <string>export</string>")
</dict>
</plist>
EOF
  
  # Try with additional flags to handle framework signing
  if xcodebuild -exportArchive \
    -archivePath "$CM_BUILD_DIR/Runner.xcarchive" \
    -exportPath "$CM_BUILD_DIR/ios_output" \
    -exportOptionsPlist ExportOptions_framework_fix.plist \
    -allowProvisioningUpdates \
    -allowProvisioningDeviceRegistration \
    -verbose 2>&1 | tee export_framework_fix.log; then
    
    echo "✅ Framework fix export completed successfully!"
    exit 0
  fi
  
  echo "❌ All export attempts failed"
  echo "📋 Export logs:"
  cat export.log 2>/dev/null || echo "No export log found"
  cat export_manual.log 2>/dev/null || echo "No manual export log found"
  cat export_minimal.log 2>/dev/null || echo "No minimal export log found"
  cat export_framework_fix.log 2>/dev/null || echo "No framework fix export log found"
  exit 1
else
  echo "❌ Export failed for reasons other than framework provisioning profiles"
  cat export.log
  exit 1
fi 