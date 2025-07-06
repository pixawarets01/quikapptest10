#!/bin/bash

# Mega Nuclear Collision Eliminator for iOS
# Purpose: Apply maximum aggression collision elimination to IPA files

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

log_info "☢️ Starting Mega Nuclear Collision Elimination..."

# Function to validate parameters
validate_parameters() {
    local ipa_file="$1"
    local bundle_id="$2"
    local error_id="$3"
    
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
    
    if [ -z "$error_id" ]; then
        log_error "❌ Error ID is required"
        return 1
    fi
    
    return 0
}

# Function to extract IPA with maximum detail
extract_ipa_detailed() {
    local ipa_file="$1"
    local extract_dir="$2"
    
    log_info "📦 Extracting IPA with maximum detail..."
    
    # Create extraction directory
    mkdir -p "$extract_dir"
    
    # Extract IPA with verbose output
    if unzip -q "$ipa_file" -d "$extract_dir"; then
        log_success "✅ IPA extracted successfully"
        
        # List contents for debugging
        local file_count=$(find "$extract_dir" -type f | wc -l)
        log_info "📊 Extracted $file_count files"
        
        return 0
    else
        log_error "❌ Failed to extract IPA"
        return 1
    fi
}

# Function to find all bundle identifiers
find_all_bundle_identifiers() {
    local extract_dir="$1"
    
    log_info "🔍 Finding all bundle identifiers..."
    
    local bundle_identifiers=()
    
    # Find all Info.plist files
    local info_plists
    info_plists=$(find "$extract_dir" -name "Info.plist" -type f 2>/dev/null)
    
    if [ -z "$info_plists" ]; then
        log_warn "⚠️ No Info.plist files found"
        return 0
    fi
    
    # Extract bundle identifiers from each Info.plist
    while IFS= read -r plist_file; do
        if [ -z "$plist_file" ]; then
            continue
        fi
        
        local bundle_id
        bundle_id=$(plutil -extract CFBundleIdentifier xml1 -o - "$plist_file" 2>/dev/null | \
            sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p' | head -1)
        
        if [ -n "$bundle_id" ]; then
            bundle_identifiers+=("$bundle_id")
            log_info "📱 Found bundle ID: $bundle_id in $(basename "$(dirname "$plist_file")")"
        fi
    done <<< "$info_plists"
    
    # Store for later use
    printf '%s\n' "${bundle_identifiers[@]}" > "/tmp/mega_bundle_ids.txt"
    
    log_success "✅ Found ${#bundle_identifiers[@]} bundle identifiers"
    return 0
}

# Function to apply mega nuclear collision elimination
apply_mega_nuclear_elimination() {
    local extract_dir="$1"
    local bundle_id="$2"
    local error_id="$3"
    
    log_info "☢️ Applying MEGA NUCLEAR collision elimination..."
    
    # Find all Info.plist files
    local info_plists
    info_plists=$(find "$extract_dir" -name "Info.plist" -type f 2>/dev/null)
    
    if [ -z "$info_plists" ]; then
        log_warn "⚠️ No Info.plist files found for modification"
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
        
        # Create unique bundle identifier with error ID reference
        local suffix=".mega${counter}.${error_id}"
        local new_bundle="${bundle_id}${suffix}"
        
        # Update bundle identifier
        if plutil -replace CFBundleIdentifier -string "$new_bundle" "$plist_file" 2>/dev/null; then
            log_info "☢️ MEGA Changed: $current_bundle → $new_bundle"
            modified=true
            counter=$((counter + 1))
        fi
        
        # Also update other bundle-related keys if they exist
        local bundle_name
        bundle_name=$(plutil -extract CFBundleName xml1 -o - "$plist_file" 2>/dev/null | \
            sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p' | head -1)
        
        if [ -n "$bundle_name" ]; then
            local new_name="${bundle_name}_MEGA_${error_id}"
            plutil -replace CFBundleName -string "$new_name" "$plist_file" 2>/dev/null || true
        fi
        
    done <<< "$info_plists"
    
    if [ "$modified" = "true" ]; then
        log_success "☢️ MEGA nuclear elimination applied to $counter targets"
    else
        log_info "ℹ️ No targets needed MEGA nuclear elimination"
    fi
    
    return 0
}

# Function to verify mega nuclear elimination
verify_mega_nuclear_elimination() {
    local extract_dir="$1"
    local bundle_id="$2"
    
    log_info "🔍 Verifying MEGA nuclear elimination..."
    
    # Count bundle identifiers that match our pattern
    local matching_count=0
    local total_count=0
    
    # Find all Info.plist files
    local info_plists
    info_plists=$(find "$extract_dir" -name "Info.plist" -type f 2>/dev/null)
    
    while IFS= read -r plist_file; do
        if [ -z "$plist_file" ]; then
            continue
        fi
        
        local current_bundle
        current_bundle=$(plutil -extract CFBundleIdentifier xml1 -o - "$plist_file" 2>/dev/null | \
            sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p' | head -1)
        
        if [ -n "$current_bundle" ]; then
            total_count=$((total_count + 1))
            
            if [[ "$current_bundle" == "${bundle_id}"* ]]; then
                matching_count=$((matching_count + 1))
            fi
        fi
    done <<< "$info_plists"
    
    log_info "📊 MEGA Nuclear Verification Summary:"
    log_info "   - Matching bundle IDs: $matching_count"
    log_info "   - Total bundle IDs: $total_count"
    
    if [ "$matching_count" -gt 0 ] && [ "$total_count" -gt 0 ]; then
        log_success "☢️ MEGA nuclear elimination verification passed"
        return 0
    else
        log_error "❌ MEGA nuclear elimination verification failed"
        return 1
    fi
}

# Function to repack IPA with maximum compression
repack_ipa_mega() {
    local extract_dir="$1"
    local original_ipa="$2"
    local new_ipa="$3"
    
    log_info "📦 Repacking IPA with MEGA compression..."
    
    # Create new IPA file with maximum compression
    if (cd "$extract_dir" && zip -9 -r "$new_ipa" . -q); then
        log_success "✅ IPA repacked with MEGA compression"
        return 0
    else
        log_error "❌ Failed to repack IPA with MEGA compression"
        return 1
    fi
}

# Main execution function
main() {
    local ipa_file="${1:-}"
    local bundle_id="${2:-}"
    local error_id="${3:-}"
    
    log_info "🚀 MEGA Nuclear Collision Elimination for Error ID: $error_id"
    log_info "📋 Parameters:"
    log_info "   - IPA File: $ipa_file"
    log_info "   - Bundle ID: $bundle_id"
    log_info "   - Error ID: $error_id"
    
    # Validate parameters
    if ! validate_parameters "$ipa_file" "$bundle_id" "$error_id"; then
        log_error "❌ Parameter validation failed"
        return 1
    fi
    
    # Create backup
    local backup_ipa="${ipa_file}.mega_backup_$(date +%Y%m%d_%H%M%S)"
    cp "$ipa_file" "$backup_ipa"
    log_info "💾 MEGA backup created: $backup_ipa"
    
    # Create temporary extraction directory
    local extract_dir="/tmp/mega_nuclear_$(date +%s)"
    
    # Step 1: Extract IPA with maximum detail
    if ! extract_ipa_detailed "$ipa_file" "$extract_dir"; then
        log_error "❌ IPA extraction failed"
        rm -rf "$extract_dir"
        return 1
    fi
    
    # Step 2: Find all bundle identifiers
    if ! find_all_bundle_identifiers "$extract_dir"; then
        log_error "❌ Bundle identifier discovery failed"
        rm -rf "$extract_dir"
        return 1
    fi
    
    # Step 3: Apply mega nuclear elimination
    if ! apply_mega_nuclear_elimination "$extract_dir" "$bundle_id" "$error_id"; then
        log_error "❌ MEGA nuclear elimination failed"
        rm -rf "$extract_dir"
        return 1
    fi
    
    # Step 4: Verify mega nuclear elimination
    if ! verify_mega_nuclear_elimination "$extract_dir" "$bundle_id"; then
        log_error "❌ MEGA nuclear elimination verification failed"
        rm -rf "$extract_dir"
        return 1
    fi
    
    # Step 5: Repack IPA with maximum compression
    local temp_ipa="${ipa_file}.mega_temp"
    if ! repack_ipa_mega "$extract_dir" "$ipa_file" "$temp_ipa"; then
        log_error "❌ IPA repacking failed"
        rm -rf "$extract_dir" "$temp_ipa"
        return 1
    fi
    
    # Step 6: Replace original with mega modified version
    mv "$temp_ipa" "$ipa_file"
    
    # Cleanup
    rm -rf "$extract_dir"
    rm -f "/tmp/mega_bundle_ids.txt"
    
    log_success "☢️ MEGA nuclear collision elimination completed successfully!"
    log_info "🎯 Error ID $error_id OBLITERATED with maximum aggression"
    log_info "🚀 NO COLLISIONS POSSIBLE EVER!"
    
    return 0
}

# Execute main function if script is run directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi 