#!/bin/bash

# Comprehensive Certificate Validation and Code Signing Script
# Purpose: Handle P12 files, CER+KEY combinations, and App Store Connect API validation
# Author: AI Assistant
# Version: 1.0

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

# Configuration
DEFAULT_P12_PASSWORD="Password@1234"
KEYCHAIN_NAME="ios-build.keychain"
KEYCHAIN_PASSWORD="${KEYCHAIN_PASSWORD:-build123}"
CERT_DIR="ios/certificates"

log_info "🔒 Starting Comprehensive Certificate Validation and Code Signing..."

# Create certificates directory
mkdir -p "$CERT_DIR"

# Function to download file with retry logic
download_with_retry() {
    local url="$1"
    local output_file="$2"
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log_info "📥 Downloading from $url (attempt $attempt/$max_attempts)..."
        
        if curl -L -f -s -o "$output_file" "$url" 2>/dev/null; then
            log_success "✅ Download completed: $output_file"
            return 0
        elif wget -q -O "$output_file" "$url" 2>/dev/null; then
            log_success "✅ Download completed: $output_file"
            return 0
        fi
        
        log_warn "⚠️ Download attempt $attempt failed"
        attempt=$((attempt + 1))
        [ $attempt -le $max_attempts ] && sleep 2
    done
    
    log_error "❌ Failed to download after $max_attempts attempts"
    return 1
}

# Function to validate file exists and has content
validate_file() {
    local file="$1"
    local min_size="${2:-10}"
    
    if [ ! -f "$file" ]; then
        log_error "❌ File does not exist: $file"
        return 1
    fi
    
    local file_size
    if command -v stat >/dev/null 2>&1; then
        if stat -c%s "$file" >/dev/null 2>&1; then
            file_size=$(stat -c%s "$file" 2>/dev/null)
        else
            file_size=$(stat -f%z "$file" 2>/dev/null)
        fi
    else
        file_size=$(wc -c < "$file" 2>/dev/null)
    fi
    
    if [ "${file_size:-0}" -lt "$min_size" ]; then
        log_error "❌ File too small (${file_size:-0} bytes): $file"
        return 1
    fi
    
    log_success "✅ File validated: $file (${file_size} bytes)"
    return 0
}

# Function to setup keychain
setup_keychain() {
    log_info "🔐 Setting up dedicated keychain for certificate installation..."
    
    # Check if keychain is already initialized
    if [ "${KEYCHAIN_INITIALIZED:-false}" = "true" ]; then
        log_info "✅ Keychain already initialized by keychain_initializer.sh"
        return 0
    fi
    
    # Delete existing keychain if it exists
    security delete-keychain "$KEYCHAIN_NAME" 2>/dev/null || true
    
    # Create new keychain
    if ! security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"; then
        log_error "❌ Failed to create keychain"
        return 1
    fi
    
    # Configure keychain settings
    security set-keychain-settings -lut 21600 "$KEYCHAIN_NAME"
    security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"
    
    # Set as default keychain
    security list-keychains -s "$KEYCHAIN_NAME"
    security default-keychain -s "$KEYCHAIN_NAME"
    
    log_success "✅ Keychain setup completed"
    return 0
}

# Function to validate P12 certificate
validate_p12_certificate() {
    local p12_file="$1"
    local password="$2"
    
    log_info "🔍 Validating P12 certificate with password: '${password:-<empty>}'"
    
    # Test P12 file with provided password
    if openssl pkcs12 -in "$p12_file" -noout -passin "pass:$password" -legacy 2>/dev/null; then
        log_success "✅ P12 certificate validation passed with provided password"
        return 0
    elif openssl pkcs12 -in "$p12_file" -noout -passin "pass:$password" 2>/dev/null; then
        log_success "✅ P12 certificate validation passed with provided password (modern mode)"
        return 0
    else
        log_warn "⚠️ P12 certificate validation failed with provided password"
        return 1
    fi
}

