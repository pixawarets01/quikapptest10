#!/bin/bash

# Universal Nuclear Collision Eliminator for iOS
# Purpose: Apply universal collision elimination to IPA files

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

log_info "🌍 Starting Universal Nuclear Collision Elimination..."

# Function to validate parameters
validate_parameters() {
    local ipa_file="$1"
    local bundle_id="$2"
    local mode="$3"
    
    if [ -z "$ipa_file" ]; then
        log_error "❌ IPA file path is required"
        return 1
    fi
    
    if [ ! -f "$ipa_file" ]; then
        log_error "❌ IPA file not found: $ipa_file"
        return 1
    fi
    
    if [ -z "$bundle_id" ]; then
        log_error "❌ Bundle ID is required"
        return 1
    fi
    
    if [ -z "$mode" ]; then
        log_error "❌ Mode is required"
        return 1
    fi
    
    return 0
}

# Function to extract IPA contents
extract_ipa() {
    local ipa_file="$1"
    local extract_dir="$2"
    
    log_info "📦 Extracting IPA contents..."
    
    # Create extraction directory
    mkdir -p "$extract_dir"
    
    # Extract IPA
    if unzip -q "$ipa_file" -d "$extract_dir"; then
        log_success "✅ IPA extracted successfully"
        return 0
    else
        log_error "❌ Failed to extract IPA"
        return 1
    fi
}

# Function to find and modify bundle identifiers in IPA
modify_bundle_identifiers() {
    local extract_dir="$1"
    local bundle_id="$2"
    
    log_info "🎯 Modifying bundle identifiers in IPA..."
    
    # Find all Info.plist files
    local info_plists
    info_plists=$(find "$extract_dir" -name "Info.plist" -type f 2>/dev/null)
    
    if [ -z "$info_plists" ]; then
        log_warn "⚠️ No Info.plist files found in IPA"
        return 0
    fi
    
    local counter=0
    local modified=false
    
    # Process each Info.plist file
    while IFS= read -r plist_file; do
        if [ -z "$plist_file" ]; then
            continue
        fi
        
        # Get current bundle identifier
        local current_bundle
        current_bundle=$(plutil -extract CFBundleIdentifier xml1 -o - "$plist_file" 2>/dev/null | \
            sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p' | head -1)
        
        if [ -z "$current_bundle" ]; then
            continue
        fi
        
        # Skip if already matches our bundle ID pattern
        if [[ "$current_bundle" == "${bundle_id}"* ]]; then
            continue
        fi
        
        # Create unique bundle identifier
        local suffix=".universal${counter}"
        local new_bundle="${bundle_id}${suffix}"
        
        # Update bundle identifier
        if plutil -replace CFBundleIdentifier -string "$new_bundle" "$plist_file" 2>/dev/null; then
            log_info "🔄 Changed: $current_bundle → $new_bundle"
            modified=true
            counter=$((counter + 1))
        fi
    done <<< "$info_plists"
    
    if [ "$modified" = "true" ]; then
        log_success "✅ Modified $counter bundle identifiers"
    else
        log_info "ℹ️ No bundle identifiers needed modification"
    fi
    
    return 0
}

# Function to repack IPA
repack_ipa() {
    local extract_dir="$1"
    local original_ipa="$2"
    local new_ipa="$3"
    
    log_info "📦 Repacking IPA..."
    
    # Create new IPA file
    if (cd "$extract_dir" && zip -r "$new_ipa" . -q); then
        log_success "✅ IPA repacked successfully"
        return 0
    else
        log_error "❌ Failed to repack IPA"
        return 1
    fi
}

# Function to verify IPA integrity
verify_ipa_integrity() {
    local ipa_file="$1"
    
    log_info "🔍 Verifying IPA integrity..."
    
    # Check if IPA is valid
    if unzip -t "$ipa_file" >/dev/null 2>&1; then
        log_success "✅ IPA integrity verified"
        return 0
    else
        log_error "❌ IPA integrity check failed"
        return 1
    fi
}

# Main execution function
main() {
    local ipa_file="${1:-}"
    local bundle_id="${2:-}"
    local mode="${3:-universal}"
    
    log_info "🚀 Universal Nuclear Collision Elimination"
    log_info "📋 Parameters:"
    log_info "   - IPA File: $ipa_file"
    log_info "   - Bundle ID: $bundle_id"
    log_info "   - Mode: $mode"
    
    # Validate parameters
    if ! validate_parameters "$ipa_file" "$bundle_id" "$mode"; then
        log_error "❌ Parameter validation failed"
        return 1
    fi
    
    # Create backup
    local backup_ipa="${ipa_file}.universal_backup_$(date +%Y%m%d_%H%M%S)"
    cp "$ipa_file" "$backup_ipa"
    log_info "💾 Backup created: $backup_ipa"
    
    # Create temporary extraction directory
    local extract_dir="/tmp/universal_nuclear_$(date +%s)"
    
    # Step 1: Extract IPA
    if ! extract_ipa "$ipa_file" "$extract_dir"; then
        log_error "❌ IPA extraction failed"
        rm -rf "$extract_dir"
        return 1
    fi
    
    # Step 2: Modify bundle identifiers
    if ! modify_bundle_identifiers "$extract_dir" "$bundle_id"; then
        log_error "❌ Bundle identifier modification failed"
        rm -rf "$extract_dir"
        return 1
    fi
    
    # Step 3: Repack IPA
    local temp_ipa="${ipa_file}.temp"
    if ! repack_ipa "$extract_dir" "$ipa_file" "$temp_ipa"; then
        log_error "❌ IPA repacking failed"
        rm -rf "$extract_dir" "$temp_ipa"
        return 1
    fi
    
    # Step 4: Verify integrity
    if ! verify_ipa_integrity "$temp_ipa"; then
        log_error "❌ IPA integrity verification failed"
        rm -rf "$extract_dir" "$temp_ipa"
        return 1
    fi
    
    # Step 5: Replace original with modified version
    mv "$temp_ipa" "$ipa_file"
    
    # Cleanup
    rm -rf "$extract_dir"
    
    log_success "✅ Universal nuclear collision elimination completed successfully!"
    log_info "🌍 All bundle identifiers in IPA are now unique"
    log_info "🎯 Universal mode applied - handles any collision pattern"
    
    return 0
}

# Execute main function if script is run directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi 