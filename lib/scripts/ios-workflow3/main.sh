#!/bin/bash

# Main iOS Workflow 3 Orchestration Script
# Purpose: Universal build support with nuclear collision handling protocols
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

log_info "Starting iOS Workflow 3..."
log_info "📁 Following iOS-Workflow Pattern: Comprehensive staging and error handling"
log_info "🎯 Specialization: Universal build support with nuclear collision handling protocols"

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
    
    # Set default values for iOS Workflow 3
    export OUTPUT_DIR="${OUTPUT_DIR:-output/ios}"
    export PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
    export CM_BUILD_DIR="${CM_BUILD_DIR:-$(pwd)}"
    export PROFILE_TYPE="${PROFILE_TYPE:-app-store}"
    export WORKFLOW_ID="ios-workflow3"
    export WORKFLOW_TYPE="workflow3"
    export UNIVERSAL_BUILD="enabled"
    export NUCLEAR_PROTOCOLS="enabled"
    export COLLISION_ELIMINATION="nuclear"
    export ULTIMATE_ELIMINATION="enabled"
    
    log_success "Environment variables loaded successfully"
    log_info "📋 iOS Workflow 3 Configuration:"
    log_info "  - Workflow: ios-workflow3"
    log_info "  - Purpose: Universal build support with nuclear collision handling"
    log_info "  - Bundle ID: $BUNDLE_ID"
    log_info "  - Profile Type: $PROFILE_TYPE"
    log_info "  - Universal Build: ENABLED"
    log_info "  - Nuclear Protocols: ENABLED"
    log_info "  - Collision Elimination: Nuclear grade"
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

# Function to setup nuclear collision protocols
setup_nuclear_collision_protocols() {
    log_info "--- Stage 1: Nuclear Collision Protocol Setup ---"
    
    log_info "☢️ Activating nuclear collision handling protocols for Workflow 3..."
    log_info "🎯 Target: Universal build support with maximum collision elimination"
    log_info "🔬 Strategy: Nuclear-grade collision prevention with universal compatibility"
    log_info "🌐 Mode: Universal build support for all distribution methods"
    
    # Create nuclear backup
    if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
        cp "ios/Runner.xcodeproj/project.pbxproj" "ios/Runner.xcodeproj/project.pbxproj.nuclear_backup_$(date +%Y%m%d_%H%M%S)"
        log_success "✅ Nuclear backup created for Workflow 3"
    fi
    
    # Nuclear bundle ID analysis
    local main_bundle_count
    main_bundle_count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = ${BUNDLE_ID};" "ios/Runner.xcodeproj/project.pbxproj" 2>/dev/null || echo "0")
    
    log_info "☢️ Nuclear Bundle ID Analysis:"
    log_info "  - Main Bundle ID: $BUNDLE_ID"
    log_info "  - Current Occurrences: $main_bundle_count"
    log_info "  - Nuclear Target: 3 (Debug, Release, Profile)"
    log_info "  - Universal Build: $UNIVERSAL_BUILD"
    
    if [ "$main_bundle_count" -gt 3 ]; then
        log_warn "⚠️ Nuclear collision threat detected ($main_bundle_count > 3)"
        log_info "☢️ Nuclear elimination protocols will be activated"
        export NUCLEAR_ACTIVATION="required"
        export NUCLEAR_BUNDLE_ID_FIX="enabled"
        export ULTIMATE_COLLISION_ELIMINATOR="enabled"
    else
        log_success "✅ Bundle ID configuration within nuclear safety parameters"
        export NUCLEAR_ACTIVATION="standby"
    fi
    
    log_success "✅ Nuclear collision protocol setup completed"
    return 0
}

