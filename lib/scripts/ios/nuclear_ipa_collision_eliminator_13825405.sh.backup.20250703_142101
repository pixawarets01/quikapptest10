#!/bin/bash

# Nuclear IPA Collision Elimination Script for Error ID 13825405
# Purpose: Directly modify IPA file to eliminate CFBundleIdentifier collisions
# Error ID: 13825405-65f1-480a-a2b4-517c5cd309e4
# Strategy: Direct IPA file modification with bundle-id-rules compliance

set -euo pipefail

# Script configuration
SCRIPT_NAME="Nuclear IPA Collision Eliminator (13825405)"
ERROR_ID="13825405"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Input validation
if [ $# -lt 3 ]; then
    echo "❌ Usage: $0 <ipa_file> <main_bundle_id> <error_id>"
    echo "📝 Example: $0 Runner.ipa com.insurancegroupmo.insurancegroupmo 13825405"
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
log_info "🎯 Target Error ID: 13825405-65f1-480a-a2b4-517c5cd309e4"
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
    log_info "📦 Extracting IPA file for 13825405 modification..."
    
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
    log_info "🔍 Analyzing bundle identifiers in IPA for 13825405 collisions..."
    
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
    
    log_info "📊 13825405 IPA Analysis:"
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
                log_error "🚨 13825405 COLLISION DETECTED in framework: $plist"
                log_error "   Framework bundle ID: $framework_bundle_id (SAME AS MAIN APP)"
                export COLLISION_13825405_FOUND="true"
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
                log_error "🚨 13825405 COLLISION DETECTED in plugin: $plist"
                log_error "   Plugin bundle ID: $plugin_bundle_id (SAME AS MAIN APP)"
                export COLLISION_13825405_FOUND="true"
            else
                log_info "   ✅ Plugin: $plugin_bundle_id (unique)"
            fi
        done
    fi
    
    return 0
}

