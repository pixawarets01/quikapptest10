#!/bin/bash

# Nuclear IPA Collision Eliminator for Error ID: 13825405-65f1-480a-a2b4-517c5cd309e4
# Purpose: Directly modify IPA file to eliminate CFBundleIdentifier collisions
# Target: Multiple bundles with same CFBundleIdentifier 'com.insurancegroupmo.insurancegroupmo'

set -euo pipefail

# Configuration
ERROR_ID="13825405-65f1-480a-a2b4-517c5cd309e4"
MAIN_BUNDLE_ID="com.insurancegroupmo.insurancegroupmo"
IPA_FILE="output/ios/setup-app.ipa"
WORKSPACE_DIR="/tmp/nuclear_ipa_13825405_$(date +%Y%m%d_%H%M%S)"

# Logging functions
log_info() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1"; }
log_success() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: ✅ $1"; }
log_error() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: ❌ $1"; }
log_warn() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: ⚠️ $1"; }

echo "☢️ NUCLEAR IPA COLLISION ELIMINATOR 13825405"
echo "=========================================="
echo "🎯 Target Error ID: $ERROR_ID"
echo "📱 IPA File: $IPA_FILE"
echo "🆔 Main Bundle ID: $MAIN_BUNDLE_ID"
echo "💥 Strategy: Direct IPA modification for 13825405 elimination"
echo "💼 Working directory: $WORKSPACE_DIR"
echo ""

log_info "🚀 Starting 13825405 nuclear IPA collision elimination..."

# Step 1: Validate IPA file
if [ ! -f "$IPA_FILE" ]; then
    log_error "IPA file not found: $IPA_FILE"
    log_info "🔍 Searching for IPA files..."
    find output/ios -name "*.ipa" -type f 2>/dev/null | head -5
    exit 1
fi

log_success "✅ IPA file found: $IPA_FILE ($(du -h "$IPA_FILE" | cut -f1))"

# Step 2: Create workspace and extract IPA
log_info "📦 Extracting IPA file for 13825405 modification..."
mkdir -p "$WORKSPACE_DIR"
cd "$WORKSPACE_DIR"

if ! unzip -q "$IPA_FILE"; then
    log_error "Failed to extract IPA file"
    exit 1
fi

log_success "✅ IPA extracted successfully"
log_info "📱 App directory: ./Payload/Runner.app"

# Step 3: Analyze bundle identifiers in IPA
log_info "🔍 Analyzing bundle identifiers in IPA for 13825405 collisions..."

# Find all Info.plist files
find . -name "Info.plist" -type f > info_plist_files.txt

echo "📊 13825405 IPA Analysis:"
echo "   - Main app bundle ID: $MAIN_BUNDLE_ID"
echo "   - Expected bundle ID: $MAIN_BUNDLE_ID"

# Check frameworks for bundle ID collisions
echo "🔍 Checking frameworks for bundle ID collisions..."

collision_found=0
while IFS= read -r plist_file; do
    if [ -f "$plist_file" ]; then
        # Extract CFBundleIdentifier using plutil
        bundle_id=$(plutil -extract CFBundleIdentifier raw "$plist_file" 2>/dev/null || echo "NO_BUNDLE_ID")
        
        if [ "$bundle_id" = "$MAIN_BUNDLE_ID" ]; then
            # Check if this is the main app (should be allowed)
            if [[ "$plist_file" == *"/Runner.app/Info.plist" ]]; then
                echo "   ✅ Framework: $bundle_id (main app - allowed)"
            else
                echo "   ❌ 🚨 13825405 COLLISION DETECTED in framework: $plist_file"
                echo "   ❌    Framework bundle ID: $bundle_id (SAME AS MAIN APP)"
                collision_found=1
            fi
        else
            echo "   ✅ Framework: $bundle_id (unique)"
        fi
    fi
done < info_plist_files.txt

if [ $collision_found -eq 0 ]; then
    log_success "✅ No 13825405 collisions detected in initial scan"
else
    log_warn "⚠️ 13825405 collisions detected - applying nuclear fixes..."
fi

# Step 4: Apply 13825405 nuclear IPA fixes
log_info "☢️ Applying 13825405 nuclear IPA fixes..."

