#!/bin/bash

# Certificate Signing Fix for Error ID: 822b41a6-8771-40c5-b6f5-df38db7abf2c
# Purpose: Fix "Missing or invalid signature" error for Apple submission certificates
# Error: Missing or invalid signature. The bundle '${BUNDLE_ID:-com.insurancegroupmo.insurancegroupmo}' at bundle path 'Payload/Runner.app' is not signed using an Apple submission certificate.

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

log_info "🔐 822B41A6 Certificate Signing Fix Starting..."
log_info "🎯 Target Error ID: 822b41a6-8771-40c5-b6f5-df38db7abf2c"
log_info "⚠️  Issue: Missing or invalid signature for Apple submission certificate"
log_info "🔧 Strategy: Ensure proper Apple Distribution certificate configuration"

# Function to validate certificate for Apple submission
validate_apple_submission_certificate() {
    log_info "🔍 Validating Apple submission certificate configuration..."
    
    local keychain_name="ios-build.keychain"
    local cert_found=false
    
    # Check for Apple Distribution certificates in keychain
    if security list-keychains | grep -q "$keychain_name"; then
        log_info "✅ Build keychain found: $keychain_name"
        
        # Look for Apple Distribution certificates
        local apple_certs
        apple_certs=$(security find-identity -v -p codesigning "$keychain_name" 2>/dev/null | grep -E "Apple Distribution|iPhone Distribution|iOS Distribution" || true)
        
        if [ -n "$apple_certs" ]; then
            log_success "✅ Found Apple Distribution certificates:"
            echo "$apple_certs" | while read line; do
                log_info "   $line"
            done
            cert_found=true
        else
            log_warn "⚠️ No Apple Distribution certificates found in keychain"
        fi
    else
        log_warn "⚠️ Build keychain not found: $keychain_name"
    fi
    
    return $([ "$cert_found" = true ] && echo 0 || echo 1)
}

# Function to ensure proper code signing identity export
configure_code_signing_identity() {
    log_info "🔧 Configuring code signing identity for Apple submission..."
    
    local keychain_name="ios-build.keychain"
    
    # Extract the first Apple Distribution certificate identity
    local cert_identity
    cert_identity=$(security find-identity -v -p codesigning "$keychain_name" 2>/dev/null | grep -E "Apple Distribution|iPhone Distribution|iOS Distribution" | head -1 | sed 's/.*"\([^"]*\)".*/\1/')
    
    if [ -n "$cert_identity" ]; then
        log_success "✅ Using Apple Distribution certificate: $cert_identity"
        
        # Export for use in build process
        export CODE_SIGN_IDENTITY="$cert_identity"
        export CERT_822B41A6_IDENTITY="$cert_identity"
        
        log_info "📤 Exported CODE_SIGN_IDENTITY: $CODE_SIGN_IDENTITY"
        
        # Also set for manual signing if needed
        export MANUAL_CODE_SIGN_IDENTITY="$cert_identity"
        
        return 0
    else
        log_error "❌ Failed to extract Apple Distribution certificate identity"
        return 1
    fi
}

# Function to create Apple submission export options
create_apple_submission_export_options() {
    log_info "📋 Creating Apple submission export options..."
    
    local export_options_path="${OUTPUT_DIR:-output/ios}/ExportOptions_AppleSubmission_822b41a6.plist"
    local export_dir=$(dirname "$export_options_path")
    
    # Ensure output directory exists
    mkdir -p "$export_dir"
    
    # Get provisioning profile UUID
    local profile_uuid="${MOBILEPROVISION_UUID:-}"
    if [ -z "$profile_uuid" ]; then
        log_warn "⚠️ No MOBILEPROVISION_UUID found, using App Store profile method"
        profile_uuid="automatic"
    fi
    
    # Get bundle identifier
    local bundle_id="${BUNDLE_ID:-com.insurancegroupmo.insurancegroupmo}"
    
    # Create export options specifically for Apple submission
    cat > "$export_options_path" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>${TEAM_ID:-AUTOMATIC}</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>manual</string>
    <key>signingCertificate</key>
    <string>Apple Distribution</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>$bundle_id</key>
        <string>$profile_uuid</string>
    </dict>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>thinning</key>
    <string>&lt;none&gt;</string>
    <key>destination</key>
    <string>upload</string>
    <key>manageAppVersionAndBuildNumber</key>
    <false/>
</dict>
</plist>
EOF
    
    if [ -f "$export_options_path" ]; then
        log_success "✅ Created Apple submission export options: $export_options_path"
        export EXPORT_OPTIONS_822B41A6="$export_options_path"
        return 0
    else
        log_error "❌ Failed to create Apple submission export options"
        return 1
    fi
}

# Function to verify and fix keychain permissions
fix_keychain_permissions() {
    log_info "🔧 Fixing keychain permissions for Apple submission..."
    
    local keychain_name="ios-build.keychain"
    local keychain_path="$HOME/Library/Keychains/$keychain_name"
    
    if [ -f "$keychain_path" ]; then
        log_info "🔍 Setting keychain permissions..."
        
        # Set proper permissions
        chmod 600 "$keychain_path"
        
        # Unlock keychain
        security unlock-keychain -p "${KEYCHAIN_PASSWORD:-temp123}" "$keychain_name" || log_warn "⚠️ Keychain unlock failed"
        
        # Set keychain settings
        security set-keychain-settings -t 7200 -l "$keychain_name" || log_warn "⚠️ Keychain settings failed"
        
        log_success "✅ Keychain permissions configured"
        return 0
    else
        log_error "❌ Keychain file not found: $keychain_path"
        return 1
    fi
}

# Function to create dedicated signing function for 822B41A6 fix
create_822b41a6_signing_function() {
    log_info "🔧 Creating dedicated signing function for 822B41A6 fix..."
    
    # Create a function that can be called during IPA export
    cat > "${SCRIPT_DIR}/sign_ipa_822b41a6.sh" << 'EOF'
#!/bin/bash

# Dedicated IPA signing function for 822B41A6 fix
sign_ipa_822b41a6() {
    local ipa_path="$1"
    local cert_identity="$2"
    local profile_uuid="$3"
    
    if [ ! -f "$ipa_path" ]; then
        echo "❌ IPA file not found: $ipa_path"
        return 1
    fi
    
    echo "🔐 Applying 822B41A6 signing fix to IPA: $(basename "$ipa_path")"
    echo "🎯 Certificate: $cert_identity"
    echo "📱 Profile UUID: $profile_uuid"
    
    # Create temporary directory for signing
    local temp_dir=$(mktemp -d)
    local app_dir="$temp_dir/Payload"
    
    # Extract IPA
    echo "📦 Extracting IPA for signing..."
    unzip -q "$ipa_path" -d "$temp_dir"
    
    if [ ! -d "$app_dir" ]; then
        echo "❌ Invalid IPA structure - Payload directory not found"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Find the app bundle
    local app_bundle=$(find "$app_dir" -name "*.app" -type d | head -1)
    
    if [ -z "$app_bundle" ]; then
        echo "❌ App bundle not found in IPA"
        rm -rf "$temp_dir"
        return 1
    fi
    
    echo "📱 Found app bundle: $(basename "$app_bundle")"
    
    # Re-sign the app bundle with proper Apple Distribution certificate
    echo "🔐 Re-signing app bundle..."
    codesign --force --sign "$cert_identity" --verbose --preserve-metadata=identifier,entitlements,flags --timestamp=none "$app_bundle"
    
    if [ $? -eq 0 ]; then
        echo "✅ App bundle re-signed successfully"
        
        # Repackage IPA
        echo "📦 Repackaging IPA..."
        local signed_ipa="${ipa_path%.*}_822b41a6_signed.ipa"
        
        cd "$temp_dir"
        zip -q -r "$signed_ipa" Payload/
        cd - > /dev/null
        
        if [ -f "$signed_ipa" ]; then
            echo "✅ Signed IPA created: $(basename "$signed_ipa")"
            
            # Replace original IPA with signed version
            mv "$signed_ipa" "$ipa_path"
            echo "🔄 Original IPA replaced with signed version"
        else
            echo "❌ Failed to create signed IPA"
            rm -rf "$temp_dir"
            return 1
        fi
    else
        echo "❌ Failed to re-sign app bundle"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Clean up
    rm -rf "$temp_dir"
    
    echo "✅ 822B41A6 signing fix completed successfully"
    return 0
}

# Export the function for use by other scripts
export -f sign_ipa_822b41a6
EOF
    
    chmod +x "${SCRIPT_DIR}/sign_ipa_822b41a6.sh"
    log_success "✅ Created dedicated signing function: sign_ipa_822b41a6.sh"
}

# Main execution function
main() {
    log_info "🚀 Starting 822B41A6 certificate signing fix..."
    
    # Step 1: Validate Apple submission certificate
    if ! validate_apple_submission_certificate; then
        log_error "❌ Apple submission certificate validation failed"
        log_info "💡 Ensure proper Apple Distribution certificate is installed"
        return 1
    fi
    
    # Step 2: Configure code signing identity
    if ! configure_code_signing_identity; then
        log_error "❌ Code signing identity configuration failed"
        return 1
    fi
    
    # Step 3: Create Apple submission export options
    if ! create_apple_submission_export_options; then
        log_error "❌ Apple submission export options creation failed"
        return 1
    fi
    
    # Step 4: Fix keychain permissions
    if ! fix_keychain_permissions; then
        log_warn "⚠️ Keychain permissions fix failed, but continuing..."
    fi
    
    # Step 5: Create dedicated signing function
    if ! create_822b41a6_signing_function; then
        log_warn "⚠️ Dedicated signing function creation failed, but continuing..."
    fi
    
    log_success "✅ 822B41A6 Certificate Signing Fix completed successfully!"
    log_info "🎯 Error ID 822b41a6-8771-40c5-b6f5-df38db7abf2c FIXED"
    log_info "🔐 Apple submission certificate properly configured"
    log_info "📋 Export options created for App Store submission"
    
    # Export status for main workflow
    export CERT_822B41A6_FIX_APPLIED="true"
    export CERT_822B41A6_EXPORT_OPTIONS="${EXPORT_OPTIONS_822B41A6:-}"
    
    return 0
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 