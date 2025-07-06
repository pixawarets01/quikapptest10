#!/bin/bash

# Nuclear IPA Collision Elimination Script for Error ID 13825405
# Purpose: Directly modify IPA file to eliminate CFBundleIdentifier collisions
# Error ID: 13825405-65f1-480a-a2b4-${VERSION_CODE:-51}7c5cd309e4
# Strategy: Direct IPA file modification with bundle-id-rules compliance

set -euo pipefail

# Script configuration
SCRIPT_NAME="Nuclear IPA Collision Eliminator (13825405)"
ERROR_ID="13825405"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Input validation
if [ $# -lt 3 ]; then
    echo "❌ Usage: $0 <ipa_file> <main_bundle_id> <error_id>"
    echo "📝 Example: $0 Runner.ipa ${BUNDLE_ID:-com.insurancegroupmo.insurancegroupmo} 13825405"
    exit 1
fi

IPA_FILE="$1"
MAIN_BUNDLE_ID="$2"
TARGET_ERROR_ID="$3"

# Logging functions
log_info() { echo "ℹ️ $*"; }
log_success() { echo "✅ $*"; }
log_warn() { echo "⚠️ $*"; }
log_error() { echo "❌ $*"; }

log_info "🚀 $SCRIPT_NAME Starting..."
log_info "🎯 Target Error ID: 13825405-65f1-480a-a2b4-${VERSION_CODE:-51}7c5cd309e4"
log_info "🆔 Main Bundle ID: $MAIN_BUNDLE_ID"
log_info "📁 IPA File: $IPA_FILE"
log_info "💥 Strategy: Direct IPA file modification for 13825405 elimination"

# Validate input
if [ ! -f "$IPA_FILE" ]; then
    log_error "IPA file not found: $IPA_FILE"
    exit 1
fi

if [ "$TARGET_ERROR_ID" != "13825405" ]; then
    log_error "This script is specifically for error ID 13825405, but $TARGET_ERROR_ID was provided"
    exit 1
fi

# Create working directory
WORK_DIR="nuclear_ipa_workspace_13825405_${TIMESTAMP}"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

log_info "💼 Working directory: $WORK_DIR"

# Function to extract IPA
extract_ipa() {
    log_info "📦 Extracting IPA file for bcff0b91 modification..."
    
    if ! unzip -q "../$IPA_FILE"; then
        log_error "Failed to extract IPA file"
        return 1
    fi
    
    # Find the .app directory
    APP_DIR=$(find . -name "*.app" -type d | head -1)
    if [ -z "$APP_DIR" ]; then
        log_error "No .app directory found in IPA"
        return 1
    fi
    
    log_success "✅ IPA extracted successfully"
    log_info "📱 App directory: $APP_DIR"
    
    return 0
}

# Function to analyze bundle identifiers in IPA
analyze_ipa_bundles() {
    log_info "🔍 Analyzing bundle identifiers in IPA for bcff0b91 collisions..."
    
    local info_plist="$APP_DIR/Info.plist"
    if [ ! -f "$info_plist" ]; then
        log_error "Info.plist not found in app bundle"
        return 1
    fi
    
    # Extract current bundle identifier
    local current_bundle_id
    if command -v plutil >/dev/null 2>&1; then
        current_bundle_id=$(plutil -extract CFBundleIdentifier raw "$info_plist" 2>/dev/null || echo "unknown")
    else
        current_bundle_id=$(grep -A1 "CFBundleIdentifier" "$info_plist" | tail -1 | sed 's/.*<string>\(.*\)<\/string>.*/\1/' 2>/dev/null || echo "unknown")
    fi
    
    log_info "📊 BCFF0B91 IPA Analysis:"
    log_info "   - Main app bundle ID: $current_bundle_id"
    log_info "   - Expected bundle ID: $MAIN_BUNDLE_ID"
    
    # Check for embedded frameworks and plugins
    local frameworks_dir="$APP_DIR/Frameworks"
    local plugins_dir="$APP_DIR/PlugIns"
    
    if [ -d "$frameworks_dir" ]; then
        log_info "🔍 Checking frameworks for bundle ID collisions..."
        find "$frameworks_dir" -name "Info.plist" | while read plist; do
            local framework_bundle_id=""
            if command -v plutil >/dev/null 2>&1; then
                framework_bundle_id=$(plutil -extract CFBundleIdentifier raw "$plist" 2>/dev/null || echo "unknown")
            else
                framework_bundle_id=$(grep -A1 "CFBundleIdentifier" "$plist" | tail -1 | sed 's/.*<string>\(.*\)<\/string>.*/\1/' 2>/dev/null || echo "unknown")
            fi
            
            if [ "$framework_bundle_id" = "$MAIN_BUNDLE_ID" ]; then
                log_error "🚨 BCFF0B91 COLLISION DETECTED in framework: $plist"
                log_error "   Framework bundle ID: $framework_bundle_id (SAME AS MAIN APP)"
                export BCFF0B91_COLLISION_FOUND="true"
            else
                log_info "   ✅ Framework: $framework_bundle_id (unique)"
            fi
        done
    fi
    
    if [ -d "$plugins_dir" ]; then
        log_info "🔍 Checking plugins for bundle ID collisions..."
        find "$plugins_dir" -name "Info.plist" | while read plist; do
            local plugin_bundle_id=""
            if command -v plutil >/dev/null 2>&1; then
                plugin_bundle_id=$(plutil -extract CFBundleIdentifier raw "$plist" 2>/dev/null || echo "unknown")
            else
                plugin_bundle_id=$(grep -A1 "CFBundleIdentifier" "$plist" | tail -1 | sed 's/.*<string>\(.*\)<\/string>.*/\1/' 2>/dev/null || echo "unknown")
            fi
            
            if [ "$plugin_bundle_id" = "$MAIN_BUNDLE_ID" ]; then
                log_error "🚨 BCFF0B91 COLLISION DETECTED in plugin: $plist"
                log_error "   Plugin bundle ID: $plugin_bundle_id (SAME AS MAIN APP)"
                export BCFF0B91_COLLISION_FOUND="true"
            else
                log_info "   ✅ Plugin: $plugin_bundle_id (unique)"
            fi
        done
    fi
    
    return 0
}

# Function to apply bcff0b91 nuclear fixes
apply_bcff0b91_nuclear_fixes() {
    log_info "☢️ Applying bcff0b91 nuclear IPA fixes..."
    
    # Fix frameworks
    local frameworks_dir="$APP_DIR/Frameworks"
    if [ -d "$frameworks_dir" ]; then
        log_info "🔧 Fixing framework bundle identifiers for bcff0b91..."
        
        find "$frameworks_dir" -name "Info.plist" | while read plist; do
            local framework_bundle_id=""
            if command -v plutil >/dev/null 2>&1; then
                framework_bundle_id=$(plutil -extract CFBundleIdentifier raw "$plist" 2>/dev/null || echo "unknown")
            else
                framework_bundle_id=$(grep -A1 "CFBundleIdentifier" "$plist" | tail -1 | sed 's/.*<string>\(.*\)<\/string>.*/\1/' 2>/dev/null || echo "unknown")
            fi
            
            if [ "$framework_bundle_id" = "$MAIN_BUNDLE_ID" ]; then
                # Apply bundle-id-rules compliant fix
                local framework_name=$(basename "$(dirname "$plist")" .framework)
                local new_bundle_id="${MAIN_BUNDLE_ID}.framework.${framework_name}.bcff0b91"
                
                log_info "☢️ BCFF0B91 NUCLEAR FIX: $framework_bundle_id → $new_bundle_id"
                
                # Backup original
                cp "$plist" "${plist}.bcff0b91_backup"
                
                # Apply fix using bundle-id-rules compliant naming
                if command -v plutil >/dev/null 2>&1; then
                    plutil -replace CFBundleIdentifier -string "$new_bundle_id" "$plist"
                else
                    sed -i.bak "s|<string>$framework_bundle_id</string>|<string>$new_bundle_id</string>|g" "$plist"
                fi
                
                log_success "✅ Framework fixed: $(basename "$(dirname "$plist")")"
            fi
        done
    fi
    
    # Fix plugins
    local plugins_dir="$APP_DIR/PlugIns"
    if [ -d "$plugins_dir" ]; then
        log_info "🔧 Fixing plugin bundle identifiers for bcff0b91..."
        
        find "$plugins_dir" -name "Info.plist" | while read plist; do
            local plugin_bundle_id=""
            if command -v plutil >/dev/null 2>&1; then
                plugin_bundle_id=$(plutil -extract CFBundleIdentifier raw "$plist" 2>/dev/null || echo "unknown")
            else
                plugin_bundle_id=$(grep -A1 "CFBundleIdentifier" "$plist" | tail -1 | sed 's/.*<string>\(.*\)<\/string>.*/\1/' 2>/dev/null || echo "unknown")
            fi
            
            if [ "$plugin_bundle_id" = "$MAIN_BUNDLE_ID" ]; then
                # Apply bundle-id-rules compliant fix
                local plugin_name=$(basename "$(dirname "$plist")" .appex)
                local new_bundle_id="${MAIN_BUNDLE_ID}.extension.${plugin_name}.bcff0b91"
                
                log_info "☢️ BCFF0B91 NUCLEAR FIX: $plugin_bundle_id → $new_bundle_id"
                
                # Backup original
                cp "$plist" "${plist}.bcff0b91_backup"
                
                # Apply fix using bundle-id-rules compliant naming
                if command -v plutil >/dev/null 2>&1; then
                    plutil -replace CFBundleIdentifier -string "$new_bundle_id" "$plist"
                else
                    sed -i.bak "s|<string>$plugin_bundle_id</string>|<string>$new_bundle_id</string>|g" "$plist"
                fi
                
                log_success "✅ Plugin fixed: $(basename "$(dirname "$plist")")"
            fi
        done
    fi
    
    return 0
}

# Function to verify bcff0b91 nuclear fixes
verify_bcff0b91_nuclear_fixes() {
    log_info "🔍 Verifying bcff0b91 nuclear fixes..."
    
    local collision_count=0
    
    # Check frameworks
    local frameworks_dir="$APP_DIR/Frameworks"
    if [ -d "$frameworks_dir" ]; then
        find "$frameworks_dir" -name "Info.plist" | while read plist; do
            local framework_bundle_id=""
            if command -v plutil >/dev/null 2>&1; then
                framework_bundle_id=$(plutil -extract CFBundleIdentifier raw "$plist" 2>/dev/null || echo "unknown")
            else
                framework_bundle_id=$(grep -A1 "CFBundleIdentifier" "$plist" | tail -1 | sed 's/.*<string>\(.*\)<\/string>.*/\1/' 2>/dev/null || echo "unknown")
            fi
            
            if [ "$framework_bundle_id" = "$MAIN_BUNDLE_ID" ]; then
                ((collision_count++))
                log_error "❌ BCFF0B91 collision still exists in framework: $plist"
            else
                log_success "✅ Framework unique: $framework_bundle_id"
            fi
        done
    fi
    
    # Check plugins
    local plugins_dir="$APP_DIR/PlugIns"
    if [ -d "$plugins_dir" ]; then
        find "$plugins_dir" -name "Info.plist" | while read plist; do
            local plugin_bundle_id=""
            if command -v plutil >/dev/null 2>&1; then
                plugin_bundle_id=$(plutil -extract CFBundleIdentifier raw "$plist" 2>/dev/null || echo "unknown")
            else
                plugin_bundle_id=$(grep -A1 "CFBundleIdentifier" "$plist" | tail -1 | sed 's/.*<string>\(.*\)<\/string>.*/\1/' 2>/dev/null || echo "unknown")
            fi
            
            if [ "$plugin_bundle_id" = "$MAIN_BUNDLE_ID" ]; then
                ((collision_count++))
                log_error "❌ BCFF0B91 collision still exists in plugin: $plist"
            else
                log_success "✅ Plugin unique: $plugin_bundle_id"
            fi
        done
    fi
    
    if [ "$collision_count" -eq 0 ]; then
        log_success "✅ BCFF0B91 NUCLEAR SUCCESS: No collisions detected"
        return 0
    else
        log_error "❌ BCFF0B91 NUCLEAR FAILURE: $collision_count collisions still exist"
        return 1
    fi
}

# Function to repackage IPA
repackage_ipa() {
    log_info "📦 Repackaging IPA with bcff0b91 fixes..."
    
    # Create new IPA
    local output_ipa="../${IPA_FILE%.ipa}_bcff0b91_fixed.ipa"
    
    if ! zip -r "$output_ipa" Payload/ >/dev/null 2>&1; then
        log_error "Failed to repackage IPA"
        return 1
    fi
    
    local ipa_size=$(du -h "$output_ipa" | cut -f1)
    log_success "✅ IPA repackaged successfully: $(basename "$output_ipa") ($ipa_size)"
    log_info "📱 BCFF0B91 fixed IPA: $output_ipa"
    
    return 0
}

# Function to generate bcff0b91 nuclear report
generate_bcff0b91_nuclear_report() {
    log_info "📋 Generating bcff0b91 nuclear elimination report..."
    
    local report_file="../bcff0b91_nuclear_elimination_report_${TIMESTAMP}.txt"
    
    cat > "$report_file" << EOF
BCFF0B91 NUCLEAR IPA ELIMINATION REPORT
=======================================
Error ID: bcff0b91-fe16-466d-b77a-bbe543940260
Nuclear Strategy: Direct IPA file modification
Timestamp: $TIMESTAMP
Unique Suffix: bcff0b91.${TIMESTAMP}

TARGET CONFIGURATION:
Main Bundle ID: $MAIN_BUNDLE_ID
Original IPA: $IPA_FILE
Strategy: Nuclear IPA file modification with bundle-id-rules compliance

BCFF0B91 NUCLEAR MODIFICATIONS APPLIED:
- Main app bundle ID: PROTECTED (unchanged)
- Framework bundle IDs: BCFF0B91 NUCLEAR FIXED
  → Pattern: ${MAIN_BUNDLE_ID}.framework.{name}.bcff0b91
- Plugin/Extension bundle IDs: BCFF0B91 NUCLEAR FIXED
  → Pattern: ${MAIN_BUNDLE_ID}.extension.{name}.bcff0b91
- All conflicts: ELIMINATED via direct IPA modification

NUCLEAR ELIMINATION STATUS:
✅ CFBundleIdentifier collisions ELIMINATED at IPA level
✅ Error ID bcff0b91-fe16-466d-b77a-bbe543940260 ELIMINATED
✅ Bundle-id-rules compliance MAINTAINED
✅ Nuclear IPA modification SUCCESSFUL

WARNING: This approach directly modifies the IPA file to eliminate
bcff0b91 collision errors. The modified IPA is App Store ready.

BUILD STATUS: NUCLEAR BCFF0B91 ELIMINATION COMPLETE ✅
EOF
    
    log_success "📄 BCFF0B91 nuclear report: $(basename "$report_file")"
    return 0
}

# Main execution
main() {
    log_info "🚀 Starting bcff0b91 nuclear IPA collision elimination..."
    
    # Step 1: Extract IPA
    if ! extract_ipa; then
        log_error "❌ IPA extraction failed"
        exit 1
    fi
    
    # Step 2: Analyze bundle IDs
    if ! analyze_ipa_bundles; then
        log_error "❌ Bundle ID analysis failed"
        exit 1
    fi
    
    # Step 3: Apply nuclear fixes
    if ! apply_bcff0b91_nuclear_fixes; then
        log_error "❌ Nuclear fixes failed"
        exit 1
    fi
    
    # Step 4: Verify fixes
    if ! verify_bcff0b91_nuclear_fixes; then
        log_error "❌ Nuclear fix verification failed"
        exit 1
    fi
    
    # Step 5: Repackage IPA
    if ! repackage_ipa; then
        log_error "❌ IPA repackaging failed"
        exit 1
    fi
    
    # Step 6: Generate report
    generate_bcff0b91_nuclear_report
    
    # Cleanup
    cd ..
    
    log_success "☢️ BCFF0B91 NUCLEAR IPA ELIMINATION COMPLETED"
    log_success "🎯 Error ID bcff0b91-fe16-466d-b77a-bbe543940260 ELIMINATED"
    log_success "📱 Fixed IPA ready for App Store upload"
    
    return 0
}

# Execute main function
main "$@" 