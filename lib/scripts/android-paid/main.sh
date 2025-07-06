#!/bin/bash

# Main Android Paid Build Orchestration Script
# Purpose: Orchestrate the entire Android Paid build workflow
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

log_info "Starting Android Paid Build Workflow..."
log_info "📁 Following iOS-Workflow Pattern: Comprehensive staging and error handling"

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
    
    # Set default values for Android Paid tier
    export OUTPUT_DIR="${OUTPUT_DIR:-output/android}"
    export PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
    export CM_BUILD_DIR="${CM_BUILD_DIR:-$(pwd)}"
    export PKG_NAME="${PKG_NAME:-com.example.app}"
    export BUILD_TYPE="paid"
    export FIREBASE_ENABLED="true"
    export PUSH_NOTIFY="${PUSH_NOTIFY:-true}"
    export IS_DOMAIN_URL="${IS_DOMAIN_URL:-true}"
    
    log_success "Environment variables loaded successfully"
    log_info "📋 Android Paid Configuration:"
    log_info "  - Build Type: Paid Tier"
    log_info "  - Package: $PKG_NAME"
    log_info "  - Firebase: ENABLED"
    log_info "  - Push Notifications: ENABLED"
    log_info "  - Output: $OUTPUT_DIR"
    log_info "  - Firebase Config: ${FIREBASE_CONFIG_ANDROID:-'Not Set'}"
    
    return 0
}

# Function to validate Android project structure
validate_android_project() {
    log_info "--- Android Project Validation ---"
    
    # Check for Android project structure
    if [ ! -f "android/build.gradle" ] && [ ! -f "android/build.gradle.kts" ]; then
        log_error "Android project structure not found (missing build.gradle)"
        return 1
    fi
    
    if [ ! -f "pubspec.yaml" ]; then
        log_error "Flutter project structure not found (missing pubspec.yaml)"
        return 1
    fi
    
    log_success "✅ Android project structure validation completed"
    return 0
}

# Function to setup build environment
setup_build_environment() {
    log_info "--- Stage 1: Build Environment Setup ---"
    
    # Create output directories
    mkdir -p "$OUTPUT_DIR"
    mkdir -p build/app/outputs/logs/
    
    # Clean previous builds
    log_info "🧹 Cleaning previous build artifacts..."
    flutter clean || log_warn "Flutter clean failed"
    
    # Clear Gradle cache for fresh build
    rm -rf ~/.gradle/caches/ 2>/dev/null || true
    rm -rf .dart_tool/ 2>/dev/null || true
    
    log_success "✅ Build environment setup completed"
    return 0
}

# Function to get dependencies
get_flutter_dependencies() {
    log_info "--- Stage 2: Flutter Dependencies ---"
    
    log_info "📦 Getting Flutter dependencies..."
    if flutter pub get; then
        log_success "✅ Flutter dependencies downloaded successfully"
        return 0
    else
        log_error "❌ Failed to get Flutter dependencies"
        return 1
    fi
}

# Function to setup Firebase for paid tier
setup_firebase_configuration() {
    log_info "--- Stage 3: Firebase Configuration (Paid Tier) ---"
    
    if [ "${FIREBASE_ENABLED}" = "true" ] && [ -n "${FIREBASE_CONFIG_ANDROID:-}" ]; then
        log_info "🔥 Setting up Firebase configuration for paid features"
        
        # Create Android app directory if it doesn't exist
        mkdir -p android/app
        
        # Download Firebase configuration
        log_info "📥 Downloading Firebase configuration from: $FIREBASE_CONFIG_ANDROID"
        if wget -O android/app/google-services.json "$FIREBASE_CONFIG_ANDROID"; then
            log_success "✅ Firebase configuration downloaded successfully"
            
            # Validate Firebase configuration
            if [ -f "android/app/google-services.json" ] && [ -s "android/app/google-services.json" ]; then
                log_success "✅ Firebase configuration file validated"
                
                # Extract project info from Firebase config for verification
                if command -v python3 >/dev/null 2>&1; then
                    PROJECT_ID=$(python3 -c "import json; print(json.load(open('android/app/google-services.json'))['project_info']['project_id'])" 2>/dev/null || echo "Unknown")
                    log_info "🔥 Firebase Project ID: $PROJECT_ID"
                fi
            else
                log_error "❌ Downloaded Firebase configuration is invalid or empty"
                return 1
            fi
        else
            log_error "❌ Failed to download Firebase configuration"
            log_error "📋 Check FIREBASE_CONFIG_ANDROID URL: $FIREBASE_CONFIG_ANDROID"
            return 1
        fi
    else
        log_warn "⚠️ Firebase configuration not provided or disabled"
        log_warn "📋 Some paid features may not work without Firebase"
    fi
    
    log_success "✅ Firebase configuration setup completed"
    return 0
}