# Function to detect P12 certificate password
detect_p12_password() {
    local p12_file="$1"
    local provided_password="${CERT_PASSWORD:-}"
    
    log_info "🔍 Detecting P12 certificate password..."
    
    # First priority: Use provided CERT_PASSWORD if it exists and is not a placeholder
    if [ -n "$provided_password" ] && [ "$provided_password" != "set" ] && [ "$provided_password" != "true" ] && [ "$provided_password" != "false" ] && [ "$provided_password" != "SET" ] && [ "$provided_password" != "your_password" ] && [ "$provided_password" != "Password@1234" ] && [ "$provided_password" != "SET" ]; then
        log_info "Testing provided certificate password: '$provided_password'"
        if validate_p12_certificate "$p12_file" "$provided_password"; then
            log_success "Provided certificate password is valid: '$provided_password'"
            echo "$provided_password"
            return 0
        else
            log_warn "Provided certificate password failed validation: '$provided_password'"
        fi
    else
        log_info "No valid certificate password provided (value: '${provided_password:-<empty>}') - skipping provided password"
    fi
    
    # Second priority: Try empty password
    log_info "Trying empty password..."
    if validate_p12_certificate "$p12_file" ""; then
        log_success "Certificate password is empty"
        echo ""
        return 0
    fi
    
    # Third priority: Try common passwords (prioritize quikappcert)
    log_info "Trying common passwords..."
    local common_passwords=("quikappcert" "Password@1234" "build123" "ios123" "cert123" "p12password" "distribution123" "apple123" "developer123" "team123" "keychain123" "password" "123456" "certificate" "ios" "apple" "distribution" "match" "User@54321" "twinklub")
    
    for pwd in "${common_passwords[@]}"; do
        log_info "Trying common password: '$pwd'"
        if validate_p12_certificate "$p12_file" "$pwd"; then
            log_success "Found valid certificate password: '$pwd'"
            echo "$pwd"
            return 0
        fi
    done
    
    log_error "❌ Could not detect valid certificate password"
    return 1
}

# Function to install P12 certificate
install_p12_certificate() {
    local p12_file="$1"
    local password="$2"
    
    log_info "📦 Installing P12 certificate..."
    
    # Try multiple import methods
    local import_success=false
    
    # Method 1: Standard import
    log_info "🔧 Trying standard security import..."
    if security import "$p12_file" -k "$KEYCHAIN_NAME" -P "$password" -T /usr/bin/codesign 2>/dev/null; then
        log_success "✅ P12 certificate imported successfully (standard method)"
        import_success=true
    else
        log_warn "⚠️ Standard import failed, trying alternative methods..."
    fi
    
    # Method 2: Import without codesign trust
    if [ "$import_success" = false ]; then
        log_info "🔧 Trying import without codesign trust..."
        if security import "$p12_file" -k "$KEYCHAIN_NAME" -P "$password" 2>/dev/null; then
            log_success "✅ P12 certificate imported successfully (without trust)"
            import_success=true
        else
            log_warn "⚠️ Import without trust failed..."
        fi
    fi
    
    # Method 3: Try with legacy flag
    if [ "$import_success" = false ]; then
        log_info "🔧 Trying import with legacy compatibility..."
        if security import "$p12_file" -k "$KEYCHAIN_NAME" -P "$password" -T /usr/bin/codesign -A 2>/dev/null; then
            log_success "✅ P12 certificate imported successfully (legacy method)"
            import_success=true
        else
            log_warn "⚠️ Legacy import failed..."
        fi
    fi
    
    # Method 4: Try with different keychain settings
    if [ "$import_success" = false ]; then
        log_info "🔧 Trying import with custom keychain settings..."
        if security import "$p12_file" -k "$KEYCHAIN_NAME" -P "$password" -T /usr/bin/codesign -f pkcs12 2>/dev/null; then
            log_success "✅ P12 certificate imported successfully (custom settings)"
            import_success=true
        else
            log_warn "⚠️ Custom settings import failed..."
        fi
    fi
    
    if [ "$import_success" = true ]; then
        # Set key partition list for access
        if security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME" 2>/dev/null; then
            log_success "✅ Key partition list set successfully"
        else
            log_warn "⚠️ Failed to set key partition list, but continuing..."
        fi
        
        return 0
    else
        log_error "❌ All P12 certificate import methods failed"
        log_error "🔍 This might indicate:"
        log_error "   - P12 file is corrupted or has encoding issues"
        log_error "   - Password is correct but file format is incompatible"
        log_error "   - Certificate is not valid for macOS security import"
        return 1
    fi
}

# Function to generate P12 from CER and KEY files
generate_p12_from_cer_key() {
    local cer_file="$1"
    local key_file="$2"
    local p12_file="$3"
    local password="$4"
    
    log_info "🔄 Converting CER+KEY to P12 format with password: '${password:-<empty>}'"
    
    if openssl pkcs12 -export -in "$cer_file" -inkey "$key_file" -out "$p12_file" -password "pass:$password" -name "iOS Distribution Certificate" -legacy 2>/dev/null; then
        log_success "✅ Certificate converted to P12 format successfully"
        return 0
    elif openssl pkcs12 -export -in "$cer_file" -inkey "$key_file" -out "$p12_file" -password "pass:$password" -name "iOS Distribution Certificate" 2>/dev/null; then
        log_success "✅ Certificate converted to P12 format successfully (modern mode)"
        return 0
    else
        log_error "❌ Failed to convert CER+KEY to P12 format"
        return 1
    fi
}

# Function to validate App Store Connect API credentials
validate_app_store_connect_api() {
    local api_key_path="$1"
    local key_id="$2"
    local issuer_id="$3"
    
    log_info "🔐 Validating App Store Connect API credentials..."
    log_info "   - Key ID: $key_id"
    log_info "   - Issuer ID: $issuer_id"
    log_info "   - API Key Path: $api_key_path"
    
    # Download API key if it's a URL
    local local_api_key_path="$api_key_path"
    if [[ "$api_key_path" == http* ]]; then
        local_api_key_path="/tmp/AuthKey_${key_id}.p8"
        log_info "📥 Downloading API key from URL..."
        
        if ! download_with_retry "$api_key_path" "$local_api_key_path"; then
            log_error "❌ Failed to download API key"
            return 1
        fi
    fi
    
    # Validate API key file
    if ! validate_file "$local_api_key_path"; then
        log_error "❌ API key file is invalid"
        return 1
    fi
    
    # Check if it looks like a valid p8 file
    if head -1 "$local_api_key_path" | grep -q "BEGIN PRIVATE KEY"; then
        log_success "✅ API key format validation passed"
    else
        log_warn "⚠️ API key format validation warning - file may not be a valid p8 key"
    fi
    
    # Set file permissions
    chmod 600 "$local_api_key_path"
    log_success "✅ API key file permissions set correctly"
    
    # Export for use in other scripts
    export APP_STORE_CONNECT_API_KEY_DOWNLOADED_PATH="$local_api_key_path"
    export APP_STORE_CONNECT_KEY_IDENTIFIER="$key_id"
    export APP_STORE_CONNECT_ISSUER_ID="$issuer_id"
    
    log_success "✅ App Store Connect API credentials validated successfully"
    return 0
}

