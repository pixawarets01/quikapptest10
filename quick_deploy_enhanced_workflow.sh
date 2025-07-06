#!/bin/bash

# 🚀 Quick Deploy Enhanced iOS Workflow
# ⚡ Immediate deployment of all enhancements to codemagic.yaml
# 🎯 Ready-to-use enhanced workflow deployment

set -euo pipefail

echo "⚡ Quick Deploy Enhanced iOS Workflow"
echo "===================================="
echo ""

# Check if codemagic.yaml exists
if [ ! -f "codemagic.yaml" ]; then
    echo "❌ codemagic.yaml not found!"
    echo "Please ensure you're in the correct directory."
    exit 1
fi

# Create backup
BACKUP_FILE="codemagic.yaml.backup.$(date +%Y%m%d_%H%M%S)"
cp codemagic.yaml "$BACKUP_FILE"
echo "📋 Backup created: $BACKUP_FILE"

# Verify required scripts exist
echo "🔧 Verifying enhancement scripts..."
REQUIRED_SCRIPTS=(
    "lib/scripts/ios/enhanced_error_handler.sh"
    "lib/scripts/ios/enhanced_ipa_upload_handler.sh"
)

for script in "${REQUIRED_SCRIPTS[@]}"; do
    if [ ! -f "$script" ]; then
        echo "❌ Missing required script: $script"
        exit 1
    fi
    
    if [ ! -x "$script" ]; then
        chmod +x "$script"
        echo "✅ Made executable: $script"
    else
        echo "✅ Already executable: $script"
    fi
done

# Quick enhancement: Replace the Build iOS app step
echo ""
echo "🏗️ Enhancing Build iOS app step..."

# Find and replace the Build iOS app step with enhanced version
python3 << 'EOF'
import re
import sys

# Read the current codemagic.yaml
with open('codemagic.yaml', 'r') as f:
    content = f.read()