# Function to configure Android for paid tier
configure_android_paid() {
    log_info "--- Stage 4: Android Paid Tier Configuration ---"
    
    # Verify package name configuration
    if [ -n "${PKG_NAME:-}" ]; then
        log_info "📦 Package Name: $PKG_NAME"
    fi
    
    # Ensure Firebase is properly configured
    if [ -f "android/app/google-services.json" ]; then
        log_success "✅ Firebase configuration present for paid features"
    else
        log_warn "⚠️ Firebase configuration missing - some paid features may not work"
    fi
    
    log_success "✅ Android Paid Tier configuration completed"
    return 0
}

# Function to build Android APK
build_android_apk() {
    log_info "--- Stage 5: Building Android APK (Paid Tier) ---"
    
    log_info "📱 Building Flutter Android APK for Paid Tier..."
    log_info "🎯 Build configuration: Release mode, Firebase enabled, paid features enabled"
    
    # Build APK with paid tier configuration
    if flutter build apk --release \
        --dart-define=PUSH_NOTIFY=true \
        --dart-define=IS_DOMAIN_URL=true \
        --dart-define=BUILD_TYPE=paid \
        --dart-define=FIREBASE_ENABLED=true; then
        
        log_success "✅ Android APK build completed successfully"
        
        # Verify APK was created
        if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
            APK_SIZE=$(du -h "build/app/outputs/flutter-apk/app-release.apk" | cut -f1)
            log_success "📱 APK created: build/app/outputs/flutter-apk/app-release.apk ($APK_SIZE)"
            
            # Copy to output directory
            cp "build/app/outputs/flutter-apk/app-release.apk" "$OUTPUT_DIR/app-release.apk"
            log_success "📦 APK copied to: $OUTPUT_DIR/app-release.apk"
            
            return 0
        else
            log_error "❌ APK file not found after build"
            return 1
        fi
    else
        log_error "❌ Flutter Android APK build failed"
        return 1
    fi
}

# Function to validate build outputs
validate_build_outputs() {
    log_info "--- Stage 6: Build Output Validation ---"
    
    local validation_passed=true
    
    # Check for APK file
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        log_success "✅ Primary APK: build/app/outputs/flutter-apk/app-release.apk"
    else
        log_error "❌ Primary APK not found"
        validation_passed=false
    fi
    
    # Check for copied APK
    if [ -f "$OUTPUT_DIR/app-release.apk" ]; then
        log_success "✅ Output APK: $OUTPUT_DIR/app-release.apk"
    else
        log_error "❌ Output APK not found"
        validation_passed=false
    fi
    
    # Check for Firebase configuration
    if [ -f "android/app/google-services.json" ]; then
        log_success "✅ Firebase configuration: android/app/google-services.json"
    else
        log_warn "⚠️ Firebase configuration missing - paid features may not work"
    fi
    
    if [ "$validation_passed" = "true" ]; then
        log_success "✅ Build output validation completed successfully"
        return 0
    else
        log_error "❌ Build output validation failed"
        return 1
    fi
}