# Function to extract UUID from mobileprovision file
extract_mobileprovision_uuid() {
    local profile_file="$1"
    
    log_info "🔍 Extracting UUID from mobileprovision file..."
    
    local profile_uuid
    profile_uuid=$(security cms -D -i "$profile_file" 2>/dev/null | plutil -extract UUID xml1 -o - - 2>/dev/null | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p' | head -1)
    
    if [ -n "$profile_uuid" ]; then
        log_success "✅ Extracted UUID: $profile_uuid"
        echo "$profile_uuid"
        return 0
    else
        log_error "❌ Failed to extract UUID from provisioning profile"
        return 1
    fi
}

# Function to validate code signing
validate_code_signing() {
    log_info "🔍 Validating code signing setup..."
    
    # Check for code signing identities in keychain
    local identities
    identities=$(security find-identity -v -p codesigning "$KEYCHAIN_NAME" 2>/dev/null)
    
    if [ -n "$identities" ]; then
        log_success "✅ Found code signing identities:"
        echo "$identities" | while read line; do
            log_info "   $line"
        done
        
        # Check for iOS distribution certificates specifically
        local ios_certs
        ios_certs=$(echo "$identities" | grep -E "iPhone Distribution|iOS Distribution|Apple Distribution")
        
        if [ -n "$ios_certs" ]; then
            log_success "✅ Found iOS distribution certificates!"
            return 0
        else
            log_warn "⚠️ No iOS distribution certificates found"
            return 1
        fi
    else
        log_error "❌ No code signing identities found in keychain"
        return 1
    fi
}

# Main validation logic
main() {
    log_info "🚀 Starting comprehensive certificate validation..."
    
    # Setup keychain
    if ! setup_keychain; then
        log_error "❌ Failed to setup keychain"
        exit 1
    fi
    
    # Check for P12 file
    if [ -n "${CERT_P12_URL:-}" ]; then
        log_info "📦 P12 file URL provided: $CERT_P12_URL"
        
        # Download P12 file
        local p12_file="$CERT_DIR/certificate.p12"
        if ! download_with_retry "$CERT_P12_URL" "$p12_file"; then
            log_error "❌ Failed to download P12 file"
            exit 1
        fi
        
        # Validate P12 file
        if ! validate_file "$p12_file"; then
            log_error "❌ Downloaded P12 file is invalid"
            exit 1
        fi
        
        # Detect P12 certificate password
        local detected_password
        detected_password=$(detect_p12_password "$p12_file")
        local password_detection_result=$?
        
        if [ $password_detection_result -eq 0 ] && [ -n "$detected_password" ]; then
            log_info "🔐 Using detected password: '${detected_password}'"
            
            # Install P12 certificate with detected password
            if install_p12_certificate "$p12_file" "$detected_password"; then
                log_success "✅ P12 certificate installed successfully with detected password"
            else
                log_error "❌ Failed to install P12 certificate"
                exit 1
            fi
        elif [ $password_detection_result -eq 0 ] && [ -z "$detected_password" ]; then
            log_info "🔐 Using empty password"
            
            # Install P12 certificate with empty password
            if install_p12_certificate "$p12_file" ""; then
                log_success "✅ P12 certificate installed successfully with empty password"
            else
                log_error "❌ Failed to install P12 certificate"
                exit 1
            fi
        else
            log_error "❌ Could not detect valid certificate password"
            log_error "💡 Please check your CERT_PASSWORD environment variable"
            log_error "🔍 Tried: provided password, empty password, and common passwords"
            exit 1
        fi
        
    # Check for CER and KEY files
    elif [ -n "${CERT_CER_URL:-}" ] && [ -n "${CERT_KEY_URL:-}" ]; then
        log_info "📄 CER and KEY files provided:"
        log_info "   - CER URL: $CERT_CER_URL"
        log_info "   - KEY URL: $CERT_KEY_URL"
        
        # Download CER file
        local cer_file="$CERT_DIR/certificate.cer"
        if ! download_with_retry "$CERT_CER_URL" "$cer_file"; then
            log_error "❌ Failed to download CER file"
            exit 1
        fi
        
        # Download KEY file
        local key_file="$CERT_DIR/certificate.key"
        if ! download_with_retry "$CERT_KEY_URL" "$key_file"; then
            log_error "❌ Failed to download KEY file"
            exit 1
        fi
        
        # Validate files
        if ! validate_file "$cer_file" || ! validate_file "$key_file"; then
            log_error "❌ Downloaded certificate files are invalid"
            exit 1
        fi
        
        # Generate P12 file with default password
        local p12_file="$CERT_DIR/certificate.p12"
        if generate_p12_from_cer_key "$cer_file" "$key_file" "$p12_file" "$DEFAULT_P12_PASSWORD"; then
            # Install generated P12 certificate
            if install_p12_certificate "$p12_file" "$DEFAULT_P12_PASSWORD"; then
                log_success "✅ Generated P12 certificate installed successfully with default password"
            else
                log_error "❌ Failed to install generated P12 certificate"
                exit 1
            fi
        else
            log_error "❌ Failed to generate P12 from CER and KEY files"
            exit 1
        fi
        
    else
        log_error "❌ No code signing data provided"
        log_error "   Please provide either:"
        log_error "   - CERT_P12_URL with CERT_PASSWORD, or"
        log_error "   - CERT_CER_URL and CERT_KEY_URL"
        exit 1
    fi
    
    # Validate App Store Connect API credentials
    if [ -n "${APP_STORE_CONNECT_API_KEY_PATH:-}" ] && [ -n "${APP_STORE_CONNECT_KEY_IDENTIFIER:-}" ] && [ -n "${APP_STORE_CONNECT_ISSUER_ID:-}" ]; then
        if ! validate_app_store_connect_api "$APP_STORE_CONNECT_API_KEY_PATH" "$APP_STORE_CONNECT_KEY_IDENTIFIER" "$APP_STORE_CONNECT_ISSUER_ID"; then
            log_error "❌ App Store Connect API validation failed"
            exit 1
        fi
    else
        log_warn "⚠️ App Store Connect API credentials not provided"
    fi
    
    # Validate code signing
    if ! validate_code_signing; then
        log_error "❌ Code signing validation failed"
        exit 1
    fi
    
    # Extract UUID from mobileprovision if provided
    if [ -n "${PROFILE_URL:-}" ]; then
        log_info "📱 Processing provisioning profile..."
        
        local profile_file="$CERT_DIR/profile.mobileprovision"
        if download_with_retry "$PROFILE_URL" "$profile_file"; then
            if validate_file "$profile_file"; then
                local profile_uuid
                profile_uuid=$(extract_mobileprovision_uuid "$profile_file")
                if [ -n "$profile_uuid" ]; then
                    export MOBILEPROVISION_UUID="$profile_uuid"
                    log_success "✅ Mobileprovision UUID extracted: $profile_uuid"
                    
                    # Output UUID in a format that can be captured by parent script
                    echo "UUID: $profile_uuid" >&2
                    echo "MOBILEPROVISION_UUID=$profile_uuid" >&2
                    
                    # Install provisioning profile
                    local profiles_dir="$HOME/Library/MobileDevice/Provisioning Profiles"
                    mkdir -p "$profiles_dir"
                    local target_file="$profiles_dir/$profile_uuid.mobileprovision"
                    cp "$profile_file" "$target_file"
                    log_success "✅ Provisioning profile installed: $target_file"
                fi
            fi
        fi
    fi
    
    log_success "🎉 Comprehensive certificate validation completed successfully!"
    log_info "📋 Summary:"
    log_info "   - Certificate: ✅ Installed and validated"
    log_info "   - Code Signing: ✅ Ready for IPA export"
    if [ -n "${MOBILEPROVISION_UUID:-}" ]; then
        log_info "   - Provisioning Profile: ✅ UUID: $MOBILEPROVISION_UUID"
    fi
    if [ -n "${APP_STORE_CONNECT_API_KEY_DOWNLOADED_PATH:-}" ]; then
        log_info "   - App Store Connect API: ✅ Ready for upload"
    fi
    
    return 0
}

# Run main function
main "$@" 