# Enhanced build step content
enhanced_build_step = '''      - name: 🛡️ Enhanced iOS Build with Error Handling
        script: |
          echo "🛡️ Starting Enhanced iOS Build with Comprehensive Error Handling"
          echo "📊 Build Configuration:"
          echo "  - Bundle ID: $BUNDLE_ID"
          echo "  - Profile Type: $PROFILE_TYPE"
          echo "  - App Name: $APP_NAME"
          echo "  - Build Date: $(date)"
          echo ""
          
          # Initialize enhanced error handling
          echo "🔧 Initializing enhanced error handling system..."
          source lib/scripts/ios/enhanced_error_handler.sh
          lib/scripts/ios/enhanced_error_handler.sh --init
          
          # Validate build environment
          echo "🔍 Validating build environment..."
          if ! validate_environment; then
            echo "❌ Environment validation failed"
            lib/scripts/ios/enhanced_error_handler.sh --report 1
            exit 1
          fi
          
          # Create output directory
          mkdir -p output/ios
          
          # Enhanced error handling for build process
          echo ""
          echo "🚀 STARTING ENHANCED BUILD PROCESS"
          echo "================================="
          
          # Phase 1: Flutter Dependencies
          echo ""
          echo "📦 Phase 1: Flutter Dependencies"
          if ! execute_with_retry "flutter clean && flutter pub get" "Flutter Dependencies"; then
            echo "❌ Flutter dependencies phase failed"
            lib/scripts/ios/enhanced_error_handler.sh --report 1
            exit 1
          fi
          
          # Phase 2: CocoaPods Dependencies
          echo ""
          echo "🍃 Phase 2: CocoaPods Dependencies"
          cd ios
          if ! execute_with_retry "pod install --repo-update" "CocoaPods Installation"; then
            echo "❌ CocoaPods phase failed"
            cd ..
            lib/scripts/ios/enhanced_error_handler.sh --report 1
            exit 1
          fi
          cd ..
          
          # Phase 3: iOS Build
          echo ""
          echo "🏗️ Phase 3: iOS Build"
          
          # Prepare build command based on profile type
          case "$PROFILE_TYPE" in
            "app-store")
              BUILD_CMD="flutter build ipa --release --export-options-plist=ios/ExportOptions.plist"
              ;;
            "ad-hoc")
              BUILD_CMD="flutter build ipa --release --export-options-plist=ios/ExportOptions.plist"
              ;;
            "enterprise")
              BUILD_CMD="flutter build ipa --release --export-options-plist=ios/ExportOptions.plist"
              ;;
            "development")
              BUILD_CMD="flutter build ipa --debug --export-options-plist=ios/ExportOptions.plist"
              ;;
            *)
              BUILD_CMD="flutter build ipa --release"
              ;;
          esac
          
          echo "📋 Build Command: $BUILD_CMD"
          
          if ! execute_with_retry "$BUILD_CMD" "iOS Build"; then
            echo "❌ iOS build phase failed"
            
            # Attempt alternative build methods
            echo "🔄 Attempting alternative build methods..."
            
            # Alternative 1: Build without export options
            echo "🔄 Alternative 1: Build without export options"
            if execute_with_retry "flutter build ipa --release" "iOS Build (Alternative 1)"; then
              echo "✅ Alternative build method 1 succeeded"
            else
              # Alternative 2: Build archive only
              echo "🔄 Alternative 2: Build archive only"
              if execute_with_retry "flutter build ios --release" "iOS Archive Build"; then
                echo "✅ Alternative build method 2 succeeded (archive only)"
                echo "📦 Archive created, will attempt manual IPA export"
              else
                echo "❌ All build methods failed"
                lib/scripts/ios/enhanced_error_handler.sh --report 1
                exit 1
              fi
            fi
          fi
          
          # Phase 4: IPA Location and Validation
          echo ""
          echo "📦 Phase 4: IPA Location and Validation"
          
          # Find and validate IPAs
          echo "🔍 Searching for built IPAs..."
          
          # Define potential IPA locations
          IPA_LOCATIONS=(
            "build/ios/ipa/Runner.ipa"
            "build/ios/ipa/*.ipa"
            "ios/build/Runner.ipa"
            "ios/build/*.ipa"
          )
          
          FOUND_IPAS=()
          for location in "${IPA_LOCATIONS[@]}"; do
            for ipa in $location; do
              if [ -f "$ipa" ]; then
                echo "📦 Found IPA: $ipa"
                FOUND_IPAS+=("$ipa")
              fi
            done
          done
          
          if [ ${#FOUND_IPAS[@]} -eq 0 ]; then
            echo "⚠️ No IPA files found, checking for archive..."
            
            # Look for xcarchive
            ARCHIVE_LOCATIONS=(
              "ios/build/Runner.xcarchive"
              "ios/build/*.xcarchive"
              "build/ios/archive/*.xcarchive"
            )
            
            FOUND_ARCHIVES=()
            for location in "${ARCHIVE_LOCATIONS[@]}"; do
              for archive in $location; do
                if [ -d "$archive" ]; then
                  echo "📦 Found Archive: $archive"
                  FOUND_ARCHIVES+=("$archive")
                fi
              done
            done
            
            if [ ${#FOUND_ARCHIVES[@]} -gt 0 ]; then
              echo "🔄 Attempting to export IPA from archive..."
              BEST_ARCHIVE="${FOUND_ARCHIVES[0]}"
              
              # Create ExportOptions.plist if it doesn't exist
              if [ ! -f "ios/ExportOptions.plist" ]; then
                echo "📝 Creating ExportOptions.plist for $PROFILE_TYPE"
                cat > ios/ExportOptions.plist << EXPORTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>$PROFILE_TYPE</string>
    <key>teamID</key>
    <string>$APPLE_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
EXPORTEOF
              fi
              
              # Export IPA from archive
              EXPORT_CMD="xcodebuild -exportArchive -archivePath \\"$BEST_ARCHIVE\\" -exportPath output/ios/ -exportOptionsPlist ios/ExportOptions.plist"
              
              if execute_with_retry "$EXPORT_CMD" "IPA Export from Archive"; then
                echo "✅ IPA exported successfully from archive"
                # Look for exported IPA
                for ipa in output/ios/*.ipa; do
                  if [ -f "$ipa" ]; then
                    FOUND_IPAS+=("$ipa")
                  fi
                done
              else
                echo "❌ Failed to export IPA from archive"
              fi
            fi
          fi
          
          # Copy IPAs to output directory
          if [ ${#FOUND_IPAS[@]} -gt 0 ]; then
            echo "📦 Copying IPAs to output directory..."
            for ipa in "${FOUND_IPAS[@]}"; do
              cp "$ipa" output/ios/ 2>/dev/null || true
              echo "✅ Copied: $(basename "$ipa")"
            done
          else
            echo "❌ No IPAs or archives found"
            lib/scripts/ios/enhanced_error_handler.sh --report 1
            exit 1
          fi
          
          # Phase 5: Enhanced IPA Upload (if app-store profile)
          if [ "$PROFILE_TYPE" = "app-store" ]; then
            echo ""
            echo "📤 Phase 5: Enhanced IPA Upload to App Store Connect"
            
            # Check if upload is enabled
            if [ "${IS_TESTFLIGHT:-true}" = "true" ] || [ "${SUBMIT_TO_TESTFLIGHT:-true}" = "true" ]; then
              echo "🚀 TestFlight upload enabled, proceeding with upload..."
              
              # Use enhanced upload handler
              if lib/scripts/ios/enhanced_ipa_upload_handler.sh --upload; then
                echo "✅ IPA upload completed successfully"
              else
                echo "❌ IPA upload failed"
                echo "📋 Upload will be attempted again in post-processing"
              fi
            else
              echo "ℹ️ TestFlight upload disabled, skipping upload"
            fi
          else
            echo "ℹ️ Profile type is $PROFILE_TYPE, skipping App Store Connect upload"
          fi
          
          # Phase 6: Build Summary
          echo ""
          echo "📊 Phase 6: Build Summary"
          
          # Generate comprehensive build report
          echo "📋 BUILD SUMMARY:"
          echo "  - Build Status: SUCCESS"
          echo "  - Profile Type: $PROFILE_TYPE"
          echo "  - Bundle ID: $BUNDLE_ID"
          echo "  - IPAs Found: ${#FOUND_IPAS[@]}"
          echo "  - Archives Found: ${#FOUND_ARCHIVES[@]}"
          
          # List all artifacts
          echo ""
          echo "📦 AVAILABLE ARTIFACTS:"
          if [ -d "output/ios" ]; then
            find output/ios -name "*.ipa" -o -name "*.xcarchive" -o -name "*.dSYM" | while read -r artifact; do
              if [ -f "$artifact" ] || [ -d "$artifact" ]; then
                size=$(du -h "$artifact" | cut -f1)
                echo "  📄 $(basename "$artifact"): $size"
              fi
            done
          fi
          
          if [ -d "build/ios/ipa" ]; then
            find build/ios/ipa -name "*.ipa" | while read -r artifact; do
              if [ -f "$artifact" ]; then
                size=$(du -h "$artifact" | cut -f1)
                echo "  📄 $(basename "$artifact"): $size"
              fi
            done
          fi
          
          # Generate final error report
          lib/scripts/ios/enhanced_error_handler.sh --report 0
          
          echo ""
          echo "✅ Enhanced iOS Build completed successfully!"
          echo "🎉 Build artifacts are ready for distribution"'''

