#!/bin/bash

# Environment Variable Validator for iOS Workflow
# Purpose: Validate all required environment variables before iOS build starts

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

log_info "🔍 Starting Environment Variable Validation for iOS Workflow..."

# Function to validate required variable
validate_required_variable() {
    local var_name="$1"
    local var_value="${!var_name:-}"
    local description="$2"
    local is_url="${3:-false}"
    
    if [ -z "$var_value" ]; then
        log_error "❌ Required variable $var_name is not set"
        log_error "   Description: $description"
        return 1
    else
        if [ "$is_url" = "true" ]; then
            # Validate URL format
            if [[ "$var_value" =~ ^https?:// ]]; then
                log_success "✅ $var_name: URL format valid"
            else
                log_warn "⚠️ $var_name: May not be a valid URL format"
            fi
        else
            log_success "✅ $var_name: Set"
        fi
        return 0
    fi
}

# Function to validate optional variable
validate_optional_variable() {
    local var_name="$1"
    local var_value="${!var_name:-}"
    local description="$2"
    local is_url="${3:-false}"
    
    if [ -z "$var_value" ]; then
        log_info "⏭️ $var_name: Not set (optional)"
    else
        if [ "$is_url" = "true" ]; then
            # Validate URL format
            if [[ "$var_value" =~ ^https?:// ]]; then
                log_success "✅ $var_name: URL format valid"
            else
                log_warn "⚠️ $var_name: May not be a valid URL format"
            fi
        else
            log_success "✅ $var_name: Set"
        fi
    fi
    return 0
}

# Function to validate boolean variable
validate_boolean_variable() {
    local var_name="$1"
    local var_value="${!var_name:-}"
    local description="$2"
    
    case "${var_value:-}" in
        "true"|"TRUE"|"True"|"1"|"yes"|"YES"|"Yes")
            log_success "✅ $var_name: true"
            ;;
        "false"|"FALSE"|"False"|"0"|"no"|"NO"|"No"|"")
            log_success "✅ $var_name: false"
            ;;
        *)
            log_warn "⚠️ $var_name: Invalid boolean value '$var_value' (defaulting to false)"
            ;;
    esac
    return 0
}

# Function to validate profile type
validate_profile_type() {
    local profile_type="${PROFILE_TYPE:-}"
    
    case "$profile_type" in
        "app-store"|"appstore")
            log_success "✅ PROFILE_TYPE: app-store"
            ;;
        "ad-hoc"|"adhoc")
            log_success "✅ PROFILE_TYPE: ad-hoc"
            ;;
        "enterprise")
            log_success "✅ PROFILE_TYPE: enterprise"
            ;;
        "development"|"dev")
            log_success "✅ PROFILE_TYPE: development"
            ;;
        "developer_id")
            log_success "✅ PROFILE_TYPE: developer_id"
            ;;
        *)
            log_error "❌ PROFILE_TYPE: Invalid value '$profile_type'"
            log_error "   Valid values: app-store, ad-hoc, enterprise, development, developer_id"
            return 1
            ;;
    esac
    return 0
}

# Function to validate certificate configuration
validate_certificate_config() {
    local has_p12=false
    local has_cer_key=false
    
    # Check P12 flow
    if [ -n "${CERT_P12_URL:-}" ]; then
        has_p12=true
        validate_required_variable "CERT_P12_URL" "P12 certificate URL" "true"
        validate_required_variable "CERT_PASSWORD" "Certificate password for P12"
    fi
    
    # Check CER+KEY flow
    if [ -n "${CERT_CER_URL:-}" ] && [ -n "${CERT_KEY_URL:-}" ]; then
        has_cer_key=true
        validate_required_variable "CERT_CER_URL" "Certificate CER file URL" "true"
        validate_required_variable "CERT_KEY_URL" "Private key file URL" "true"
        validate_required_variable "CERT_PASSWORD" "Certificate password for CER+KEY"
    fi
    
    # Validate that at least one certificate method is configured
    if [ "$has_p12" = "false" ] && [ "$has_cer_key" = "false" ]; then
        log_error "❌ No certificate configuration found"
        log_error "   Either CERT_P12_URL or (CERT_CER_URL + CERT_KEY_URL) must be set"
        return 1
    fi
    
    if [ "$has_p12" = "true" ] && [ "$has_cer_key" = "true" ]; then
        log_warn "⚠️ Both P12 and CER+KEY configurations found"
        log_warn "   P12 configuration will be used (CERT_P12_URL takes precedence)"
    fi
    
    return 0
}