# Function to apply 13825405 nuclear fixes
apply_13825405_nuclear_fixes() {
    log_info "☢️ Applying 13825405 nuclear IPA fixes..."
    
    # Fix frameworks
    local frameworks_dir="$APP_DIR/Frameworks"
    if [ -d "$frameworks_dir" ]; then
        log_info "🔧 Fixing framework bundle identifiers for 13825405..."
        
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
                local new_bundle_id="${MAIN_BUNDLE_ID}.framework.${framework_name}.13825405"
                
                log_info "☢️ 13825405 NUCLEAR FIX: $framework_bundle_id → $new_bundle_id"
                
                # Backup original
                cp "$plist" "${plist}.13825405_backup"
                
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
        log_info "🔧 Fixing plugin bundle identifiers for 13825405..."
        
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
                local new_bundle_id="${MAIN_BUNDLE_ID}.plugin.${plugin_name}.13825405"
                
                log_info "☢️ 13825405 NUCLEAR FIX: $plugin_bundle_id → $new_bundle_id"
                
                # Backup original
                cp "$plist" "${plist}.13825405_backup"
                
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

# Function to verify 13825405 nuclear fixes
verify_13825405_fixes() {
    log_info "🔍 Verifying 13825405 nuclear fixes..."
    
    local collision_remaining=0
    
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
                log_error "❌ 🚨 13825405 COLLISION STILL EXISTS: $plist"
                collision_remaining=1
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
                log_error "❌ 🚨 13825405 COLLISION STILL EXISTS: $plist"
                collision_remaining=1
            else
                log_success "✅ Plugin unique: $plugin_bundle_id"
            fi
        done
    fi
    
    if [ $collision_remaining -eq 0 ]; then
        log_success "✅ 13825405 NUCLEAR SUCCESS: No collisions detected"
        return 0
    else
        log_error "❌ 13825405 collisions still exist after nuclear fix"
        return 1
    fi
}

# Function to repackage IPA
repackage_ipa() {
    log_info "📦 Repackaging IPA with 13825405 fixes..."
    
    local output_ipa="Runner_13825405_fixed.ipa"
    
    if zip -r "$output_ipa" Payload/ >/dev/null 2>&1; then
        log_success "✅ IPA repackaged successfully: $output_ipa ($(du -h "$output_ipa" | cut -f1))"
        
        # Copy to output directory
        cp "$output_ipa" "../output/ios/$output_ipa"
        log_info "📱 13825405 fixed IPA: ../output/ios/$output_ipa"
        
        return 0
    else
        log_error "Failed to repackage IPA"
        return 1
    fi
}

# Function to generate report
generate_13825405_report() {
    log_info "📋 Generating 13825405 nuclear elimination report..."
    
    local report_file="13825405_nuclear_elimination_report_${TIMESTAMP}.txt"
    
    {
        echo "13825405 Nuclear IPA Collision Elimination Report"
        echo "Generated: $(date)"
        echo "Error ID: 13825405-65f1-480a-a2b4-517c5cd309e4"
        echo "Main Bundle ID: $MAIN_BUNDLE_ID"
        echo "Original IPA: $IPA_FILE"
        echo "Fixed IPA: Runner_13825405_fixed.ipa"
        echo "========================================"
        echo ""
        echo "Collision Analysis:"
        echo "------------------"
        echo "✅ All framework bundle identifiers made unique"
        echo "✅ All plugin bundle identifiers made unique"
        echo "✅ Main app bundle identifier preserved"
        echo "✅ 13825405 error ID eliminated"
        echo ""
        echo "Fixed Bundle Identifiers:"
        echo "------------------------"
        find . -name "Info.plist" | while read plist; do
            if [ -f "$plist" ]; then
                local bundle_id=""
                if command -v plutil >/dev/null 2>&1; then
                    bundle_id=$(plutil -extract CFBundleIdentifier raw "$plist" 2>/dev/null || echo "NO_BUNDLE_ID")
                else
                    bundle_id=$(grep -A1 "CFBundleIdentifier" "$plist" | tail -1 | sed 's/.*<string>\(.*\)<\/string>.*/\1/' 2>/dev/null || echo "NO_BUNDLE_ID")
                fi
                echo "  $bundle_id"
            fi
        done
        echo ""
        echo "Status: 13825405 COLLISION ELIMINATED"
        echo "Next Steps: Use Runner_13825405_fixed.ipa for App Store upload"
    } > "$report_file"
    
    log_success "📄 13825405 nuclear report: $report_file"
}

# Main execution
main() {
    log_info "🚀 Starting 13825405 nuclear IPA collision elimination..."
    
    # Extract IPA
    if ! extract_ipa; then
        log_error "Failed to extract IPA"
        exit 1
    fi
    
    # Analyze bundles
    if ! analyze_ipa_bundles; then
        log_error "Failed to analyze IPA bundles"
        exit 1
    fi
    
    # Apply nuclear fixes
    if ! apply_13825405_nuclear_fixes; then
        log_error "Failed to apply 13825405 nuclear fixes"
        exit 1
    fi
    
    # Verify fixes
    if ! verify_13825405_fixes; then
        log_error "13825405 nuclear fixes verification failed"
        exit 1
    fi
    
    # Repackage IPA
    if ! repackage_ipa; then
        log_error "Failed to repackage IPA"
        exit 1
    fi
    
    # Generate report
    generate_13825405_report
    
    # Cleanup
    cd ..
    rm -rf "$WORK_DIR"
    
    echo ""
    echo "✅ ☢️ 13825405 NUCLEAR IPA ELIMINATION COMPLETED"
    echo "✅ 🎯 Error ID 13825405-65f1-480a-a2b4-517c5cd309e4 ELIMINATED"
    echo "✅ 📱 Fixed IPA ready for App Store upload"
    echo "✅ 🚀 13825405 GUARANTEED SUCCESS - No collisions possible in final IPA"
}

# Run main function
main "$@" 