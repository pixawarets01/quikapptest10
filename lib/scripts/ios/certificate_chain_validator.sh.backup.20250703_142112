#!/bin/bash

# Certificate Chain Validator
# Purpose: Validate iOS certificate configuration for proper signing

set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

log_info "🔐 Starting Certificate Chain Validation..."

# Validate P12 certificate method
validate_p12_method() {
    if [ -n "${CERT_P12_URL:-}" ] && [ -n "${CERT_PASSWORD:-}" ]; then
        log_success "✅ P12 certificate method configured"
        
        # Test P12 URL accessibility
        if curl -fsSL --head --connect-timeout 10 "${CERT_P12_URL}" >/dev/null 2>&1; then
            log_success "✅ P12 URL accessible"
        else
            log_warn "⚠️ P12 URL may not be accessible"
        fi
        
        return 0
    else
        log_info "ℹ️ P12 certificate method not configured"
        return 1
    fi
}

# Validate CER+KEY certificate method
validate_cer_key_method() {
    if [ -n "${CERT_CER_URL:-}" ] && [ -n "${CERT_KEY_URL:-}" ]; then
        log_success "✅ CER+KEY certificate method configured"
        
        # Test CER URL accessibility
        if curl -fsSL --head --connect-timeout 10 "${CERT_CER_URL}" >/dev/null 2>&1; then
            log_success "✅ CER URL accessible"
        else
            log_warn "⚠️ CER URL may not be accessible"
        fi
        
        # Test KEY URL accessibility
        if curl -fsSL --head --connect-timeout 10 "${CERT_KEY_URL}" >/dev/null 2>&1; then
            log_success "✅ KEY URL accessible"
        else
            log_warn "⚠️ KEY URL may not be accessible"
        fi
        
        return 0
    else
        log_info "ℹ️ CER+KEY certificate method not configured"
        return 1
    fi
}

# Validate App Store Connect API
validate_app_store_connect_api() {
    if [ -n "${APP_STORE_CONNECT_API_KEY_PATH:-}" ] && [ -n "${APP_STORE_CONNECT_KEY_IDENTIFIER:-}" ] && [ -n "${APP_STORE_CONNECT_ISSUER_ID:-}" ]; then
        log_success "✅ App Store Connect API configured"
        
        # Check if API key file exists (if local path)
        if [[ "${APP_STORE_CONNECT_API_KEY_PATH}" =~ ^https?:// ]]; then
            # It's a URL
            if curl -fsSL --head --connect-timeout 10 "${APP_STORE_CONNECT_API_KEY_PATH}" >/dev/null 2>&1; then
                log_success "✅ API key URL accessible"
            else
                log_warn "⚠️ API key URL may not be accessible"
            fi
        else
            # It's a local path
            if [ -f "${APP_STORE_CONNECT_API_KEY_PATH}" ]; then
                log_success "✅ API key file exists locally"
            else
                log_warn "⚠️ API key file not found at local path"
            fi
        fi
        
        # Validate key identifier format
        if [[ "${APP_STORE_CONNECT_KEY_IDENTIFIER}" =~ ^[A-Z0-9]{10}$ ]]; then
            log_success "✅ Key identifier format valid"
        else
            log_warn "⚠️ Key identifier format unusual: ${APP_STORE_CONNECT_KEY_IDENTIFIER}"
        fi
        
        # Validate issuer ID format
        if [[ "${APP_STORE_CONNECT_ISSUER_ID}" =~ ^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$ ]]; then
            log_success "✅ Issuer ID format valid"
        else
            log_warn "⚠️ Issuer ID format unusual: ${APP_STORE_CONNECT_ISSUER_ID}"
        fi
        
        return 0
    else
        log_info "ℹ️ App Store Connect API not configured"
        return 1
    fi
}

# Validate Apple Team ID
validate_apple_team_id() {
    if [ -n "${APPLE_TEAM_ID:-}" ]; then
        log_success "✅ Apple Team ID configured: ${APPLE_TEAM_ID}"
        
        if [[ "${APPLE_TEAM_ID}" =~ ^[A-Z0-9]{10}$ ]]; then
            log_success "✅ Team ID format valid"
        else
            log_warn "⚠️ Team ID format unusual (should be 10 alphanumeric chars): ${APPLE_TEAM_ID}"
        fi
        
        return 0
    else
        log_error "❌ Apple Team ID not configured"
        return 1
    fi
}

# Check certificate redundancy
check_certificate_redundancy() {
    log_info "🔍 Checking certificate method redundancy..."
    
    local methods=0
    local method_names=()
    
    if validate_p12_method >/dev/null 2>&1; then
        methods=$((methods + 1))
        method_names+=("P12")
    fi
    
    if validate_cer_key_method >/dev/null 2>&1; then
        methods=$((methods + 1))
        method_names+=("CER+KEY")
    fi
    
    if validate_app_store_connect_api >/dev/null 2>&1; then
        methods=$((methods + 1))
        method_names+=("App Store Connect API")
    fi
    
    case "$methods" in
        0)
            log_error "❌ No certificate methods available"
            return 1
            ;;
        1)
            log_warn "⚠️ Only one certificate method available: ${method_names[0]}"
            log_info "💡 Consider configuring additional methods for redundancy"
            ;;
        2)
            log_success "✅ Good redundancy: ${method_names[*]}"
            ;;
        3)
            log_success "🎉 Excellent redundancy: ${method_names[*]}"
            ;;
    esac
    
    return 0
}

