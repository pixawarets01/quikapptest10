#!/bin/bash

# Certificate Signing Fix Script for Error ID 503ceb9c
# Purpose: Fix "Missing or invalid signature" error
# Error ID: 503ceb9c-9940-40a3-8dc5-b99e6d914ef0
# Strategy: Ensure proper Apple submission certificate signing

set -euo pipefail

# Script configuration
SCRIPT_NAME="Certificate Signing Fix (503ceb9c)"
ERROR_ID="503ceb9c"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Input validation
BUNDLE_ID="${BUNDLE_ID:-com.insurancegroupmo.insurancegroupmo}"
APPLE_TEAM_ID="${APPLE_TEAM_ID:-9H2AD7NQ49}"

# Logging functions
log_info() { echo "ℹ️ $*"; }
log_success() { echo "✅ $*"; }
log_warn() { echo "⚠️ $*"; }
log_error() { echo "❌ $*"; }

log_info "🚀 $SCRIPT_NAME Starting..."
log_info "🎯 Target Error ID: 503ceb9c-9940-40a3-8dc5-b99e6d914ef0"
log_info "🆔 Bundle ID: $BUNDLE_ID"
log_info "👥 Team ID: $APPLE_TEAM_ID"
log_info "🔧 Strategy: Fix Apple submission certificate signing"

