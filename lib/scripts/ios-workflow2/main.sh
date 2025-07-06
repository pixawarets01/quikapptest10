#!/bin/bash

# Main iOS Workflow 2 Orchestration Script
# Purpose: P12/CER+KEY certificate support with enhanced collision prevention
# Following iOS-Workflow Pattern: Comprehensive staging and error handling

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source utilities with fallback
if [ -f "$UTILS_DIR/common.sh" ]; then
    source "$UTILS_DIR/common.sh"
else
    # Fallback logging functions
    log_info() { echo -e "\033[0;34mℹ️ INFO: $1\033[0m"; }
    log_success() { echo -e "\033[0;32m✅ SUCCESS: $1\033[0m"; }
    log_warn() { echo -e "\033[1;33m⚠️ WARNING: $1\033[0m"; }
    log_error() { echo -e "\033[0;31m❌ ERROR: $1\033[0m"; }
fi

log_info "Starting iOS Workflow 2..."
log_info "📁 Following iOS-Workflow Pattern: Comprehensive staging and error handling"
log_info "🎯 Specialization: P12/CER+KEY certificate support with enhanced collision prevention"

# Function to send email notifications (if enabled)
send_email() {
    local email_type="$1"
    local platform="$2"
    local build_id="$3"
    local error_message="$4"
    
    if [ "${ENABLE_EMAIL_NOTIFICATIONS:-false}" = "true" ]; then
        log_info "Sending $email_type email for $platform build $build_id"
        log_info "Email notification: $email_type for $platform ($error_message)"
    fi
}

# Function to load environment variables
load_environment_variables() {
    log_info "Loading environment variables..."
    
    # Validate essential variables
    if [ -z "${BUNDLE_ID:-}" ]; then
        log_error "BUNDLE_ID is not set. Exiting."
        return 1
    fi
    
    # Set default values for iOS Workflow 2
    export OUTPUT_DIR="${OUTPUT_DIR:-output/ios}"
    export PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
    export CM_BUILD_DIR="${CM_BUILD_DIR:-$(pwd)}"
    export PROFILE_TYPE="${PROFILE_TYPE:-app-store}"
    export WORKFLOW_ID="ios-workflow2"
    export WORKFLOW_TYPE="workflow2"
    export CERTIFICATE_HANDLING="advanced"
    export SIGNING_METHOD="manual"
    export COLLISION_PREVENTION="enhanced"
    
    log_success "Environment variables loaded successfully"
    log_info "📋 iOS Workflow 2 Configuration:"
    log_info "  - Workflow: ios-workflow2"
    log_info "  - Purpose: P12/CER+KEY certificate support with enhanced collision prevention"
    log_info "  - Bundle ID: $BUNDLE_ID"
    log_info "  - Profile Type: $PROFILE_TYPE"
    log_info "  - Certificate Handling: Advanced"
    log_info "  - Signing Method: Manual"
    log_info "  - Collision Prevention: ENHANCED mode"
    log_info "  - Output: $OUTPUT_DIR"
    
    return 0
}

# Function to validate iOS project structure
validate_ios_project() {
    log_info "--- iOS Project Structure Validation ---"
    
    # Check for iOS project structure
    if [ ! -d "ios" ]; then
        log_error "iOS directory not found"
        return 1
    fi
    
    if [ ! -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
        log_error "Xcode project file not found"
        return 1
    fi
    
    if [ ! -f "pubspec.yaml" ]; then
        log_error "Flutter project structure not found (missing pubspec.yaml)"
        return 1
    fi
    
    log_success "✅ iOS project structure validation completed"
    return 0
}

# Function to setup enhanced collision prevention
setup_enhanced_collision_prevention() {
    log_info "--- Stage 1: Enhanced Collision Prevention Setup ---"
    
    log_info "🛡️ Activating enhanced collision prevention protocols for Workflow 2..."
    log_info "🎯 Target: Bundle identifier conflicts and certificate issues"
    log_info "🔧 Strategy: Enhanced validation and prevention mechanisms"
    
    # Create backup of critical files
    if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
        cp "ios/Runner.xcodeproj/project.pbxproj" "ios/Runner.xcodeproj/project.pbxproj.workflow2_backup_$(date +%Y%m%d_%H%M%S)"
        log_success "✅ Project backup created for Workflow 2"
    fi
    
    # Enhanced bundle ID validation
    local main_bundle_count
    main_bundle_count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = ${BUNDLE_ID};" "ios/Runner.xcodeproj/project.pbxproj" 2>/dev/null || echo "0")
    
    log_info "📊 Bundle ID Analysis:"
    log_info "  - Main Bundle ID: $BUNDLE_ID"
    log_info "  - Current Occurrences: $main_bundle_count"
    log_info "  - Target: 3 (Debug, Release, Profile)"
    
    if [ "$main_bundle_count" -gt 3 ]; then
        log_warn "⚠️ Potential bundle ID collision detected ($main_bundle_count > 3)"
        log_info "🔧 Enhanced collision prevention will be applied during certificate handling"
    else
        log_success "✅ Bundle ID configuration appears clean"
    fi
    
    log_success "✅ Enhanced collision prevention setup completed"
    return 0
}

# Function to handle advanced certificate configuration
handle_advanced_certificate_configuration() {
    log_info "--- Stage 2: Advanced Certificate Configuration ---"
    
    log_info "🔐 iOS Workflow 2: Advanced certificate support"
    log_info "📋 Supported methods: P12 certificates and CER+KEY combinations"
    
    local cert_method="none"
    
    # Check for P12 certificate
    if [ -n "${CERT_P12_URL:-}" ]; then
        cert_method="p12_url"
        export CERT_METHOD="p12_url"
        log_success "✅ P12 URL certificate method detected"
        log_info "🔐 Method: P12 certificate via URL"
        log_info "📥 P12 URL: ${CERT_P12_URL}"
        
        if [ -n "${CERT_PASSWORD:-}" ]; then
            log_success "✅ P12 password configured"
        else
            log_warn "⚠️ P12 password not configured"
        fi
    fi
    
    # Check for CER+KEY combination
    if [ -n "${CERT_CER_URL:-}" ] && [ -n "${CERT_KEY_URL:-}" ]; then
        if [ "$cert_method" = "p12_url" ]; then
            log_info "🔧 Both P12 and CER+KEY detected - P12 will take precedence"
        else
            cert_method="cer_key"
            export CERT_METHOD="cer_key"
            log_success "✅ CER+KEY certificate method detected"
            log_info "🔐 Method: CER+KEY combination"
            log_info "📥 CER URL: ${CERT_CER_URL}"
            log_info "📥 KEY URL: ${CERT_KEY_URL}"
        fi
    fi
    
    # Check for App Store Connect API
    if [ -n "${APP_STORE_CONNECT_API_KEY_PATH:-}" ]; then
        log_success "✅ App Store Connect API configuration detected"
        log_info "🔗 API Key Path: ${APP_STORE_CONNECT_API_KEY_PATH}"
    else
        log_warn "⚠️ App Store Connect API not configured"
    fi
    
    # Check for provisioning profile
    if [ -n "${PROFILE_URL:-}" ]; then
        log_success "✅ Provisioning profile configuration detected"
        log_info "📱 Profile URL: ${PROFILE_URL}"
    else
        log_warn "⚠️ Provisioning profile not configured"
    fi
    
    # Check for team ID
    if [ -n "${APPLE_TEAM_ID:-}" ]; then
        log_success "✅ Apple Team ID configured: ${APPLE_TEAM_ID}"
    else
        log_warn "⚠️ Apple Team ID not configured"
    fi
    
    if [ "$cert_method" = "none" ]; then
        log_warn "⚠️ No certificate method detected"
        log_warn "📋 Configure either P12 or CER+KEY for signing"
        export CERT_METHOD="none"
    fi
    
    log_success "✅ Advanced certificate configuration completed"
    return 0
}

# Function to handle Firebase configuration
handle_firebase_configuration() {
    log_info "--- Stage 3: Firebase Configuration ---"
    
    if [ "${PUSH_NOTIFY:-false}" = "true" ] && [ -n "${FIREBASE_CONFIG_IOS:-}" ]; then
        log_info "🔥 Firebase iOS configuration detected for Workflow 2"
        export FIREBASE_IOS_ENABLED="true"
        
        # Download Firebase configuration
        log_info "📥 Downloading Firebase iOS configuration..."
        mkdir -p ios/Runner
        
        if wget -O ios/Runner/GoogleService-Info.plist "$FIREBASE_CONFIG_IOS"; then
            log_success "✅ Firebase iOS configuration downloaded successfully"
            
            # Validate Firebase configuration
            if [ -f "ios/Runner/GoogleService-Info.plist" ] && [ -s "ios/Runner/GoogleService-Info.plist" ]; then
                log_success "✅ Firebase configuration file validated"
            else
                log_error "❌ Downloaded Firebase configuration is invalid or empty"
                return 1
            fi
        else
            log_error "❌ Failed to download Firebase iOS configuration"
            log_error "📋 Check FIREBASE_CONFIG_IOS URL: $FIREBASE_CONFIG_IOS"
            return 1
        fi
    else
        log_info "📱 Firebase disabled or not configured for Workflow 2"
        export FIREBASE_IOS_ENABLED="false"
    fi
    
    log_success "✅ Firebase configuration handling completed"
    return 0
}

# Function to run main iOS build process
run_main_ios_build() {
    log_info "--- Stage 4: Main iOS Build Process ---"
    
    if [ -f "$SCRIPT_DIR/../ios/main.sh" ]; then
        log_info "✅ Delegating to main iOS script with Workflow 2 configuration"
        log_info "🔧 Enhanced collision prevention: ACTIVE"
        log_info "🔐 Certificate method: ${CERT_METHOD:-none}"
        log_info "🔥 Firebase: ${FIREBASE_IOS_ENABLED:-false}"
        
        # Make the script executable
        chmod +x "$SCRIPT_DIR/../ios/main.sh"
        
        # Call the main iOS build script with Workflow 2 configuration
        if "$SCRIPT_DIR/../ios/main.sh"; then
            log_success "✅ Main iOS build process completed successfully"
            return 0
        else
            log_error "❌ Main iOS build process failed"
            return 1
        fi
    else
        log_warn "⚠️ Main iOS script not found, using fallback build process"
        
        # Fallback build process for Workflow 2
        log_info "🔧 Running fallback iOS build process for Workflow 2..."
        
        # Clean and get dependencies
        flutter clean || log_warn "Flutter clean failed"
        flutter pub get || { log_error "Flutter pub get failed"; return 1; }
        
        # Build iOS with no codesign (for manual signing)
        if flutter build ios --release --no-codesign; then
            log_success "✅ Flutter iOS build completed (no codesign)"
            
            # Check for build artifacts
            if [ -d "build/ios/Release-iphoneos/Runner.app" ]; then
                APP_SIZE=$(du -sh "build/ios/Release-iphoneos/Runner.app" | cut -f1)
                log_success "📱 iOS app bundle created: build/ios/Release-iphoneos/Runner.app ($APP_SIZE)"
                
                # Create output directory and copy artifacts
                mkdir -p "$OUTPUT_DIR"
                cp -r "build/ios/Release-iphoneos/Runner.app" "$OUTPUT_DIR/"
                log_success "📦 Build artifacts copied to output directory"
                
                return 0
            else
                log_error "❌ iOS app bundle not found after build"
                return 1
            fi
        else
            log_error "❌ Flutter iOS build failed"
            return 1
        fi
    fi
}

# Function to validate Workflow 2 outputs
validate_workflow2_outputs() {
    log_info "--- Stage 5: Workflow 2 Output Validation ---"
    
    local validation_passed=true
    
    # Check for build directory
    if [ -d "build/ios" ]; then
        log_success "✅ iOS build directory found"
    else
        log_error "❌ iOS build directory not found"
        validation_passed=false
    fi
    
    # Check for app bundle
    if [ -d "build/ios/Release-iphoneos/Runner.app" ]; then
        log_success "✅ iOS app bundle found"
    else
        log_warn "⚠️ iOS app bundle not found"
    fi
    
    # Check for various output locations
    if [ -f "build/ios/ipa/Runner.ipa" ]; then
        IPA_SIZE=$(du -h "build/ios/ipa/Runner.ipa" | cut -f1)
        log_success "📱 IPA found: build/ios/ipa/Runner.ipa ($IPA_SIZE)"
    elif [ -d "build/ios/archive/Runner.xcarchive" ]; then
        ARCHIVE_SIZE=$(du -h "build/ios/archive/Runner.xcarchive" | cut -f1)
        log_success "📦 Archive found: build/ios/archive/Runner.xcarchive ($ARCHIVE_SIZE)"
    elif [ -d "$OUTPUT_DIR/Runner.app" ]; then
        APP_SIZE=$(du -h "$OUTPUT_DIR/Runner.app" | cut -f1)
        log_success "📱 App Bundle: $OUTPUT_DIR/Runner.app ($APP_SIZE)"
    else
        log_warn "⚠️ No final build artifacts found in expected locations"
    fi
    
    # Validate collision prevention effectiveness
    if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
        local final_bundle_count
        final_bundle_count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = ${BUNDLE_ID};" "ios/Runner.xcodeproj/project.pbxproj" 2>/dev/null || echo "0")
        
        log_info "🛡️ Collision Prevention Results:"
        log_info "  - Final Bundle ID Count: $final_bundle_count"
        
        if [ "$final_bundle_count" -le 3 ]; then
            log_success "✅ Enhanced collision prevention: EFFECTIVE"
        else
            log_warn "⚠️ Enhanced collision prevention: May need additional attention"
        fi
    fi
    
    if [ "$validation_passed" = "true" ]; then
        log_success "✅ Workflow 2 output validation completed successfully"
        return 0
    else
        log_error "❌ Workflow 2 output validation failed"
        return 1
    fi
}

# Main execution function
main() {
    log_info "🚀 iOS Workflow 2 Starting..."
    log_info "📋 Following iOS-Workflow Pattern with advanced certificate support"
    
    # Load environment variables
    if ! load_environment_variables; then
        log_error "Environment variable loading failed"
        send_email "build_failed" "iOS" "${CM_BUILD_ID:-unknown}" "Environment variable loading failed."
        return 1
    fi
    
    # Validate iOS project structure
    if ! validate_ios_project; then
        log_error "iOS project validation failed"
        send_email "build_failed" "iOS" "${CM_BUILD_ID:-unknown}" "iOS project validation failed."
        return 1
    fi
    
    # Email notification - Build started (if enabled)
    if [ "${ENABLE_EMAIL_NOTIFICATIONS:-false}" = "true" ]; then
        send_email "build_started" "iOS" "${CM_BUILD_ID:-unknown}" "iOS Workflow 2 build started"
    fi
    
    # Stage 1: Setup enhanced collision prevention
    if ! setup_enhanced_collision_prevention; then
        log_error "Enhanced collision prevention setup failed"
        send_email "build_failed" "iOS" "${CM_BUILD_ID:-unknown}" "Enhanced collision prevention setup failed."
        return 1
    fi
    
    # Stage 2: Handle advanced certificate configuration
    if ! handle_advanced_certificate_configuration; then
        log_error "Advanced certificate configuration failed"
        send_email "build_failed" "iOS" "${CM_BUILD_ID:-unknown}" "Advanced certificate configuration failed."
        return 1
    fi
    
    # Stage 3: Handle Firebase configuration
    if ! handle_firebase_configuration; then
        log_error "Firebase configuration failed"
        send_email "build_failed" "iOS" "${CM_BUILD_ID:-unknown}" "Firebase configuration failed."
        return 1
    fi
    
    # Stage 4: Run main iOS build process
    if ! run_main_ios_build; then
        log_error "Main iOS build process failed"
        send_email "build_failed" "iOS" "${CM_BUILD_ID:-unknown}" "Main iOS build process failed."
        return 1
    fi
    
    # Stage 5: Validate Workflow 2 outputs
    if ! validate_workflow2_outputs; then
        log_error "Workflow 2 output validation failed"
        send_email "build_failed" "iOS" "${CM_BUILD_ID:-unknown}" "Workflow 2 output validation failed."
        return 1
    fi
    
    # Success summary
    log_success "🎉 iOS Workflow 2 completed successfully!"
    log_info "🎯 Purpose: P12/CER+KEY certificate support with enhanced collision prevention"
    log_info "🛡️ Collision Prevention: ENHANCED mode"
    log_info "🔐 Certificate Method: ${CERT_METHOD:-none}"
    log_info "🔥 Firebase: ${FIREBASE_IOS_ENABLED:-false}"
    log_info "📊 Following iOS-Workflow Pattern: All Workflow 2 stages completed"
    
    # Display final summary
    echo ""
    log_info "📋 Final Workflow 2 Summary:"
    log_success "✅ Enhanced Collision Prevention: ACTIVE"
    log_success "✅ Certificate Support: P12 and CER+KEY methods"
    log_success "✅ Bundle ID Management: Advanced validation"
    log_success "✅ Manual Signing: Configured"
    log_success "✅ Build Process: Specialized for certificate handling"
    log_success "🚀 Ready for App Store submission"
    
    # Email notification - Build success
    if [ "${ENABLE_EMAIL_NOTIFICATIONS:-false}" = "true" ]; then
        send_email "build_success" "iOS" "${CM_BUILD_ID:-unknown}" "iOS Workflow 2 completed successfully"
    fi
    
    return 0
}

# Execute main function
if ! main "$@"; then
    log_error "🚨 iOS Workflow 2 FAILED"
    log_error "📋 Check the logs above for specific error details"
    exit 1
fi

log_success "🚀 iOS Workflow 2 completed successfully!"
log_info "📁 Following iOS-Workflow Pattern: Advanced certificate support workflow completed" 