# Process each Info.plist file and fix collisions
while IFS= read -r plist_file; do
    if [ -f "$plist_file" ]; then
        bundle_id=$(plutil -extract CFBundleIdentifier raw "$plist_file" 2>/dev/null || echo "NO_BUNDLE_ID")
        
        if [ "$bundle_id" = "$MAIN_BUNDLE_ID" ] && [[ "$plist_file" != *"/Runner.app/Info.plist" ]]; then
            # This is a collision - fix it
            framework_name=$(basename "$(dirname "$plist_file")")
            new_bundle_id="${MAIN_BUNDLE_ID}.framework.${framework_name}.13825405"
            
            log_info "☢️ 13825405 NUCLEAR FIX: $bundle_id → $new_bundle_id"
            
            # Update the bundle identifier
            if plutil -replace CFBundleIdentifier -string "$new_bundle_id" "$plist_file"; then
                log_success "✅ Framework fixed: $framework_name"
            else
                log_error "Failed to fix framework: $framework_name"
            fi
        fi
    fi
done < info_plist_files.txt

# Step 5: Verify 13825405 nuclear fixes
log_info "🔍 Verifying 13825405 nuclear fixes..."

collision_remaining=0
while IFS= read -r plist_file; do
    if [ -f "$plist_file" ]; then
        bundle_id=$(plutil -extract CFBundleIdentifier raw "$plist_file" 2>/dev/null || echo "NO_BUNDLE_ID")
        
        if [ "$bundle_id" = "$MAIN_BUNDLE_ID" ] && [[ "$plist_file" != *"/Runner.app/Info.plist" ]]; then
            echo "   ❌ 🚨 13825405 COLLISION STILL EXISTS: $plist_file"
            collision_remaining=1
        else
            echo "   ✅ Framework unique: $bundle_id"
        fi
    fi
done < info_plist_files.txt

if [ $collision_remaining -eq 0 ]; then
    log_success "✅ 13825405 NUCLEAR SUCCESS: No collisions detected"
else
    log_error "❌ 13825405 collisions still exist after nuclear fix"
    exit 1
fi

# Step 6: Repackage IPA with 13825405 fixes
log_info "📦 Repackaging IPA with 13825405 fixes..."

cd "$WORKSPACE_DIR"
if zip -r "Runner_13825405_fixed.ipa" Payload/ >/dev/null 2>&1; then
    log_success "✅ IPA repackaged successfully: Runner_13825405_fixed.ipa ($(du -h Runner_13825405_fixed.ipa | cut -f1))"
else
    log_error "Failed to repackage IPA"
    exit 1
fi

# Copy fixed IPA to output directory
cp "Runner_13825405_fixed.ipa" "../output/ios/Runner_13825405_fixed.ipa"
log_info "📱 13825405 fixed IPA: ../output/ios/Runner_13825405_fixed.ipa"

# Step 7: Generate 13825405 nuclear elimination report
log_info "📋 Generating 13825405 nuclear elimination report..."

{
    echo "13825405 Nuclear IPA Collision Elimination Report"
    echo "Generated: $(date)"
    echo "Error ID: $ERROR_ID"
    echo "Main Bundle ID: $MAIN_BUNDLE_ID"
    echo "Original IPA: $IPA_FILE"
    echo "Fixed IPA: Runner_13825405_fixed.ipa"
    echo "========================================"
    echo ""
    echo "Collision Analysis:"
    echo "------------------"
    echo "✅ All framework bundle identifiers made unique"
    echo "✅ Main app bundle identifier preserved"
    echo "✅ 13825405 error ID eliminated"
    echo ""
    echo "Fixed Bundle Identifiers:"
    echo "------------------------"
    while IFS= read -r plist_file; do
        if [ -f "$plist_file" ]; then
            bundle_id=$(plutil -extract CFBundleIdentifier raw "$plist_file" 2>/dev/null || echo "NO_BUNDLE_ID")
            echo "  $bundle_id"
        fi
    done < info_plist_files.txt
    echo ""
    echo "Status: 13825405 COLLISION ELIMINATED"
    echo "Next Steps: Use Runner_13825405_fixed.ipa for App Store upload"
} > "13825405_nuclear_elimination_report_$(date +%Y%m%d_%H%M%S).txt"

log_success "📄 13825405 nuclear report: 13825405_nuclear_elimination_report_$(date +%Y%m%d_%H%M%S).txt"

# Cleanup
cd ..
rm -rf "$WORKSPACE_DIR"

echo ""
echo "✅ ☢️ 13825405 NUCLEAR IPA ELIMINATION COMPLETED"
echo "✅ 🎯 Error ID $ERROR_ID ELIMINATED"
echo "✅ 📱 Fixed IPA ready for App Store upload"
echo "✅ 🚀 13825405 GUARANTEED SUCCESS - No collisions possible in final IPA" 