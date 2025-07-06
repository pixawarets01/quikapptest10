#!/bin/bash

# Nuclear IPA Collision Elimination for Error ID: 2375d0ef-7f95-4a0d-b424-9782f5092cd1
# Purpose: Fix CFBundleIdentifier collisions by directly modifying the IPA file
# Error: CFBundleIdentifier Collision. There is more than one bundle with the CFBundleIdentifier value '${BUNDLE_ID:-com.insurancegroupmo.insurancegroupmo}' under the iOS application 'Runner.app'.

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

log_info "☢️ 2375D0EF Nuclear IPA Collision Elimination Starting..."
log_info "🎯 Target Error ID: 2375d0ef-7f95-4a0d-b424-9782f5092cd1"
log_info "⚠️  Issue: Multiple bundles with same CFBundleIdentifier in IPA"
log_info "🔧 Strategy: Direct IPA modification with Bundle-ID-Rules compliance"

# Function to extract and analyze IPA contents
analyze_ipa_contents() {
    local ipa_path="$1"
    local temp_dir="$2"
    
    log_info "🔍 Analyzing IPA contents for collision sources..."
    
    # Extract IPA
    unzip -q "$ipa_path" -d "$temp_dir"
    
    # Find all app bundles and frameworks
    local app_bundles
    app_bundles=$(find "$temp_dir" -name "*.app" -type d)
    
    log_info "📱 Found app bundles:"
    echo "$app_bundles" | while read -r bundle; do
        if [ -n "$bundle" ]; then
            local bundle_name=$(basename "$bundle")
            log_info "   $bundle_name"
        fi
    done
    
    # Find all frameworks
    local frameworks
    frameworks=$(find "$temp_dir" -name "*.framework" -type d)
    
    if [ -n "$frameworks" ]; then
        log_info "📦 Found frameworks:"
        echo "$frameworks" | while read -r framework; do
            if [ -n "$framework" ]; then
                local framework_name=$(basename "$framework")
                log_info "   $framework_name"
            fi
        done
    fi
    
    # Find all bundle identifiers
    local bundle_identifiers=()
    local collision_sources=()
    
    # Check main app bundle
    local main_app=$(find "$temp_dir" -name "*.app" -type d | head -1)
    if [ -n "$main_app" ] && [ -f "$main_app/Info.plist" ]; then
        local main_bundle_id
        main_bundle_id=$(plutil -extract CFBundleIdentifier xml1 -o - "$main_app/Info.plist" 2>/dev/null | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p' | head -1)
        
        if [ -n "$main_bundle_id" ]; then
            bundle_identifiers+=("$main_bundle_id")
            log_info "📱 Main app bundle ID: $main_bundle_id"
        fi
    fi
    
    # Check frameworks
    echo "$frameworks" | while read -r framework; do
        if [ -n "$framework" ] && [ -f "$framework/Info.plist" ]; then
            local framework_bundle_id
            framework_bundle_id=$(plutil -extract CFBundleIdentifier xml1 -o - "$framework/Info.plist" 2>/dev/null | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p' | head -1)
            
            if [ -n "$framework_bundle_id" ]; then
                bundle_identifiers+=("$framework_bundle_id")
                log_info "📦 Framework bundle ID: $framework_bundle_id"
                
                # Check for collisions with main app
                if [ "$framework_bundle_id" = "$main_bundle_id" ]; then
                    collision_sources+=("$framework")
                    log_warn "⚠️ COLLISION DETECTED: $framework has same bundle ID as main app"
                fi
            fi
        fi
    done
    
    # Check for other app bundles (extensions, etc.)
    echo "$app_bundles" | while read -r bundle; do
        if [ -n "$bundle" ] && [ "$bundle" != "$main_app" ] && [ -f "$bundle/Info.plist" ]; then
            local bundle_id
            bundle_id=$(plutil -extract CFBundleIdentifier xml1 -o - "$bundle/Info.plist" 2>/dev/null | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p' | head -1)
            
            if [ -n "$bundle_id" ]; then
                bundle_identifiers+=("$bundle_id")
                log_info "📱 Extension bundle ID: $bundle_id"
                
                # Check for collisions
                if [ "$bundle_id" = "$main_bundle_id" ]; then
                    collision_sources+=("$bundle")
                    log_warn "⚠️ COLLISION DETECTED: $bundle has same bundle ID as main app"
                fi
            fi
        fi
    done
    
    # Return collision sources
    if [ ${#collision_sources[@]} -gt 0 ]; then
        log_error "❌ Found ${#collision_sources[@]} collision sources"
        for source in "${collision_sources[@]}"; do
            log_error "   $source"
        done
        return 1
    else
        log_success "✅ No collisions detected in IPA analysis"
        return 0
    fi
}

# Function to fix bundle identifier collisions
fix_bundle_identifier_collisions() {
    local ipa_path="$1"
    local base_bundle_id="$2"
    local temp_dir="$3"
    
    log_info "🔧 Fixing bundle identifier collisions..."
    
    # Define target type patterns and their suffixes
    declare -A target_patterns=(
        ["WidgetExtension"]=".widget"
        ["NotificationServiceExtension"]=".notificationservice"
        ["AppExtension"]=".extension"
        ["Framework"]=".framework"
        ["WatchKitApp"]=".watchkitapp"
        ["WatchKitExtension"]=".watchkitextension"
        ["Component"]=".component"
        ["Library"]=".library"
        ["Plugin"]=".plugin"
    )
    
    local main_app=$(find "$temp_dir" -name "*.app" -type d | head -1)
    local main_bundle_id="$base_bundle_id"
    local fixes_applied=0
    
    # Process each target type
    for target_pattern in "${!target_patterns[@]}"; do
        local suffix="${target_patterns[$target_pattern]}"
        local new_bundle_id="${base_bundle_id}${suffix}"
        
        log_info "🎯 Processing $target_pattern with new bundle ID: $new_bundle_id"
        
        # Find matching bundles/frameworks
        case "$target_pattern" in
            "WidgetExtension")
                # Look for widget extensions
                find "$temp_dir" -name "*.app" -type d | while read -r bundle; do
                    if [ -n "$bundle" ] && [ "$bundle" != "$main_app" ]; then
                        if [ -f "$bundle/Info.plist" ]; then
                            local bundle_type
                            bundle_type=$(plutil -extract NSExtension.NSExtensionPointIdentifier xml1 -o - "$bundle/Info.plist" 2>/dev/null | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p' | head -1)
                            
                            if [ "$bundle_type" = "com.apple.widget-extension" ]; then
                                log_info "   🔧 Fixing widget extension: $(basename "$bundle")"
                                plutil -replace CFBundleIdentifier -string "$new_bundle_id" "$bundle/Info.plist"
                                fixes_applied=$((fixes_applied + 1))
                            fi
                        fi
                    fi
                done
                ;;
            "NotificationServiceExtension")
                # Look for notification service extensions
                find "$temp_dir" -name "*.app" -type d | while read -r bundle; do
                    if [ -n "$bundle" ] && [ "$bundle" != "$main_app" ]; then
                        if [ -f "$bundle/Info.plist" ]; then
                            local bundle_type
                            bundle_type=$(plutil -extract NSExtension.NSExtensionPointIdentifier xml1 -o - "$bundle/Info.plist" 2>/dev/null | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p' | head -1)
                            
                            if [ "$bundle_type" = "com.apple.usernotifications.service" ]; then
                                log_info "   🔧 Fixing notification service extension: $(basename "$bundle")"
                                plutil -replace CFBundleIdentifier -string "$new_bundle_id" "$bundle/Info.plist"
                                fixes_applied=$((fixes_applied + 1))
                            fi
                        fi
                    fi
                done
                ;;
            "Framework")
                # Look for frameworks
                find "$temp_dir" -name "*.framework" -type d | while read -r framework; do
                    if [ -n "$framework" ] && [ -f "$framework/Info.plist" ]; then
                        local current_bundle_id
                        current_bundle_id=$(plutil -extract CFBundleIdentifier xml1 -o - "$framework/Info.plist" 2>/dev/null | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p' | head -1)
                        
                        if [ "$current_bundle_id" = "$main_bundle_id" ]; then
                            log_info "   🔧 Fixing framework: $(basename "$framework")"
                            plutil -replace CFBundleIdentifier -string "$new_bundle_id" "$framework/Info.plist"
                            fixes_applied=$((fixes_applied + 1))
                        fi
                    fi
                done
                ;;
            "WatchKitApp")
                # Look for Watch apps
                find "$temp_dir" -name "*.app" -type d | while read -r bundle; do
                    if [ -n "$bundle" ] && [ "$bundle" != "$main_app" ]; then
                        if [ -f "$bundle/Info.plist" ]; then
                            local bundle_type
                            bundle_type=$(plutil -extract WKApplication xml1 -o - "$bundle/Info.plist" 2>/dev/null | head -1)
                            
                            if [ -n "$bundle_type" ]; then
                                log_info "   🔧 Fixing Watch app: $(basename "$bundle")"
                                plutil -replace CFBundleIdentifier -string "$new_bundle_id" "$bundle/Info.plist"
                                fixes_applied=$((fixes_applied + 1))
                            fi
                        fi
                    fi
                done
                ;;
            *)
                # Generic pattern matching for other extensions
                find "$temp_dir" -name "*.app" -type d | while read -r bundle; do
                    if [ -n "$bundle" ] && [ "$bundle" != "$main_app" ]; then
                        if [ -f "$bundle/Info.plist" ]; then
                            local current_bundle_id
                            current_bundle_id=$(plutil -extract CFBundleIdentifier xml1 -o - "$bundle/Info.plist" 2>/dev/null | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p' | head -1)
                            
                            if [ "$current_bundle_id" = "$main_bundle_id" ]; then
                                log_info "   🔧 Fixing generic extension: $(basename "$bundle")"
                                plutil -replace CFBundleIdentifier -string "$new_bundle_id" "$bundle/Info.plist"
                                fixes_applied=$((fixes_applied + 1))
                            fi
                        fi
                    fi
                done
                ;;
        esac
    done
    
    log_success "✅ Applied $fixes_applied bundle identifier fixes"
    return 0
}

# Function to repackage the IPA
repackage_ipa() {
    local ipa_path="$1"
    local temp_dir="$2"
    
    log_info "📦 Repackaging IPA with collision fixes..."
    
    # Create new IPA
    local new_ipa="${ipa_path%.*}_2375d0ef_fixed.ipa"
    
    cd "$temp_dir"
    zip -q -r "$new_ipa" Payload/
    cd - > /dev/null
    
    if [ -f "$new_ipa" ]; then
        # Replace original IPA
        mv "$new_ipa" "$ipa_path"
        log_success "✅ IPA repackaged successfully"
        return 0
    else
        log_error "❌ Failed to repackage IPA"
        return 1
    fi
}

# Function to verify the fixes
verify_collision_fixes() {
    local ipa_path="$1"
    local temp_dir="$2"
    local base_bundle_id="$3"
    
    log_info "🔍 Verifying collision fixes..."
    
    # Re-extract and check
    rm -rf "$temp_dir"
    mkdir -p "$temp_dir"
    unzip -q "$ipa_path" -d "$temp_dir"
    
    # Collect all bundle identifiers
    local bundle_identifiers=()
    
    # Check all app bundles
    find "$temp_dir" -name "*.app" -type d | while read -r bundle; do
        if [ -f "$bundle/Info.plist" ]; then
            local bundle_id
            bundle_id=$(plutil -extract CFBundleIdentifier xml1 -o - "$bundle/Info.plist" 2>/dev/null | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p' | head -1)
            
            if [ -n "$bundle_id" ]; then
                bundle_identifiers+=("$bundle_id")
            fi
        fi
    done
    
    # Check all frameworks
    find "$temp_dir" -name "*.framework" -type d | while read -r framework; do
        if [ -f "$framework/Info.plist" ]; then
            local bundle_id
            bundle_id=$(plutil -extract CFBundleIdentifier xml1 -o - "$framework/Info.plist" 2>/dev/null | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p' | head -1)
            
            if [ -n "$bundle_id" ]; then
                bundle_identifiers+=("$bundle_id")
            fi
        fi
    done
    
    # Check for duplicates
    local duplicates
    duplicates=$(printf '%s\n' "${bundle_identifiers[@]}" | sort | uniq -d)
    
    if [ -n "$duplicates" ]; then
        log_error "❌ Still found duplicate bundle identifiers:"
        echo "$duplicates" | while read -r dup; do
            log_error "   $dup"
        done
        return 1
    else
        log_success "✅ No duplicate bundle identifiers found"
        log_info "📋 Final bundle identifiers:"
        printf '%s\n' "${bundle_identifiers[@]}" | sort | uniq | while read -r bundle_id; do
            log_info "   $bundle_id"
        done
        return 0
    fi
}

# Main execution function
main() {
    local ipa_path="$1"
    local base_bundle_id="${2:-${BUNDLE_ID:-com.insurancegroupmo.insurancegroupmo}}"
    local error_id="${3:-2375d0ef}"
    
    log_info "🚀 Starting 2375D0EF nuclear IPA collision elimination..."
    log_info "📱 IPA File: $ipa_path"
    log_info "🎯 Base Bundle ID: $base_bundle_id"
    
    if [ ! -f "$ipa_path" ]; then
        log_error "❌ IPA file not found: $ipa_path"
        return 1
    fi
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    log_info "📁 Using temporary directory: $temp_dir"
    
    # Step 1: Analyze IPA contents
    if ! analyze_ipa_contents "$ipa_path" "$temp_dir"; then
        log_warn "⚠️ Collisions detected, will fix them"
    fi
    
    # Step 2: Fix bundle identifier collisions
    if ! fix_bundle_identifier_collisions "$ipa_path" "$base_bundle_id" "$temp_dir"; then
        log_error "❌ Failed to fix bundle identifier collisions"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Step 3: Repackage IPA
    if ! repackage_ipa "$ipa_path" "$temp_dir"; then
        log_error "❌ Failed to repackage IPA"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Step 4: Verify the fixes
    if ! verify_collision_fixes "$ipa_path" "$temp_dir" "$base_bundle_id"; then
        log_error "❌ Collision fix verification failed"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Clean up
    rm -rf "$temp_dir"
    
    log_success "✅ 2375D0EF Nuclear IPA Collision Elimination completed successfully!"
    log_info "🎯 Error ID 2375d0ef-7f95-4a0d-b424-9782f5092cd1 ELIMINATED"
    log_info "📋 Bundle-ID-Rules compliant naming applied"
    log_info "🔧 All CFBundleIdentifier collisions resolved"
    
    # Export status for main workflow
    export C2375D0EF_NUCLEAR_IPA_FIX_APPLIED="true"
    
    return 0
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <ipa_path> [base_bundle_id] [error_id]"
        exit 1
    fi
    
    main "$@"
fi 