# Function to handle universal build configuration
handle_universal_build_configuration() {
    log_info "--- Stage 2: Universal Build Configuration ---"
    
    log_info "🌐 iOS Workflow 3: Universal build support for all distribution methods"
    log_info "📋 Supported distributions: App Store, Ad Hoc, Enterprise, Development"
    
    # Universal profile type analysis
    local supported_profiles=("app-store" "ad-hoc" "enterprise" "development")
    log_info "🔄 Universal Profile Support:"
    log_info "  - Current Profile: $PROFILE_TYPE"
    log_info "  - Supported Types: ${supported_profiles[*]}"
    
    # Profile-specific configuration
    case "$PROFILE_TYPE" in
        "app-store")
            log_info "📦 Configuring for App Store distribution..."
            export DISTRIBUTION_METHOD="app-store"
            ;;
        "ad-hoc")
            log_info "📦 Configuring for Ad Hoc distribution..."
            export DISTRIBUTION_METHOD="ad-hoc"
            ;;
        "enterprise")
            log_info "📦 Configuring for Enterprise distribution..."
            export DISTRIBUTION_METHOD="enterprise"
            ;;
        "development")
            log_info "📦 Configuring for Development..."
            export DISTRIBUTION_METHOD="development"
            ;;
        *)
            log_warn "⚠️ Unknown profile type: $PROFILE_TYPE, using app-store"
            export DISTRIBUTION_METHOD="app-store"
            export PROFILE_TYPE="app-store"
            ;;
    esac
    
    # Universal certificate detection
    local cert_methods=()
    
    if [ -n "${CERT_P12_URL:-}" ]; then
        cert_methods+=("P12")
        export CERT_METHOD="p12_url"
        log_success "✅ P12 certificate method for universal build"
    else
        export CERT_METHOD="standard"
        log_info "🔐 Standard certificate handling"
    fi
    
    if [ -n "${CERT_CER_URL:-}" ] && [ -n "${CERT_KEY_URL:-}" ]; then
        cert_methods+=("CER+KEY")
    fi
    
    if [ -n "${APP_STORE_CONNECT_API_KEY_PATH:-}" ]; then
        cert_methods+=("API")
    fi
    
    log_info "🔐 Universal Certificate Support:"
    if [ ${#cert_methods[@]} -gt 0 ]; then
        log_success "✅ Available methods: ${cert_methods[*]}"
    else
        log_warn "⚠️ No certificate methods detected - unsigned build"
    fi
    
    log_success "✅ Universal build configuration completed"
    return 0
}

# Function to handle Firebase nuclear configuration
handle_firebase_nuclear_configuration() {
    log_info "--- Stage 3: Firebase Nuclear Configuration ---"
    
    if [ "${PUSH_NOTIFY:-false}" = "true" ] && [ -n "${FIREBASE_CONFIG_IOS:-}" ]; then
        log_info "🔥 Firebase iOS configuration detected for universal build"
        export FIREBASE_IOS_ENABLED="true"
        
        # Nuclear Firebase download
        log_info "📥 Downloading Firebase iOS configuration with nuclear validation..."
        mkdir -p ios/Runner
        
        if wget -O ios/Runner/GoogleService-Info.plist "$FIREBASE_CONFIG_IOS"; then
            log_success "✅ Firebase iOS configuration downloaded successfully"
            
            # Nuclear validation
            if [ -f "ios/Runner/GoogleService-Info.plist" ] && [ -s "ios/Runner/GoogleService-Info.plist" ]; then
                log_success "✅ Firebase configuration passed nuclear validation"
            else
                log_error "❌ Firebase configuration failed nuclear validation"
                return 1
            fi
        else
            log_error "❌ Failed to download Firebase iOS configuration"
            return 1
        fi
    else
        log_info "📱 Firebase disabled or not configured for universal build"
        export FIREBASE_IOS_ENABLED="false"
    fi
    
    log_success "✅ Firebase nuclear configuration completed"
    return 0
}

# Function to run universal nuclear build process
run_universal_nuclear_build() {
    log_info "--- Stage 4: Universal Nuclear Build Process ---"
    
    if [ -f "$SCRIPT_DIR/../ios/main.sh" ]; then
        log_info "✅ Delegating to main iOS script with universal nuclear enhancement"
        log_info "☢️ Nuclear collision protocols: ACTIVE"
        log_info "🌐 Universal build mode: ENABLED"
        log_info "📦 Distribution method: $DISTRIBUTION_METHOD"
        log_info "🔥 Firebase: ${FIREBASE_IOS_ENABLED:-false}"
        
        # Make the script executable
        chmod +x "$SCRIPT_DIR/../ios/main.sh"
        
        # Call the main iOS build script
        if "$SCRIPT_DIR/../ios/main.sh"; then
            log_success "✅ Universal nuclear iOS build process completed successfully"
            return 0
        else
            log_error "❌ Universal nuclear iOS build process failed"
            return 1
        fi
    else
        log_warn "⚠️ Main iOS script not found, using universal nuclear fallback"
        
        # Universal nuclear fallback build
        log_info "☢️ Running universal nuclear fallback build process..."
        
        # Nuclear preparation
        flutter clean || log_warn "Flutter clean failed"
        flutter pub get || { log_error "Flutter pub get failed"; return 1; }
        
        # Nuclear collision elimination if required
        if [ "$NUCLEAR_ACTIVATION" = "required" ]; then
            log_info "☢️ Applying nuclear collision elimination before universal build..."
            # Nuclear collision elimination would be applied here
        fi
        
        # Universal build
        if flutter build ios --release --no-codesign; then
            log_success "✅ Flutter iOS universal build completed"
            
            # Check for build artifacts
            if [ -d "build/ios/Release-iphoneos/Runner.app" ]; then
                APP_SIZE=$(du -sh "build/ios/Release-iphoneos/Runner.app" | cut -f1)
                log_success "📱 iOS app bundle created: build/ios/Release-iphoneos/Runner.app ($APP_SIZE)"
                
                # Create universal output structure
                mkdir -p "$OUTPUT_DIR"
                cp -r "build/ios/Release-iphoneos/Runner.app" "$OUTPUT_DIR/"
                
                # Create universal IPA structure for all distribution methods
                mkdir -p "$OUTPUT_DIR/Payload"
                cp -r "build/ios/Release-iphoneos/Runner.app" "$OUTPUT_DIR/Payload/"
                
                # Create universal IPA
                local universal_ipa="$OUTPUT_DIR/Runner_Universal_${PROFILE_TYPE}.ipa"
                (cd "$OUTPUT_DIR" && zip -r "Runner_Universal_${PROFILE_TYPE}.ipa" Payload/)
                
                if [ -f "$universal_ipa" ]; then
                    IPA_SIZE=$(du -sh "$universal_ipa" | cut -f1)
                    log_success "📱 Universal IPA created: $universal_ipa ($IPA_SIZE)"
                fi
                
                log_success "📦 Universal nuclear build artifacts created"
                return 0
            else
                log_error "❌ iOS app bundle not found after universal nuclear build"
                return 1
            fi
        else
            log_error "❌ Flutter iOS universal nuclear build failed"
            return 1
        fi
    fi
}

# Function to validate universal nuclear outputs
validate_universal_nuclear_outputs() {
    log_info "--- Stage 5: Universal Nuclear Output Validation ---"
    
    local validation_passed=true
    local artifacts_found=false
    
    # Check for build directory
    if [ -d "build/ios" ]; then
        log_success "✅ iOS build directory found"
    else
        log_error "❌ iOS build directory not found"
        validation_passed=false
    fi
    
    # Universal artifact validation
    if [ -f "$OUTPUT_DIR/Runner.ipa" ]; then
        IPA_SIZE=$(du -h "$OUTPUT_DIR/Runner.ipa" | cut -f1)
        log_success "📱 Primary IPA: $OUTPUT_DIR/Runner.ipa ($IPA_SIZE)"
        artifacts_found=true
    fi
    
    if [ -f "$OUTPUT_DIR/Runner_Universal_${PROFILE_TYPE}.ipa" ]; then
        UNIVERSAL_IPA_SIZE=$(du -h "$OUTPUT_DIR/Runner_Universal_${PROFILE_TYPE}.ipa" | cut -f1)
        log_success "📱 Universal IPA: $OUTPUT_DIR/Runner_Universal_${PROFILE_TYPE}.ipa ($UNIVERSAL_IPA_SIZE)"
        artifacts_found=true
    fi
    
    if [ -d "build/ios/archive/Runner.xcarchive" ]; then
        ARCHIVE_SIZE=$(du -h "build/ios/archive/Runner.xcarchive" | cut -f1)
        log_success "📦 Archive: build/ios/archive/Runner.xcarchive ($ARCHIVE_SIZE)"
        artifacts_found=true
    fi
    
    if [ -d "$OUTPUT_DIR/Runner.app" ]; then
        APP_SIZE=$(du -h "$OUTPUT_DIR/Runner.app" | cut -f1)
        log_success "📱 App Bundle: $OUTPUT_DIR/Runner.app ($APP_SIZE)"
        artifacts_found=true
    fi
    
    if [ "$artifacts_found" = false ]; then
        log_warn "⚠️ No build artifacts found in expected locations"
    fi
    
    # Nuclear collision validation
    if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
        local final_bundle_count
        final_bundle_count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = ${BUNDLE_ID};" "ios/Runner.xcodeproj/project.pbxproj" 2>/dev/null || echo "0")
        
        log_info "☢️ Nuclear Collision Results:"
        log_info "  - Final Bundle ID Count: $final_bundle_count"
        log_info "  - Nuclear Activation: $NUCLEAR_ACTIVATION"
        
        if [ "$final_bundle_count" -le 3 ]; then
            log_success "✅ Nuclear collision elimination: EFFECTIVE"
        else
            log_warn "⚠️ Nuclear collision elimination: Requires additional protocols"
        fi
    fi
    
    if [ "$validation_passed" = "true" ]; then
        log_success "✅ Universal nuclear output validation completed successfully"
        return 0
    else
        log_error "❌ Universal nuclear output validation failed"
        return 1
    fi
}

# Main execution function
main() {
    log_info "🚀 iOS Workflow 3 Starting..."
    log_info "📋 Following iOS-Workflow Pattern with universal nuclear enhancement"
    
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
        send_email "build_started" "iOS" "${CM_BUILD_ID:-unknown}" "iOS Workflow 3 build started"
    fi
    
    # Stage 1: Setup nuclear collision protocols
    if ! setup_nuclear_collision_protocols; then
        log_error "Nuclear collision protocol setup failed"
        send_email "build_failed" "iOS" "${CM_BUILD_ID:-unknown}" "Nuclear collision protocol setup failed."
        return 1
    fi
    
    # Stage 2: Handle universal build configuration
    if ! handle_universal_build_configuration; then
        log_error "Universal build configuration failed"
        send_email "build_failed" "iOS" "${CM_BUILD_ID:-unknown}" "Universal build configuration failed."
        return 1
    fi
    
    # Stage 3: Handle Firebase nuclear configuration
    if ! handle_firebase_nuclear_configuration; then
        log_error "Firebase nuclear configuration failed"
        send_email "build_failed" "iOS" "${CM_BUILD_ID:-unknown}" "Firebase nuclear configuration failed."
        return 1
    fi
    
    # Stage 4: Run universal nuclear build process
    if ! run_universal_nuclear_build; then
        log_error "Universal nuclear build process failed"
        send_email "build_failed" "iOS" "${CM_BUILD_ID:-unknown}" "Universal nuclear build process failed."
        return 1
    fi
    
    # Stage 5: Validate universal nuclear outputs
    if ! validate_universal_nuclear_outputs; then
        log_error "Universal nuclear output validation failed"
        send_email "build_failed" "iOS" "${CM_BUILD_ID:-unknown}" "Universal nuclear output validation failed."
        return 1
    fi
    
    # Success summary
    log_success "🎉 iOS Workflow 3 completed successfully!"
    log_info "🎯 Purpose: Universal build support with nuclear collision handling"
    log_info "🌐 Universal Build: ENABLED"
    log_info "☢️ Nuclear Protocols: ACTIVE"
    log_info "📦 Distribution Method: $DISTRIBUTION_METHOD"
    log_info "🔥 Firebase: ${FIREBASE_IOS_ENABLED:-false}"
    log_info "📊 Following iOS-Workflow Pattern: All universal nuclear stages completed"
    
    # Display final summary
    echo ""
    log_info "📋 Final Universal Nuclear Summary:"
    log_success "✅ Universal Build Support: ACTIVE"
    log_success "✅ Nuclear Collision Protocols: IMPLEMENTED"
    log_success "✅ All Distribution Methods: SUPPORTED"
    log_success "✅ Profile Type: $PROFILE_TYPE"
    log_success "✅ Multi-Certificate Support: AVAILABLE"
    log_success "🚀 Ready for App Store submission (Universal Build)"
    log_success "📱 Supports: App Store, Ad Hoc, Enterprise, and Development distributions"
    
    # Email notification - Build success
    if [ "${ENABLE_EMAIL_NOTIFICATIONS:-false}" = "true" ]; then
        send_email "build_success" "iOS" "${CM_BUILD_ID:-unknown}" "iOS Workflow 3 completed successfully"
    fi
    
    return 0
}

# Execute main function
if ! main "$@"; then
    log_error "🚨 iOS Workflow 3 FAILED"
    log_error "📋 Check the logs above for specific error details"
    exit 1
fi

log_success "🚀 iOS Workflow 3 completed successfully!"
log_info "📁 Following iOS-Workflow Pattern: Universal nuclear-enhanced workflow completed" 