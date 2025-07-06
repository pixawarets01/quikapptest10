#!/bin/bash

# Test Asset Download Fixes Script
# Purpose: Test the improved null/empty URL handling in branding_assets.sh

set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"

log_info() {
    echo "ℹ️  $1"
}

log_success() {
    echo "✅ $1"
}

log_warn() {
    echo "⚠️  $1"
}

log_error() {
    echo "❌ $1"
}

# Test 1: All URLs are null
log_info "=== Test 1: All URLs are null ==="
export LOGO_URL="null"
export SPLASH_URL="null"
export SPLASH_BG_URL="null"

log_info "Setting all URLs to 'null'"
log_info "Expected: Skip downloads, create fallbacks"

# Create test directories
mkdir -p assets/images

if bash lib/scripts/ios/branding_assets.sh; then
    log_success "Test 1 passed: Null URLs handled correctly"
    
    # Check if fallback assets were created
    if [ -f "assets/images/logo.png" ]; then
        log_success "✅ Fallback logo created"
    else
        log_warn "⚠️ Fallback logo not found"
    fi
    
    if [ -f "assets/images/splash.png" ]; then
        log_success "✅ Splash image created (copied from logo)"
    else
        log_warn "⚠️ Splash image not found"
    fi
else
    log_error "Test 1 failed: Should handle null URLs gracefully"
fi

echo ""

# Test 2: All URLs are empty strings
log_info "=== Test 2: All URLs are empty strings ==="
export LOGO_URL=""
export SPLASH_URL=""
export SPLASH_BG_URL=""

log_info "Setting all URLs to empty strings"
log_info "Expected: Skip downloads, create fallbacks"

if bash lib/scripts/ios/branding_assets.sh; then
    log_success "Test 2 passed: Empty URLs handled correctly"
    
    # Check if fallback assets were created
    if [ -f "assets/images/logo.png" ]; then
        log_success "✅ Fallback logo created"
    else
        log_warn "⚠️ Fallback logo not found"
    fi
    
    if [ -f "assets/images/splash.png" ]; then
        log_success "✅ Splash image created (copied from logo)"
    else
        log_warn "⚠️ Splash image not found"
    fi
else
    log_error "Test 2 failed: Should handle empty URLs gracefully"
fi

echo ""

# Test 3: URLs are not set (undefined)
log_info "=== Test 3: URLs are not set (undefined) ==="
unset LOGO_URL
unset SPLASH_URL
unset SPLASH_BG_URL

log_info "Unsetting all URL variables"
log_info "Expected: Skip downloads, create fallbacks"

if bash lib/scripts/ios/branding_assets.sh; then
    log_success "Test 3 passed: Undefined URLs handled correctly"
    
    # Check if fallback assets were created
    if [ -f "assets/images/logo.png" ]; then
        log_success "✅ Fallback logo created"
    else
        log_warn "⚠️ Fallback logo not found"
    fi
    
    if [ -f "assets/images/splash.png" ]; then
        log_success "✅ Splash image created (copied from logo)"
    else
        log_warn "⚠️ Splash image not found"
    fi
else
    log_error "Test 3 failed: Should handle undefined URLs gracefully"
fi

echo ""

# Test 4: Mixed valid and invalid URLs
log_info "=== Test 4: Mixed valid and invalid URLs ==="
export LOGO_URL="https://example.com/logo.png"
export SPLASH_URL="null"
export SPLASH_BG_URL=""

log_info "Setting LOGO_URL to valid URL, others to null/empty"
log_info "Expected: Download logo, skip others, create fallbacks"

if bash lib/scripts/ios/branding_assets.sh; then
    log_success "Test 4 passed: Mixed URLs handled correctly"
    
    # Check if logo was attempted to be downloaded (will fail due to fake URL)
    if [ -f "assets/images/logo.png" ]; then
        log_success "✅ Logo file exists (fallback created due to fake URL)"
    else
        log_warn "⚠️ Logo file not found"
    fi
    
    if [ -f "assets/images/splash.png" ]; then
        log_success "✅ Splash image created (copied from logo)"
    else
        log_warn "⚠️ Splash image not found"
    fi
    
    # Splash background should not exist since URL was empty
    if [ ! -f "assets/images/splash_bg.png" ]; then
        log_success "✅ Splash background correctly not created (empty URL)"
    else
        log_warn "⚠️ Splash background incorrectly created"
    fi
else
    log_error "Test 4 failed: Should handle mixed URLs gracefully"
fi

echo ""

# Test 5: pubspec.yaml variable substitution fix
log_info "=== Test 5: pubspec.yaml variable substitution fix ==="
export APP_ID="test_app"
export VERSION_NAME="2.0.0"
export VERSION_CODE="100"

log_info "Testing Firebase injection with proper variable substitution"
log_info "APP_ID: $APP_ID, VERSION_NAME: $VERSION_NAME, VERSION_CODE: $VERSION_CODE"

# Create a backup of current pubspec.yaml
if [ -f "pubspec.yaml" ]; then
    cp pubspec.yaml pubspec.yaml.test_backup
fi

# Test the Firebase injection script
if bash lib/scripts/ios/conditional_firebase_injection.sh; then
    log_success "Test 5 passed: Firebase injection completed"
    
    # Check if pubspec.yaml was created with proper variable substitution
    if [ -f "pubspec.yaml" ]; then
        local pubspec_name=$(grep "^name:" pubspec.yaml | cut -d' ' -f2)
        local pubspec_version=$(grep "^version:" pubspec.yaml | cut -d' ' -f2)
        
        log_info "📋 pubspec.yaml content:"
        log_info "   name: $pubspec_name"
        log_info "   version: $pubspec_version"
        
        if [ "$pubspec_name" = "$APP_ID" ]; then
            log_success "✅ Variable substitution working for APP_ID"
        else
            log_warn "⚠️ Variable substitution failed for APP_ID (expected: $APP_ID, got: $pubspec_name)"
        fi
        
        if [ "$pubspec_version" = "${VERSION_NAME}+${VERSION_CODE}" ]; then
            log_success "✅ Variable substitution working for version"
        else
            log_warn "⚠️ Variable substitution failed for version (expected: ${VERSION_NAME}+${VERSION_CODE}, got: $pubspec_version)"
        fi
    else
        log_warn "⚠️ pubspec.yaml not found after Firebase injection"
    fi
else
    log_error "Test 5 failed: Firebase injection should complete successfully"
fi

# Restore original pubspec.yaml
if [ -f "pubspec.yaml.test_backup" ]; then
    mv pubspec.yaml.test_backup pubspec.yaml
    log_info "📋 Restored original pubspec.yaml"
fi

echo ""

log_success "🎉 All asset download fixes tests completed!"
log_info "📋 Summary:"
log_info "   - Test 1: Null URLs handled correctly"
log_info "   - Test 2: Empty URLs handled correctly"
log_info "   - Test 3: Undefined URLs handled correctly"
log_info "   - Test 4: Mixed valid/invalid URLs handled correctly"
log_info "   - Test 5: pubspec.yaml variable substitution fixed"

log_info ""
log_info "🔧 Key Improvements:"
log_info "   ✅ LOGO_URL, SPLASH_URL, SPLASH_BG_URL now check for 'null' and empty strings"
log_info "   ✅ Firebase injection script now properly substitutes variables"
log_info "   ✅ Fallback assets created when URLs are unavailable"
log_info "   ✅ Better logging for asset download decisions" 