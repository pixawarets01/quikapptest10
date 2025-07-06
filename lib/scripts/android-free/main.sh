#!/bin/bash

# Main Android Free Build Orchestration Script
# Purpose: Orchestrate the entire Android Free build workflow
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

log_info "Starting Android Free Build Workflow..."
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
    
    # Set default values for Android Free tier
    export OUTPUT_DIR="${OUTPUT_DIR:-output/android}"
    export PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
    export CM_BUILD_DIR="${CM_BUILD_DIR:-$(pwd)}"
    export PKG_NAME="${PKG_NAME:-com.example.app}"
    export BUILD_TYPE="free"
    export FIREBASE_ENABLED="false"
    export PUSH_NOTIFY="false"
    export IS_DOMAIN_URL="false"
    
    log_success "Environment variables loaded successfully"
    log_info "📋 Android Free Configuration:"
    log_info "  - Build Type: Free Tier"
    log_info "  - Package: $PKG_NAME"
    log_info "  - Firebase: DISABLED"
    log_info "  - Push Notifications: DISABLED"
    log_info "  - Output: $OUTPUT_DIR"
    
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

# Function to configure Android for free tier
configure_android_free() {
    log_info "--- Stage 3: Android Free Tier Configuration ---"
    
    # Ensure no Firebase configuration for free tier
    log_info "🔥 Ensuring no Firebase configuration (Free Tier)"
    
    # Remove any existing Firebase configuration
    if [ -f "android/app/google-services.json" ]; then
        log_info "🗑️ Removing existing Firebase configuration for free tier"
        rm -f "android/app/google-services.json"
    fi
    
    # Verify package name configuration
    if [ -n "${PKG_NAME:-}" ]; then
        log_info "📦 Package Name: $PKG_NAME"
    fi
    
    log_success "✅ Android Free Tier configuration completed"
    return 0
}

# Function to build Android APK
build_android_apk() {
    log_info "--- Stage 4: Building Android APK (Free Tier) ---"
    
    log_info "📱 Building Flutter Android APK for Free Tier..."
    log_info "🎯 Build configuration: Release mode, no Firebase, no paid features"
    
    # Build APK with free tier configuration
    if flutter build apk --release \
        --dart-define=PUSH_NOTIFY=false \
        --dart-define=IS_DOMAIN_URL=false \
        --dart-define=BUILD_TYPE=free; then
        
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
    log_info "--- Stage 5: Build Output Validation ---"
    
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
    log_info "🚀 Android Free Build Workflow Starting..."
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
        send_email "build_started" "Android" "${CM_BUILD_ID:-unknown}" "Android Free build started"
    fi
    
    # Stage 3: Configure Android for free tier
    if ! configure_android_free; then
        log_error "Android Free tier configuration failed"
        send_email "build_failed" "Android" "${CM_BUILD_ID:-unknown}" "Android Free tier configuration failed."
        return 1
    fi
    
    # Stage 4: Build Android APK
    if ! build_android_apk; then
        log_error "Android APK build failed"
        send_email "build_failed" "Android" "${CM_BUILD_ID:-unknown}" "Android APK build failed."
        return 1
    fi
    
    # Stage 5: Validate build outputs
    if ! validate_build_outputs; then
        log_error "Build output validation failed"
        send_email "build_failed" "Android" "${CM_BUILD_ID:-unknown}" "Build output validation failed."
        return 1
    fi
    
    # Success summary
    log_success "🎉 Android Free Build Workflow completed successfully!"
    log_info "📦 Build Type: Free Tier"
    log_info "📱 Features: Basic app functionality without premium features"
    log_info "📊 Following iOS-Workflow Pattern: All stages completed"
    
    # Display final summary
    echo ""
    log_info "📋 Final Build Summary:"
    if [ -f "$OUTPUT_DIR/app-release.apk" ]; then
        APK_SIZE=$(du -h "$OUTPUT_DIR/app-release.apk" | cut -f1)
        log_success "✅ APK: $OUTPUT_DIR/app-release.apk ($APK_SIZE)"
        log_success "🎯 Build Type: Free Tier"
        log_success "📦 Ready for distribution"
    fi
    
    # Email notification - Build success
    if [ "${ENABLE_EMAIL_NOTIFICATIONS:-false}" = "true" ]; then
        send_email "build_success" "Android" "${CM_BUILD_ID:-unknown}" "Android Free build completed successfully"
    fi
    
    return 0
}

# Execute main function
if ! main "$@"; then
    log_error "🚨 Android Free Build Workflow FAILED"
    log_error "📋 Check the logs above for specific error details"
    exit 1
fi

log_success "🚀 Android Free Build Workflow completed successfully!"
log_info "📁 Following iOS-Workflow Pattern: Comprehensive build process completed" 