# Function to validate App Store Connect configuration
validate_app_store_connect_config() {
    if [ "${PROFILE_TYPE:-}" = "app-store" ] || [ "${PROFILE_TYPE:-}" = "appstore" ]; then
        log_info "🔍 Validating App Store Connect configuration for app-store profile..."
        
        validate_required_variable "APP_STORE_CONNECT_KEY_IDENTIFIER" "App Store Connect API Key ID"
        validate_required_variable "APP_STORE_CONNECT_API_KEY" "App Store Connect API Key URL" "true"
        validate_required_variable "APP_STORE_CONNECT_ISSUER_ID" "App Store Connect Issuer ID"
        
        # Optional for app store
        validate_optional_variable "APPLE_ID" "Apple ID for App Store Connect"
        validate_optional_variable "APPLE_ID_PASSWORD" "Apple ID password/app-specific password"
    else
        log_info "⏭️ App Store Connect validation skipped (not app-store profile)"
    fi
}

# Function to validate Firebase configuration
validate_firebase_config() {
    if [ "${PUSH_NOTIFY:-false}" = "true" ]; then
        log_info "🔍 Validating Firebase configuration for push notifications..."
        
        validate_required_variable "FIREBASE_CONFIG_IOS" "iOS Firebase configuration URL" "true"
        validate_optional_variable "FIREBASE_CONFIG_ANDROID" "Android Firebase configuration URL" "true"
        
        # Validate APNS configuration for iOS push notifications
        validate_required_variable "APPLE_TEAM_ID" "Apple Team ID for APNS"
        validate_required_variable "APNS_KEY_ID" "APNS Key ID"
        validate_required_variable "APNS_AUTH_KEY_URL" "APNS Auth Key URL" "true"
    else
        log_info "⏭️ Firebase validation skipped (PUSH_NOTIFY=false)"
    fi
}

# Function to validate email configuration
validate_email_config() {
    if [ "${ENABLE_EMAIL_NOTIFICATIONS:-false}" = "true" ]; then
        log_info "🔍 Validating email notification configuration..."
        
        validate_required_variable "EMAIL_SMTP_SERVER" "SMTP server address"
        validate_required_variable "EMAIL_SMTP_PORT" "SMTP server port"
        validate_required_variable "EMAIL_SMTP_USER" "SMTP username"
        validate_required_variable "EMAIL_SMTP_PASS" "SMTP password"
    else
        log_info "⏭️ Email validation skipped (ENABLE_EMAIL_NOTIFICATIONS=false)"
    fi
}

# Function to validate Android configuration (for reference)
validate_android_config() {
    log_info "🔍 Validating Android configuration..."
    
    validate_required_variable "KEY_STORE_URL" "Android keystore URL" "true"
    validate_required_variable "CM_KEYSTORE_PASSWORD" "Android keystore password"
    validate_required_variable "CM_KEY_ALIAS" "Android key alias"
    validate_required_variable "CM_KEY_PASSWORD" "Android key password"
}

# Function to validate app configuration
validate_app_config() {
    log_info "🔍 Validating app configuration..."
    
    # Core app variables
    validate_required_variable "APP_ID" "App ID"
    validate_required_variable "VERSION_NAME" "App version name"
    validate_required_variable "VERSION_CODE" "App version code"
    validate_required_variable "APP_NAME" "App name"
    validate_required_variable "ORG_NAME" "Organization name"
    validate_required_variable "BUNDLE_ID" "iOS bundle identifier"
    validate_required_variable "PKG_NAME" "Android package name"
    
    # URLs
    validate_required_variable "WEB_URL" "Web URL" "true"
    validate_optional_variable "LOGO_URL" "Logo URL" "true"
    validate_optional_variable "SPLASH_URL" "Splash screen URL" "true"
    validate_optional_variable "SPLASH_BG_URL" "Splash background URL" "true"
    
    # Profile configuration
    validate_required_variable "PROFILE_TYPE" "Profile type"
    validate_required_variable "PROFILE_URL" "Provisioning profile URL" "true"
}