# Validate provisioning profile
validate_provisioning_profile() {
    log_info "📱 Validating provisioning profile configuration..."
    
    if [ -z "${PROFILE_URL:-}" ]; then
        log_error "❌ Provisioning profile URL not configured"
        return 1
    fi
    
    log_success "✅ Provisioning profile URL configured"
    
    # Test profile URL accessibility
    if curl -fsSL --head --connect-timeout 10 "${PROFILE_URL}" >/dev/null 2>&1; then
        log_success "✅ Provisioning profile URL accessible"
        
        # Test UUID extraction
        local temp_profile="/tmp/cert_validation_profile.mobileprovision"
        if curl -fsSL -o "$temp_profile" "${PROFILE_URL}" 2>/dev/null; then
            local uuid
            uuid=$(security cms -D -i "$temp_profile" 2>/dev/null | plutil -extract UUID xml1 -o - - 2>/dev/null | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p' | head -1)
            
            if [ -n "$uuid" ] && [[ "$uuid" =~ ^[A-Fa-f0-9]{8}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{12}$ ]]; then
                log_success "✅ UUID extraction test successful: $uuid"
            else
                log_error "❌ UUID extraction failed or invalid format"
            fi
            
            rm -f "$temp_profile"
        else
            log_error "❌ Provisioning profile download failed"
        fi
    else
        log_error "❌ Provisioning profile URL not accessible"
        return 1
    fi
    
    return 0
}

# Check certificate signing fix scripts
check_signing_fix_scripts() {
    log_info "🛠️ Checking certificate signing fix scripts..."
    
    local fix_scripts=(
        "certificate_signing_fix_503ceb9c.sh"
        "certificate_signing_fix_8d2aeb71.sh"
        "comprehensive_certificate_validation.sh"
    )
    
    local available_fixes=0
    for script in "${fix_scripts[@]}"; do
        if [ -f "${SCRIPT_DIR}/$script" ]; then
            log_success "✅ $script available"
            available_fixes=$((available_fixes + 1))
        else
            log_warn "⚠️ $script missing"
        fi
    done
    
    if [ "$available_fixes" -ge 2 ]; then
        log_success "✅ Good certificate fix coverage ($available_fixes/${#fix_scripts[@]})"
    else
        log_warn "⚠️ Limited certificate fix coverage ($available_fixes/${#fix_scripts[@]})"
    fi
    
    return 0
}

# Generate certificate chain report
generate_certificate_report() {
    log_info "📋 Generating certificate chain validation report..."
    
    local report_file="certificate_chain_validation_$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$report_file" << EOF
Certificate Chain Validation Report
===================================
Generated: $(date)

Configuration Summary:
----------------------
P12 Method: $([ -n "${CERT_P12_URL:-}" ] && echo "Configured" || echo "Not configured")
CER+KEY Method: $([ -n "${CERT_CER_URL:-}" ] && echo "Configured" || echo "Not configured")
App Store Connect API: $([ -n "${APP_STORE_CONNECT_API_KEY_PATH:-}" ] && echo "Configured" || echo "Not configured")
Apple Team ID: ${APPLE_TEAM_ID:-"Not configured"}
Provisioning Profile: $([ -n "${PROFILE_URL:-}" ] && echo "Configured" || echo "Not configured")

Recommendations:
----------------
1. Configure multiple certificate methods for redundancy
2. Ensure all URLs are accessible from build environment
3. Validate certificate formats and credentials
4. Test UUID extraction before builds
5. Keep certificate signing fix scripts updated

Next Steps:
-----------
1. Address any configuration gaps
2. Test certificate methods in build environment
3. Implement comprehensive certificate validation
4. Monitor for certificate expiration
EOF

    log_success "✅ Certificate chain report generated: $report_file"
    return 0
}

# Main validation function
main() {
    log_info "🚀 Certificate Chain Validation Starting..."
    
    local validation_passed=true
    
    # Run all validations
    validate_p12_method || true
    validate_cer_key_method || true
    validate_app_store_connect_api || true
    
    if ! validate_apple_team_id; then
        validation_passed=false
    fi
    
    if ! validate_provisioning_profile; then
        validation_passed=false
    fi
    
    check_certificate_redundancy
    check_signing_fix_scripts
    generate_certificate_report
    
    if [ "$validation_passed" = true ]; then
        log_success "✅ Certificate chain validation passed"
        return 0
    else
        log_error "❌ Certificate chain validation failed - address critical issues"
        return 1
    fi
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi 