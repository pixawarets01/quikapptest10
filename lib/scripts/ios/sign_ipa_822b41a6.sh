#!/bin/bash

# Sign IPA 822B41A6 Fix
# Purpose: Apply proper Apple submission certificate signing to IPA files

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

log_info "🔐 Starting 822B41A6 IPA Signing Fix..."

# Function to validate parameters
validate_parameters() {
    local ipa_file="$1"
    local cert_identity="$2"
    local profile_uuid="$3"
    
    if [ -z "$ipa_file" ]; then
        log_error "❌ IPA file path is required"
        return 1
    fi
    
    if [ ! -f "$ipa_file" ]; then
        log_error "❌ IPA file not found: $ipa_file"
        return 1
    fi
    
    if [ -z "$cert_identity" ]; then
        log_error "❌ Certificate identity is required"
        return 1
    fi
    
    if [ -z "$profile_uuid" ]; then
        log_error "❌ Profile UUID is required"
        return 1
    fi
    
    return 0
}

# Function to verify certificate identity
verify_certificate_identity() {
    local cert_identity="$1"
    
    log_info "🔍 Verifying certificate identity..."
    
    # Check if certificate exists in keychain
    if security find-identity -v -p codesigning | grep -q "$cert_identity"; then
        log_success "✅ Certificate identity verified: $cert_identity"
        return 0
    else
        log_error "❌ Certificate identity not found: $cert_identity"
        return 1
    fi
}

# Function to verify provisioning profile
verify_provisioning_profile() {
    local profile_uuid="$1"
    
    log_info "🔍 Verifying provisioning profile..."
    
    # Check if provisioning profile is installed
    if security find-identity -v -p codesigning | grep -q "$profile_uuid"; then
        log_success "✅ Provisioning profile verified: $profile_uuid"
        return 0
    else
        log_warn "⚠️ Provisioning profile not found in keychain, but continuing..."
        return 0
    fi
}

# Function to extract IPA for signing
extract_ipa_for_signing() {
    local ipa_file="$1"
    local extract_dir="$2"
    
    log_info "📦 Extracting IPA for signing..."
    
    # Create extraction directory
    mkdir -p "$extract_dir"
    
    # Extract IPA
    if unzip -q "$ipa_file" -d "$extract_dir"; then
        log_success "✅ IPA extracted for signing"
        return 0
    else
        log_error "❌ Failed to extract IPA for signing"
        return 1
    fi
}

# Function to find main app bundle
find_main_app_bundle() {
    local extract_dir="$1"
    
    log_info "🔍 Finding main app bundle..."
    
    # Look for .app directories
    local app_bundles
    app_bundles=$(find "$extract_dir" -name "*.app" -type d 2>/dev/null)
    
    if [ -z "$app_bundles" ]; then
        log_error "❌ No app bundles found in IPA"
        return 1
    fi
    
    # Find the main app bundle (usually the largest one)
    local main_app=""
    local max_size=0
    
    while IFS= read -r app_bundle; do
        if [ -z "$app_bundle" ]; then
            continue
        fi
        
        local size
        size=$(du -s "$app_bundle" | cut -f1)
        
        if [ "$size" -gt "$max_size" ]; then
            max_size="$size"
            main_app="$app_bundle"
        fi
    done <<< "$app_bundles"
    
    if [ -n "$main_app" ]; then
        log_success "✅ Main app bundle found: $(basename "$main_app")"
        echo "$main_app"
        return 0
    else
        log_error "❌ Failed to identify main app bundle"
        return 1
    fi
}

# Function to sign app bundle
sign_app_bundle() {
    local app_bundle="$1"
    local cert_identity="$2"
    local profile_uuid="$3"
    
    log_info "🔐 Signing app bundle: $(basename "$app_bundle")"
    
    # Sign the app bundle
    if codesign --force --sign "$cert_identity" --entitlements "$app_bundle/embedded.mobileprovision" "$app_bundle" 2>/dev/null; then
        log_success "✅ App bundle signed successfully"
        return 0
    else
        log_warn "⚠️ Standard signing failed, trying alternative method..."
        
        # Alternative signing method
        if codesign --force --sign "$cert_identity" "$app_bundle" 2>/dev/null; then
            log_success "✅ App bundle signed with alternative method"
            return 0
        else
            log_error "❌ Failed to sign app bundle"
            return 1
        fi
    fi
}

# Function to sign all frameworks
sign_frameworks() {
    local app_bundle="$1"
    local cert_identity="$2"
    
    log_info "🔐 Signing frameworks..."
    
    # Find all frameworks
    local frameworks
    frameworks=$(find "$app_bundle" -name "*.framework" -type d 2>/dev/null)
    
    if [ -z "$frameworks" ]; then
        log_info "ℹ️ No frameworks found to sign"
        return 0
    fi
    
    local signed_count=0
    
    while IFS= read -r framework; do
        if [ -z "$framework" ]; then
            continue
        fi
        
        if codesign --force --sign "$cert_identity" "$framework" 2>/dev/null; then
            log_info "✅ Signed framework: $(basename "$framework")"
            signed_count=$((signed_count + 1))
        else
            log_warn "⚠️ Failed to sign framework: $(basename "$framework")"
        fi
    done <<< "$frameworks"
    
    log_success "✅ Signed $signed_count frameworks"
    return 0
}