# Main execution function
main() {
    log_info "🚀 Android Paid Build Workflow Starting..."
    log_info "📋 Following iOS-Workflow Pattern with comprehensive error handling"
    
    # Load environment variables
    if ! load_environment_variables; then
        log_error "Environment variable loading failed"
        send_email "build_failed" "Android" "${CM_BUILD_ID:-unknown}" "Environment variable loading failed."
        return 1
    fi
    
    # Validate Android project structure
    if ! validate_android_project; then
        log_error "Android project validation failed"
        send_email "build_failed" "Android" "${CM_BUILD_ID:-unknown}" "Android project validation failed."
        return 1
    fi
    
    # Stage 1: Setup build environment
    if ! setup_build_environment; then
        log_error "Build environment setup failed"
        send_email "build_failed" "Android" "${CM_BUILD_ID:-unknown}" "Build environment setup failed."
        return 1
    fi
    
    # Stage 2: Get Flutter dependencies
    if ! get_flutter_dependencies; then
        log_error "Flutter dependencies failed"
        send_email "build_failed" "Android" "${CM_BUILD_ID:-unknown}" "Flutter dependencies download failed."
        return 1
    fi
    
    # Email notification - Build started (if enabled)
    if [ "${ENABLE_EMAIL_NOTIFICATIONS:-false}" = "true" ]; then
        send_email "build_started" "Android" "${CM_BUILD_ID:-unknown}" "Android Paid build started"
    fi
    
    # Stage 3: Setup Firebase configuration
    if ! setup_firebase_configuration; then
        log_error "Firebase configuration setup failed"
        send_email "build_failed" "Android" "${CM_BUILD_ID:-unknown}" "Firebase configuration setup failed."
        return 1
    fi
    
    # Stage 4: Configure Android for paid tier
    if ! configure_android_paid; then
        log_error "Android Paid tier configuration failed"
        send_email "build_failed" "Android" "${CM_BUILD_ID:-unknown}" "Android Paid tier configuration failed."
        return 1
    fi
    
    # Stage 5: Build Android APK
    if ! build_android_apk; then
        log_error "Android APK build failed"
        send_email "build_failed" "Android" "${CM_BUILD_ID:-unknown}" "Android APK build failed."
        return 1
    fi
    
    # Stage 6: Validate build outputs
    if ! validate_build_outputs; then
        log_error "Build output validation failed"
        send_email "build_failed" "Android" "${CM_BUILD_ID:-unknown}" "Build output validation failed."
        return 1
    fi
    
    # Success summary
    log_success "🎉 Android Paid Build Workflow completed successfully!"
    log_info "📦 Build Type: Paid Tier"
    log_info "🔥 Firebase: $([ "${PUSH_NOTIFY:-false}" = "true" ] && echo "ENABLED" || echo "DISABLED")"
    log_info "📱 Features: Premium app functionality with advanced features"
    log_info "📊 Following iOS-Workflow Pattern: All stages completed"
    
    # Display final summary
    echo ""
    log_info "📋 Final Build Summary:"
    if [ -f "$OUTPUT_DIR/app-release.apk" ]; then
        APK_SIZE=$(du -h "$OUTPUT_DIR/app-release.apk" | cut -f1)
        log_success "✅ APK: $OUTPUT_DIR/app-release.apk ($APK_SIZE)"
        log_success "🎯 Build Type: Paid Tier"
        log_success "🔥 Firebase: ENABLED"
        log_success "📦 Ready for distribution"
    fi
    
    # Email notification - Build success
    if [ "${ENABLE_EMAIL_NOTIFICATIONS:-false}" = "true" ]; then
        send_email "build_success" "Android" "${CM_BUILD_ID:-unknown}" "Android Paid build completed successfully"
    fi
    
    return 0
}

# Execute main function
if ! main "$@"; then
    log_error "🚨 Android Paid Build Workflow FAILED"
    log_error "📋 Check the logs above for specific error details"
    exit 1
fi

log_success "🚀 Android Paid Build Workflow completed successfully!"
log_info "📁 Following iOS-Workflow Pattern: Comprehensive build process completed" 