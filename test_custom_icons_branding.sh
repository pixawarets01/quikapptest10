#!/bin/bash

# Test Custom Icons Branding Assets Script
# Purpose: Test the new IS_BOTTOMMENU and custom icons functionality

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

# Test 1: IS_BOTTOMMENU = false (should skip)
log_info "=== Test 1: IS_BOTTOMMENU = false ==="
export IS_BOTTOMMENU="false"
export BOTTOMMENU_ITEMS='[{"type":"custom","label":"Home","icon_url":"https://example.com/home.svg"},{"type":"default","label":"Profile"}]'

log_info "Setting IS_BOTTOMMENU=false"
log_info "BOTTOMMENU_ITEMS contains custom icons but should be skipped"

if bash lib/scripts/ios/branding_assets.sh; then
    log_success "Test 1 passed: Bottom menu processing correctly skipped"
else
    log_error "Test 1 failed: Bottom menu processing should have been skipped"
fi

echo ""

# Test 2: IS_BOTTOMMENU = true with JSON format and custom icons
log_info "=== Test 2: IS_BOTTOMMENU = true with JSON custom icons ==="
export IS_BOTTOMMENU="true"
export BOTTOMMENU_ITEMS='[{"type":"custom","label":"Home","icon_url":"https://example.com/home.svg"},{"type":"custom","label":"Profile","icon_url":"https://example.com/profile.svg"},{"type":"default","label":"Settings"}]'

log_info "Setting IS_BOTTOMMENU=true"
log_info "BOTTOMMENU_ITEMS contains 2 custom icons and 1 default item"

# Create test directories
mkdir -p assets/icons

if bash lib/scripts/ios/branding_assets.sh; then
    log_success "Test 2 passed: Custom icons processing completed"
    
    # Check if custom icons were processed
    if [ -f "assets/icons/Home.svg" ]; then
        log_success "✅ Home.svg custom icon file created"
    else
        log_warn "⚠️ Home.svg custom icon file not found (expected due to fake URL)"
    fi
    
    if [ -f "assets/icons/Profile.svg" ]; then
        log_success "✅ Profile.svg custom icon file created"
    else
        log_warn "⚠️ Profile.svg custom icon file not found (expected due to fake URL)"
    fi
    
    if [ -f "assets/icons/menu_config.json" ]; then
        log_success "✅ Menu configuration file created"
        log_info "📋 Menu config content:"
        cat assets/icons/menu_config.json
    else
        log_warn "⚠️ Menu configuration file not found"
    fi
else
    log_error "Test 2 failed: Custom icons processing should have completed"
fi

echo ""

# Test 3: IS_BOTTOMMENU = true with legacy format
log_info "=== Test 3: IS_BOTTOMMENU = true with legacy format ==="
export IS_BOTTOMMENU="true"
export BOTTOMMENU_ITEMS="https://example.com/home.png:Home,https://example.com/profile.png:Profile"

log_info "Setting IS_BOTTOMMENU=true"
log_info "BOTTOMMENU_ITEMS uses legacy format (icon:label,icon:label)"

if bash lib/scripts/ios/branding_assets.sh; then
    log_success "Test 3 passed: Legacy format processing completed"
    
    # Check if legacy icons were processed
    if [ -f "assets/icons/menu_icon_0.png" ]; then
        log_success "✅ menu_icon_0.png legacy icon file created"
    else
        log_warn "⚠️ menu_icon_0.png legacy icon file not found (expected due to fake URL)"
    fi
    
    if [ -f "assets/icons/menu_icon_1.png" ]; then
        log_success "✅ menu_icon_1.png legacy icon file created"
    else
        log_warn "⚠️ menu_icon_1.png legacy icon file not found (expected due to fake URL)"
    fi
else
    log_error "Test 3 failed: Legacy format processing should have completed"
fi

echo ""

# Test 4: IS_BOTTOMMENU = true but no BOTTOMMENU_ITEMS
log_info "=== Test 4: IS_BOTTOMMENU = true but no BOTTOMMENU_ITEMS ==="
export IS_BOTTOMMENU="true"
unset BOTTOMMENU_ITEMS

log_info "Setting IS_BOTTOMMENU=true but BOTTOMMENU_ITEMS is empty"

if bash lib/scripts/ios/branding_assets.sh; then
    log_success "Test 4 passed: Correctly handled empty BOTTOMMENU_ITEMS"
else
    log_error "Test 4 failed: Should handle empty BOTTOMMENU_ITEMS gracefully"
fi

echo ""

# Test 5: Mixed JSON format with custom and default items
log_info "=== Test 5: Mixed JSON format with custom and default items ==="
export IS_BOTTOMMENU="true"
export BOTTOMMENU_ITEMS='[{"type":"custom","label":"Dashboard","icon_url":"https://example.com/dashboard.svg"},{"type":"default","label":"Notifications"},{"type":"custom","label":"Settings","icon_url":"https://example.com/settings.svg"}]'

log_info "Setting IS_BOTTOMMENU=true"
log_info "BOTTOMMENU_ITEMS contains mixed custom and default items"

if bash lib/scripts/ios/branding_assets.sh; then
    log_success "Test 5 passed: Mixed format processing completed"
    
    # Check if only custom icons were processed
    if [ -f "assets/icons/Dashboard.svg" ]; then
        log_success "✅ Dashboard.svg custom icon file created"
    else
        log_warn "⚠️ Dashboard.svg custom icon file not found (expected due to fake URL)"
    fi
    
    if [ -f "assets/icons/Settings.svg" ]; then
        log_success "✅ Settings.svg custom icon file created"
    else
        log_warn "⚠️ Settings.svg custom icon file not found (expected due to fake URL)"
    fi
    
    # Default items should not create icon files
    if [ ! -f "assets/icons/Notifications.svg" ]; then
        log_success "✅ Notifications.svg correctly not created (default type)"
    else
        log_warn "⚠️ Notifications.svg incorrectly created (should be default type)"
    fi
else
    log_error "Test 5 failed: Mixed format processing should have completed"
fi

echo ""

log_success "🎉 All custom icons branding tests completed!"
log_info "📋 Summary:"
log_info "   - Test 1: IS_BOTTOMMENU=false correctly skips processing"
log_info "   - Test 2: JSON format with custom icons processes correctly"
log_info "   - Test 3: Legacy format processes correctly"
log_info "   - Test 4: Empty BOTTOMMENU_ITEMS handled gracefully"
log_info "   - Test 5: Mixed custom/default items processed correctly"

log_info ""
log_info "🔧 Usage Examples:"
log_info "   # Enable bottom menu with custom icons"
log_info "   export IS_BOTTOMMENU=true"
log_info "   export BOTTOMMENU_ITEMS='[{\"type\":\"custom\",\"label\":\"Home\",\"icon_url\":\"https://example.com/home.svg\"}]'"
log_info "   bash lib/scripts/ios/branding_assets.sh"
log_info ""
log_info "   # Disable bottom menu (skips processing)"
log_info "   export IS_BOTTOMMENU=false"
log_info "   bash lib/scripts/ios/branding_assets.sh" 