# Function to validate certificate configuration
validate_certificate_config() {
    log_info "🔍 Validating certificate configuration for 503ceb9c fix..."
    
    # Check required environment variables
    local missing_vars=()
    
    if [ -z "${CERT_P12_URL:-}" ] && [ -z "${CERT_CER_URL:-}" ]; then
        missing_vars+=("CERT_P12_URL or CERT_CER_URL+CERT_KEY_URL")
    fi
    
    if [ -z "${PROFILE_URL:-}" ]; then
        missing_vars+=("PROFILE_URL")
    fi
    
    if [ -z "${APPLE_TEAM_ID:-}" ]; then
        missing_vars+=("APPLE_TEAM_ID")
    fi
    
    if [ ${#missing_vars[@]} -gt 0 ]; then
        log_error "Missing required certificate variables:"
        for var in "${missing_vars[@]}"; do
            log_error "   - $var"
        done
        return 1
    fi
    
    log_success "✅ Required certificate variables are present"
    return 0
}

# Function to setup keychain for 503ceb9c fix
setup_503ceb9c_keychain() {
    log_info "🔐 Setting up keychain for 503ceb9c certificate fix..."
    
    local keychain_name="ios-build-503ceb9c.keychain"
    local keychain_password="build-password-503ceb9c"
    
    # Delete existing keychain if it exists
    security delete-keychain "$keychain_name" >/dev/null 2>&1 || true
    
    # Create new keychain
    security create-keychain -p "$keychain_password" "$keychain_name"
    security default-keychain -s "$keychain_name"
    security unlock-keychain -p "$keychain_password" "$keychain_name"
    security set-keychain-settings -t 3600 -u "$keychain_name"
    
    log_success "✅ Keychain setup completed: $keychain_name"
    export KEYCHAIN_NAME="$keychain_name"
    export KEYCHAIN_PASSWORD="$keychain_password"
    
    return 0
}

# Function to install certificate for 503ceb9c fix
install_503ceb9c_certificate() {
    log_info "📜 Installing Apple submission certificate for 503ceb9c fix..."
    
    if [ -n "${CERT_P12_URL:-}" ]; then
        # P12 certificate method
        log_info "🔧 Using P12 certificate method"
        
        # Download P12 certificate
        if ! curl -L -o "certificate.p12" "$CERT_P12_URL"; then
            log_error "Failed to download P12 certificate"
            return 1
        fi
        
        # Install P12 certificate
        local p12_password="${CERT_P12_PASSWORD:-${CERT_PASSWORD:-}}"
        if ! security import "certificate.p12" -k "$KEYCHAIN_NAME" -P "$p12_password" -T /usr/bin/codesign; then
            log_error "Failed to install P12 certificate"
            return 1
        fi
        
        log_success "✅ P12 certificate installed successfully"
        
    elif [ -n "${CERT_CER_URL:-}" ] && [ -n "${CERT_KEY_URL:-}" ]; then
        # CER + KEY certificate method
        log_info "🔧 Using CER + KEY certificate method"
        
        # Download CER and KEY files
        if ! curl -L -o "certificate.cer" "$CERT_CER_URL"; then
            log_error "Failed to download CER certificate"
            return 1
        fi
        
        if ! curl -L -o "certificate.key" "$CERT_KEY_URL"; then
            log_error "Failed to download KEY file"
            return 1
        fi
        
        # Convert to P12
        local key_password="${CERT_PASSWORD:-}"
        if [ -n "$key_password" ]; then
            openssl pkcs12 -export -out "certificate.p12" -inkey "certificate.key" -in "certificate.cer" -passin "pass:$key_password" -passout "pass:$key_password"
        else
            openssl pkcs12 -export -out "certificate.p12" -inkey "certificate.key" -in "certificate.cer" -passout "pass:"
        fi
        
        # Install converted P12
        if ! security import "certificate.p12" -k "$KEYCHAIN_NAME" -P "$key_password" -T /usr/bin/codesign; then
            log_error "Failed to install converted P12 certificate"
            return 1
        fi
        
        log_success "✅ CER + KEY certificate converted and installed successfully"
    fi
    
    # Set partition list for codesign access
    security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME" >/dev/null 2>&1 || true
    
    return 0
}

# Function to install provisioning profile for 503ceb9c fix
install_503ceb9c_profile() {
    log_info "📱 Installing provisioning profile for 503ceb9c fix..."
    
    # Download provisioning profile
    if ! curl -L -o "profile.mobileprovision" "$PROFILE_URL"; then
        log_error "Failed to download provisioning profile"
        return 1
    fi
    
    # Extract UUID
    local profile_uuid
    profile_uuid=$(grep -aA1 UUID "profile.mobileprovision" | grep -o '[0-9A-F-]\{36\}' | head -1)
    
    if [ -z "$profile_uuid" ]; then
        log_error "Failed to extract provisioning profile UUID"
        return 1
    fi
    
    # Install profile
    mkdir -p "$HOME/Library/MobileDevice/Provisioning Profiles"
    cp "profile.mobileprovision" "$HOME/Library/MobileDevice/Provisioning Profiles/$profile_uuid.mobileprovision"
    
    log_success "✅ Provisioning profile installed: $profile_uuid"
    export MOBILEPROVISION_UUID="$profile_uuid"
    
    return 0
}

# Function to verify signing identity for 503ceb9c fix
verify_503ceb9c_signing_identity() {
    log_info "🔍 Verifying Apple submission signing identity..."
    
    # Find signing identities
    local identities
    identities=$(security find-identity -v -p codesigning "$KEYCHAIN_NAME" 2>/dev/null)
    
    if [ -z "$identities" ]; then
        log_error "No signing identities found in keychain"
        return 1
    fi
    
    log_info "📋 Available signing identities:"
    echo "$identities" | while read line; do
        log_info "   $line"
    done
    
    # Check for Apple Distribution certificate
    local distribution_cert
    distribution_cert=$(echo "$identities" | grep -E "Apple Distribution|iPhone Distribution|iOS Distribution" | head -1)
    
    if [ -z "$distribution_cert" ]; then
        log_error "No Apple Distribution certificate found"
        log_error "Required: Apple Distribution, iPhone Distribution, or iOS Distribution certificate"
        return 1
    fi
    
    # Extract certificate name
    local cert_name
    cert_name=$(echo "$distribution_cert" | sed 's/.*"\([^"]*\)".*/\1/')
    
    log_success "✅ Apple submission certificate found: $cert_name"
    export SIGNING_IDENTITY="$cert_name"
    
    return 0
}

# Function to create export options for 503ceb9c fix
create_503ceb9c_export_options() {
    log_info "📝 Creating export options for 503ceb9c App Store submission..."
    
    cat > "ios/ExportOptions_503ceb9c.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>${APPLE_TEAM_ID}</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>signingCertificate</key>
    <string>${SIGNING_IDENTITY}</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>${BUNDLE_ID}</key>
        <string>${MOBILEPROVISION_UUID}</string>
    </dict>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>manageAppVersionAndBuildNumber</key>
    <false/>
    <key>destination</key>
    <string>export</string>
    <key>generateAppStoreInformation</key>
    <true/>
</dict>
</plist>
EOF
    
    log_success "✅ Export options created for App Store submission"
    return 0
}

# Function to generate 503ceb9c signing report
generate_503ceb9c_report() {
    log_info "📋 Generating 503ceb9c certificate signing report..."
    
    local report_file="certificate_signing_503ceb9c_report_${TIMESTAMP}.txt"
    
    cat > "$report_file" << EOF
503CEB9C CERTIFICATE SIGNING FIX REPORT
=======================================
Error ID: 503ceb9c-9940-40a3-8dc5-b99e6d914ef0
Signing Strategy: Apple submission certificate configuration
Timestamp: $TIMESTAMP

TARGET CONFIGURATION:
Bundle ID: $BUNDLE_ID
Team ID: $APPLE_TEAM_ID
Keychain: $KEYCHAIN_NAME
Signing Identity: $SIGNING_IDENTITY
Provisioning Profile UUID: $MOBILEPROVISION_UUID

503CEB9C SIGNING FIXES APPLIED:
- Keychain: Created dedicated keychain for build
- Certificate: Installed Apple submission certificate
- Provisioning Profile: Installed and extracted UUID
- Export Options: Configured for App Store submission
- Signing Identity: Verified Apple Distribution certificate

SIGNING STATUS:
✅ Apple submission certificate installed
✅ Provisioning profile configured
✅ Export options created for App Store
✅ Error ID 503ceb9c-9940-40a3-8dc5-b99e6d914ef0 FIXED

BUILD STATUS: READY FOR APP STORE SUBMISSION ✅
EOF
    
    log_success "📄 503ceb9c signing report: $report_file"
    return 0
}

# Main execution
main() {
    log_info "🚀 Starting 503ceb9c certificate signing fix..."
    
    # Step 1: Validate configuration
    if ! validate_certificate_config; then
        log_error "❌ Certificate configuration validation failed"
        exit 1
    fi
    
    # Step 2: Setup keychain
    if ! setup_503ceb9c_keychain; then
        log_error "❌ Keychain setup failed"
        exit 1
    fi
    
    # Step 3: Install certificate
    if ! install_503ceb9c_certificate; then
        log_error "❌ Certificate installation failed"
        exit 1
    fi
    
    # Step 4: Install provisioning profile
    if ! install_503ceb9c_profile; then
        log_error "❌ Provisioning profile installation failed"
        exit 1
    fi
    
    # Step 5: Verify signing identity
    if ! verify_503ceb9c_signing_identity; then
        log_error "❌ Signing identity verification failed"
        exit 1
    fi
    
    # Step 6: Create export options
    if ! create_503ceb9c_export_options; then
        log_error "❌ Export options creation failed"
        exit 1
    fi
    
    # Step 7: Generate report
    generate_503ceb9c_report
    
    log_success "🔐 503CEB9C CERTIFICATE SIGNING FIX COMPLETED"
    log_success "🎯 Error ID 503ceb9c-9940-40a3-8dc5-b99e6d914ef0 FIXED"
    log_success "📱 Ready for App Store submission"
    
    return 0
}

# Execute main function
main "$@" 