# Function to validate feature flags
validate_feature_flags() {
    log_info "🔍 Validating feature flags..."
    
    # Boolean feature flags
    validate_boolean_variable "PUSH_NOTIFY" "Push notifications"
    validate_boolean_variable "IS_CHATBOT" "Chatbot feature"
    validate_boolean_variable "IS_DOMAIN_URL" "Domain URL feature"
    validate_boolean_variable "IS_SPLASH" "Splash screen"
    validate_boolean_variable "IS_PULLDOWN" "Pull to refresh"
    validate_boolean_variable "IS_BOTTOMMENU" "Bottom menu"
    validate_boolean_variable "IS_LOAD_IND" "Loading indicator"
    validate_boolean_variable "IS_TESTFLIGHT" "TestFlight distribution"
    validate_boolean_variable "ENABLE_EMAIL_NOTIFICATIONS" "Email notifications"
    
    # Permission flags
    validate_boolean_variable "IS_CAMERA" "Camera permission"
    validate_boolean_variable "IS_LOCATION" "Location permission"
    validate_boolean_variable "IS_MIC" "Microphone permission"
    validate_boolean_variable "IS_NOTIFICATION" "Notification permission"
    validate_boolean_variable "IS_CONTACT" "Contacts permission"
    validate_boolean_variable "IS_BIOMETRIC" "Biometric permission"
    validate_boolean_variable "IS_CALENDAR" "Calendar permission"
    validate_boolean_variable "IS_STORAGE" "Storage permission"
}

# Function to validate UI configuration
validate_ui_config() {
    log_info "🔍 Validating UI configuration..."
    
    # Splash screen configuration
    if [ "${IS_SPLASH:-false}" = "true" ]; then
        validate_optional_variable "SPLASH_BG_COLOR" "Splash background color"
        validate_optional_variable "SPLASH_TAGLINE" "Splash tagline"
        validate_optional_variable "SPLASH_TAGLINE_COLOR" "Splash tagline color"
        validate_optional_variable "SPLASH_ANIMATION" "Splash animation type"
        validate_optional_variable "SPLASH_DURATION" "Splash duration"
    fi
    
    # Bottom menu configuration
    if [ "${IS_BOTTOMMENU:-false}" = "true" ]; then
        validate_required_variable "BOTTOMMENU_ITEMS" "Bottom menu items JSON"
        validate_optional_variable "BOTTOMMENU_BG_COLOR" "Bottom menu background color"
        validate_optional_variable "BOTTOMMENU_ICON_COLOR" "Bottom menu icon color"
        validate_optional_variable "BOTTOMMENU_TEXT_COLOR" "Bottom menu text color"
        validate_optional_variable "BOTTOMMENU_FONT" "Bottom menu font"
        validate_optional_variable "BOTTOMMENU_FONT_SIZE" "Bottom menu font size"
        validate_optional_variable "BOTTOMMENU_ACTIVE_TAB_COLOR" "Bottom menu active tab color"
        validate_optional_variable "BOTTOMMENU_ICON_POSITION" "Bottom menu icon position"
    fi
}

# Function to validate workflow configuration
validate_workflow_config() {
    log_info "🔍 Validating workflow configuration..."
    
    validate_optional_variable "WORKFLOW_ID" "Workflow ID"
    validate_optional_variable "USER_NAME" "User name"
    validate_optional_variable "EMAIL_ID" "Email ID"
    validate_optional_variable "BRANCH" "Git branch"
}

