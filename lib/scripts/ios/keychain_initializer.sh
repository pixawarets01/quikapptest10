#!/bin/bash

# Keychain Initializer for iOS Build
# Purpose: Ensure ios-build.keychain exists and is properly configured
# Author: AI Assistant
# Version: 1.0

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

# Configuration
KEYCHAIN_NAME="ios-build.keychain"
KEYCHAIN_PASSWORD="${KEYCHAIN_PASSWORD:-build123}"
KEYCHAIN_PATH="$HOME/Library/Keychains/${KEYCHAIN_NAME}-db"

log_info "🔐 Starting Keychain Initialization for iOS Build..."

# Function to check if keychain exists
keychain_exists() {
    local keychain="$1"
    
    # Check if keychain file exists
    if [ -f "$KEYCHAIN_PATH" ]; then
        return 0
    fi
    
    # Check if keychain is in keychain list
    if security list-keychains | grep -q "$keychain"; then
        return 0
    fi
    
    return 1
}

# Function to create new keychain
create_keychain() {
    log_info "🔧 Creating new keychain: $KEYCHAIN_NAME"
    
    # Delete any existing keychain with same name
    security delete-keychain "$KEYCHAIN_NAME" 2>/dev/null || true
    
    # Create new keychain
    if ! security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"; then
        log_error "❌ Failed to create keychain: $KEYCHAIN_NAME"
        return 1
    fi
    
    # Configure keychain settings
    security set-keychain-settings -lut 21600 "$KEYCHAIN_NAME"
    security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"
    
    # Add to search list
    security list-keychains -s "$KEYCHAIN_NAME" login.keychain
    
    # Set as default keychain
    security default-keychain -s "$KEYCHAIN_NAME"
    
    log_success "✅ Keychain created successfully: $KEYCHAIN_NAME"
    return 0
}

# Function to configure existing keychain
configure_keychain() {
    log_info "🔧 Configuring existing keychain: $KEYCHAIN_NAME"
    
    # Unlock keychain
    if ! security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"; then
        log_warn "⚠️ Failed to unlock keychain, trying to reset..."
        
        # Try to reset keychain settings
        security set-keychain-settings -lut 21600 "$KEYCHAIN_NAME"
        security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME" || {
            log_error "❌ Failed to unlock keychain even after reset"
            return 1
        }
    fi
    
    # Add to search list if not already there
    if ! security list-keychains | grep -q "$KEYCHAIN_NAME"; then
        security list-keychains -s "$KEYCHAIN_NAME" login.keychain
    fi
    
    # Set as default keychain
    security default-keychain -s "$KEYCHAIN_NAME"
    
    log_success "✅ Keychain configured successfully: $KEYCHAIN_NAME"
    return 0
}

# Function to verify keychain is working
verify_keychain() {
    log_info "🔍 Verifying keychain functionality..."
    
    # Check if keychain is unlocked
    if ! security show-keychain-info "$KEYCHAIN_NAME" >/dev/null 2>&1; then
        log_error "❌ Keychain is not accessible: $KEYCHAIN_NAME"
        return 1
    fi
    
    # Check if keychain is in search list
    if ! security list-keychains | grep -q "$KEYCHAIN_NAME"; then
        log_error "❌ Keychain not in search list: $KEYCHAIN_NAME"
        return 1
    fi
    
    # Check if keychain is default
    local default_keychain
    default_keychain=$(security default-keychain | tr -d '"')
    if [ "$default_keychain" != "$KEYCHAIN_NAME" ]; then
        log_warn "⚠️ Keychain is not default (current: $default_keychain)"
        security default-keychain -s "$KEYCHAIN_NAME"
        log_info "✅ Set $KEYCHAIN_NAME as default keychain"
    fi
    
    log_success "✅ Keychain verification passed: $KEYCHAIN_NAME"
    return 0
}

# Function to list keychain contents
list_keychain_contents() {
    log_info "📋 Listing keychain contents..."
    
    # List certificates
    local cert_count
    cert_count=$(security find-certificate -a "$KEYCHAIN_NAME" 2>/dev/null | wc -l)
    log_info "   Certificates found: $cert_count"
    
    # List identities
    local identity_count
    identity_count=$(security find-identity -v -p codesigning "$KEYCHAIN_NAME" 2>/dev/null | grep -c "valid identities found" || echo "0")
    log_info "   Code signing identities: $identity_count"
    
    if [ "$cert_count" -gt 0 ] || [ "$identity_count" -gt 0 ]; then
        log_success "✅ Keychain contains certificates and/or identities"
    else
        log_info "ℹ️ Keychain is empty (ready for certificate installation)"
    fi
}

# Main execution
main() {
    log_info "🚀 Keychain Initialization Starting..."
    log_info "📂 Script Location: $(realpath "$0" 2>/dev/null || echo "Unknown")"
    log_info "⏰ Current Time: $(date)"
    log_info ""
    
    # Check if keychain exists
    if keychain_exists "$KEYCHAIN_NAME"; then
        log_info "✅ Keychain exists: $KEYCHAIN_NAME"
        
        # Configure existing keychain
        if ! configure_keychain; then
            log_warn "⚠️ Failed to configure existing keychain, creating new one..."
            if ! create_keychain; then
                log_error "❌ Failed to create new keychain"
                return 1
            fi
        fi
    else
        log_info "📝 Keychain does not exist: $KEYCHAIN_NAME"
        
        # Create new keychain
        if ! create_keychain; then
            log_error "❌ Failed to create keychain"
            return 1
        fi
    fi
    
    # Verify keychain is working
    if ! verify_keychain; then
        log_error "❌ Keychain verification failed"
        return 1
    fi
    
    # List keychain contents
    list_keychain_contents
    
    # Export keychain information for other scripts
    export KEYCHAIN_NAME="$KEYCHAIN_NAME"
    export KEYCHAIN_PASSWORD="$KEYCHAIN_PASSWORD"
    export KEYCHAIN_PATH="$KEYCHAIN_PATH"
    
    log_success "🎉 Keychain initialization completed successfully!"
    log_info "📋 Keychain Information:"
    log_info "   Name: $KEYCHAIN_NAME"
    log_info "   Path: $KEYCHAIN_PATH"
    log_info "   Password: [HIDDEN]"
    log_info "   Status: Ready for certificate installation"
    
    return 0
}

# Run main function
main "$@" 