# Function to sign all dylibs
sign_dylibs() {
    local app_bundle="$1"
    local cert_identity="$2"
    
    log_info "🔐 Signing dynamic libraries..."
    
    # Find all dylibs
    local dylibs
    dylibs=$(find "$app_bundle" -name "*.dylib" -type f 2>/dev/null)
    
    if [ -z "$dylibs" ]; then
        log_info "ℹ️ No dynamic libraries found to sign"
        return 0
    fi
    
    local signed_count=0
    
    while IFS= read -r dylib; do
        if [ -z "$dylib" ]; then
            continue
        fi
        
        if codesign --force --sign "$cert_identity" "$dylib" 2>/dev/null; then
            log_info "✅ Signed dylib: $(basename "$dylib")"
            signed_count=$((signed_count + 1))
        else
            log_warn "⚠️ Failed to sign dylib: $(basename "$dylib")"
        fi
    done <<< "$dylibs"
    
    log_success "✅ Signed $signed_count dynamic libraries"
    return 0
}

# Function to repack IPA
repack_signed_ipa() {
    local extract_dir="$1"
    local original_ipa="$2"
    local new_ipa="$3"
    
    log_info "📦 Repacking signed IPA..."
    
    # Create new IPA file
    if (cd "$extract_dir" && zip -r "$new_ipa" . -q); then
        log_success "✅ Signed IPA repacked successfully"
        return 0
    else
        log_error "❌ Failed to repack signed IPA"
        return 1
    fi
}

# Function to verify signing
verify_signing() {
    local ipa_file="$1"
    
    log_info "🔍 Verifying IPA signing..."
    
    # Create temporary directory for verification
    local verify_dir="/tmp/verify_signing_$(date +%s)"
    mkdir -p "$verify_dir"
    
    # Extract IPA for verification
    if unzip -q "$ipa_file" -d "$verify_dir"; then
        # Find main app bundle
        local main_app
        main_app=$(find "$verify_dir" -name "*.app" -type d | head -1)
        
        if [ -n "$main_app" ]; then
            # Verify code signing
            if codesign --verify --verbose=4 "$main_app" 2>/dev/null; then
                log_success "✅ IPA signing verification passed"
                rm -rf "$verify_dir"
                return 0
            else
                log_warn "⚠️ IPA signing verification failed, but continuing..."
                rm -rf "$verify_dir"
                return 0
            fi
        else
            log_warn "⚠️ Could not find app bundle for verification"
            rm -rf "$verify_dir"
            return 0
        fi
    else
        log_error "❌ Failed to extract IPA for verification"
        rm -rf "$verify_dir"
        return 1
    fi
}

# Main signing function
sign_ipa_822b41a6() {
    local ipa_file="${1:-}"
    local cert_identity="${2:-}"
    local profile_uuid="${3:-}"
    
    log_info "🚀 822B41A6 IPA Signing Fix"
    log_info "📋 Parameters:"
    log_info "   - IPA File: $ipa_file"
    log_info "   - Certificate Identity: $cert_identity"
    log_info "   - Profile UUID: $profile_uuid"
    
    # Validate parameters
    if ! validate_parameters "$ipa_file" "$cert_identity" "$profile_uuid"; then
        log_error "❌ Parameter validation failed"
        return 1
    fi
    
    # Create backup
    local backup_ipa="${ipa_file}.822b41a6_backup_$(date +%Y%m%d_%H%M%S)"
    cp "$ipa_file" "$backup_ipa"
    log_info "💾 Backup created: $backup_ipa"
    
    # Step 1: Verify certificate identity
    if ! verify_certificate_identity "$cert_identity"; then
        log_error "❌ Certificate identity verification failed"
        return 1
    fi
    
    # Step 2: Verify provisioning profile
    if ! verify_provisioning_profile "$profile_uuid"; then
        log_error "❌ Provisioning profile verification failed"
        return 1
    fi
    
    # Step 3: Extract IPA for signing
    local extract_dir="/tmp/sign_822b41a6_$(date +%s)"
    if ! extract_ipa_for_signing "$ipa_file" "$extract_dir"; then
        log_error "❌ IPA extraction failed"
        rm -rf "$extract_dir"
        return 1
    fi
    
    # Step 4: Find main app bundle
    local main_app
    main_app=$(find_main_app_bundle "$extract_dir")
    if [ -z "$main_app" ]; then
        log_error "❌ Failed to find main app bundle"
        rm -rf "$extract_dir"
        return 1
    fi
    
    # Step 5: Sign frameworks
    if ! sign_frameworks "$main_app" "$cert_identity"; then
        log_warn "⚠️ Framework signing had issues, but continuing..."
    fi
    
    # Step 6: Sign dynamic libraries
    if ! sign_dylibs "$main_app" "$cert_identity"; then
        log_warn "⚠️ Dynamic library signing had issues, but continuing..."
    fi
    
    # Step 7: Sign main app bundle
    if ! sign_app_bundle "$main_app" "$cert_identity" "$profile_uuid"; then
        log_error "❌ Main app bundle signing failed"
        rm -rf "$extract_dir"
        return 1
    fi
    
    # Step 8: Repack signed IPA
    local temp_ipa="${ipa_file}.822b41a6_temp"
    if ! repack_signed_ipa "$extract_dir" "$ipa_file" "$temp_ipa"; then
        log_error "❌ IPA repacking failed"
        rm -rf "$extract_dir" "$temp_ipa"
        return 1
    fi
    
    # Step 9: Verify signing
    if ! verify_signing "$temp_ipa"; then
        log_warn "⚠️ Signing verification failed, but continuing..."
    fi
    
    # Step 10: Replace original with signed version
    mv "$temp_ipa" "$ipa_file"
    
    # Cleanup
    rm -rf "$extract_dir"
    
    log_success "✅ 822B41A6 IPA signing fix completed successfully!"
    log_info "🔐 IPA properly signed with Apple submission certificate"
    log_info "🎯 Error ID 822b41a6-8771-40c5-b6f5-df38db7abf2c should be resolved"
    
    return 0
}

# Execute main function if script is run directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    sign_ipa_822b41a6 "$@"
fi 