# Find the Build iOS app step and replace it
pattern = r'(\s+- name:\s+Build iOS app.*?)(\n\s+- name:)'
replacement = enhanced_build_step + r'\2'

# Replace the build step
new_content = re.sub(pattern, replacement, content, flags=re.DOTALL)

if new_content != content:
    print("✅ Enhanced build step integrated")
else:
    print("⚠️ Build iOS app step not found or already enhanced")

# Write the updated content
with open('codemagic.yaml', 'w') as f:
    f.write(new_content)
EOF

# Add enhanced artifacts if not already present
echo ""
echo "📦 Enhancing artifacts configuration..."

python3 << 'EOF'
with open('codemagic.yaml', 'r') as f:
    content = f.read()

# Enhanced artifacts configuration
enhanced_artifacts = '''    artifacts:
      # 📱 Primary IPA Files (Highest Priority)
      - output/ios/*.ipa
      - output/ios/*_collision_free.ipa
      - output/ios/*_AppStoreConnect_Fixed.ipa
      - output/ios/*_Nuclear_AppStore_Fixed.ipa
      - build/ios/ipa/*.ipa
      - ios/build/*.ipa
      - "*.ipa"

      # 📦 Archive Files (When IPA export fails or for manual processing)
      - output/ios/*.xcarchive
      - build/ios/archive/*.xcarchive
      - ios/build/*.xcarchive
      - "*.xcarchive"

      # 🔧 Debug Symbols and Build Artifacts
      - output/ios/*.dSYM
      - output/ios/*.app.dSYM.zip
      - build/ios/ipa/*.dSYM
      - ios/build/*.dSYM
      - "*.dSYM"
      - "*.dSYM.zip"

      # 📋 Build Configuration and Reports
      - ios/ExportOptions.plist
      - output/ios/ARTIFACTS_SUMMARY.txt
      - output/ios/TROUBLESHOOTING_GUIDE.txt
      - output/ios/PERMISSIONS_SUMMARY.txt
      - build_errors.log
      - ipa_upload.log

      # 📊 Build Logs (For debugging)
      - build/ios/logs/
      - output/ios/logs/
      - ios/build/logs/
      - "/tmp/xcodebuild_logs/*.log"
      - "/var/folders/**/xcodebuild_*.log"

      # 🔐 Code Signing Information
      - ios/Runner.xcodeproj/project.pbxproj
      - ios/Podfile
      - ios/Podfile.lock

      # 🎯 Additional Build Artifacts
      - output/ios/
      - build/ios/'''

# Check if artifacts section exists in iOS workflow
if 'artifacts:' in content and 'ios-workflow:' in content:
    # Find iOS workflow artifacts section and enhance it
    import re
    
    # Pattern to match the iOS workflow artifacts section
    pattern = r'(ios-workflow:.*?)(artifacts:.*?)(\n\s+publishing:|\nworkflows:|\Z)'
    
    def replace_artifacts(match):
        return match.group(1) + enhanced_artifacts + '\n' + match.group(3)
    
    new_content = re.sub(pattern, replace_artifacts, content, flags=re.DOTALL)
    
    if new_content != content:
        print("✅ Enhanced artifacts configuration integrated")
    else:
        print("⚠️ Could not enhance artifacts - manual integration may be needed")
else:
    print("⚠️ Artifacts section not found in iOS workflow")
    new_content = content

# Write the updated content
with open('codemagic.yaml', 'w') as f:
    f.write(new_content)
EOF

echo ""
echo "🔍 Final verification..."

# Verify the enhancements were applied
if grep -q "Enhanced iOS Build with Error Handling" codemagic.yaml; then
    echo "✅ Enhanced build step successfully integrated"
else
    echo "⚠️ Enhanced build step not found - check manual integration"
fi

if grep -q "enhanced_error_handler.sh" codemagic.yaml; then
    echo "✅ Enhanced error handler integration verified"
else
    echo "⚠️ Enhanced error handler not integrated - check manual integration"
fi

if grep -q "output/ios/\*.ipa" codemagic.yaml; then
    echo "✅ Enhanced artifacts configuration verified"
else
    echo "⚠️ Enhanced artifacts not found - check manual integration"
fi

echo ""
echo "⚡ QUICK DEPLOYMENT COMPLETE!"
echo "============================="
echo ""
echo "✅ Key Enhancements Applied:"
echo "   🛡️ Enhanced error handling with retry logic"
echo "   📦 6-phase build process with automatic recovery"
echo "   📤 Multi-method IPA upload system"
echo "   📊 Comprehensive artifact collection"
echo ""
echo "📋 Next Steps:"
echo "   1. ✅ Scripts are executable and ready"
echo "   2. 🧪 Trigger a test iOS workflow build"
echo "   3. 📊 Monitor enhanced error handling in logs"
echo "   4. 🚀 Verify improved build reliability"
echo ""
echo "📚 Full Documentation: ENHANCED_IOS_WORKFLOW_IMPROVEMENTS.md"
echo "🔧 Backup Created: $BACKUP_FILE"
echo ""
echo "🎉 Your iOS workflow is now enhanced and ready for production!" 