# Function to create validation summary
create_validation_summary() {
    local summary_file="ENVIRONMENT_VALIDATION_SUMMARY.txt"
    local validation_status="$1"
    
    cat > "$summary_file" << SUMMARY_EOF
=== Environment Variable Validation Summary ===
Date: $(date)
Validation Status: $validation_status

=== Core App Configuration ===
APP_ID: ${APP_ID:-NOT_SET}
VERSION_NAME: ${VERSION_NAME:-NOT_SET}
VERSION_CODE: ${VERSION_CODE:-NOT_SET}
APP_NAME: ${APP_NAME:-NOT_SET}
ORG_NAME: ${ORG_NAME:-NOT_SET}
BUNDLE_ID: ${BUNDLE_ID:-NOT_SET}
PKG_NAME: ${PKG_NAME:-NOT_SET}
WEB_URL: ${WEB_URL:-NOT_SET}

=== Profile Configuration ===
PROFILE_TYPE: ${PROFILE_TYPE:-NOT_SET}
PROFILE_URL: ${PROFILE_URL:+SET}

=== Certificate Configuration ===
CERT_P12_URL: ${CERT_P12_URL:+SET}
CERT_CER_URL: ${CERT_CER_URL:+SET}
CERT_KEY_URL: ${CERT_KEY_URL:+SET}
CERT_PASSWORD: ${CERT_PASSWORD:+SET}

=== Firebase Configuration ===
PUSH_NOTIFY: ${PUSH_NOTIFY:-false}
FIREBASE_CONFIG_IOS: ${FIREBASE_CONFIG_IOS:+SET}
FIREBASE_CONFIG_ANDROID: ${FIREBASE_CONFIG_ANDROID:+SET}
APPLE_TEAM_ID: ${APPLE_TEAM_ID:-NOT_SET}
APNS_KEY_ID: ${APNS_KEY_ID:-NOT_SET}
APNS_AUTH_KEY_URL: ${APNS_AUTH_KEY_URL:+SET}

=== App Store Connect Configuration ===
APP_STORE_CONNECT_KEY_IDENTIFIER: ${APP_STORE_CONNECT_KEY_IDENTIFIER:-NOT_SET}
APP_STORE_CONNECT_API_KEY: ${APP_STORE_CONNECT_API_KEY:+SET}
APP_STORE_CONNECT_ISSUER_ID: ${APP_STORE_CONNECT_ISSUER_ID:-NOT_SET}
APPLE_ID: ${APPLE_ID:-NOT_SET}

=== Android Configuration ===
KEY_STORE_URL: ${KEY_STORE_URL:+SET}
CM_KEYSTORE_PASSWORD: ${CM_KEYSTORE_PASSWORD:+SET}
CM_KEY_ALIAS: ${CM_KEY_ALIAS:-NOT_SET}
CM_KEY_PASSWORD: ${CM_KEY_PASSWORD:+SET}

=== Feature Flags ===
IS_CHATBOT: ${IS_CHATBOT:-false}
IS_DOMAIN_URL: ${IS_DOMAIN_URL:-false}
IS_SPLASH: ${IS_SPLASH:-false}
IS_PULLDOWN: ${IS_PULLDOWN:-false}
IS_BOTTOMMENU: ${IS_BOTTOMMENU:-false}
IS_LOAD_IND: ${IS_LOAD_IND:-false}
IS_TESTFLIGHT: ${IS_TESTFLIGHT:-false}

=== Permissions ===
IS_CAMERA: ${IS_CAMERA:-false}
IS_LOCATION: ${IS_LOCATION:-false}
IS_MIC: ${IS_MIC:-false}
IS_NOTIFICATION: ${IS_NOTIFICATION:-false}
IS_CONTACT: ${IS_CONTACT:-false}
IS_BIOMETRIC: ${IS_BIOMETRIC:-false}
IS_CALENDAR: ${IS_CALENDAR:-false}
IS_STORAGE: ${IS_STORAGE:-false}

=== Email Configuration ===
ENABLE_EMAIL_NOTIFICATIONS: ${ENABLE_EMAIL_NOTIFICATIONS:-false}
EMAIL_SMTP_SERVER: ${EMAIL_SMTP_SERVER:-NOT_SET}
EMAIL_SMTP_PORT: ${EMAIL_SMTP_PORT:-NOT_SET}
EMAIL_SMTP_USER: ${EMAIL_SMTP_USER:-NOT_SET}
EMAIL_SMTP_PASS: ${EMAIL_SMTP_PASS:+SET}

=== Workflow Configuration ===
WORKFLOW_ID: ${WORKFLOW_ID:-NOT_SET}
USER_NAME: ${USER_NAME:-NOT_SET}
EMAIL_ID: ${EMAIL_ID:-NOT_SET}
BRANCH: ${BRANCH:-NOT_SET}

Environment validation completed!
SUMMARY_EOF
    
    log_success "✅ Validation summary created: $summary_file"
}

# Main validation function
main() {
    log_info "🚀 Starting comprehensive environment variable validation..."
    
    local validation_failed=false
    
    # Validate core app configuration
    if ! validate_app_config; then
        validation_failed=true
    fi
    
    # Validate profile type
    if ! validate_profile_type; then
        validation_failed=true
    fi
    
    # Validate certificate configuration
    if ! validate_certificate_config; then
        validation_failed=true
    fi
    
    # Validate App Store Connect configuration
    if ! validate_app_store_connect_config; then
        validation_failed=true
    fi
    
    # Validate Firebase configuration
    if ! validate_firebase_config; then
        validation_failed=true
    fi
    
    # Validate Android configuration
    if ! validate_android_config; then
        validation_failed=true
    fi
    
    # Validate feature flags
    validate_feature_flags
    
    # Validate UI configuration
    validate_ui_config
    
    # Validate email configuration
    if ! validate_email_config; then
        validation_failed=true
    fi
    
    # Validate workflow configuration
    validate_workflow_config
    
    # Create validation summary
    if [ "$validation_failed" = "true" ]; then
        create_validation_summary "FAILED"
        log_error "❌ Environment validation failed - please fix the issues above"
        return 1
    else
        create_validation_summary "PASSED"
        log_success "✅ All environment variables validated successfully!"
        log_info "📋 Validation summary created: ENVIRONMENT_VALIDATION_SUMMARY.txt"
        return 0
    fi
}

# Execute main function if script is run directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi 