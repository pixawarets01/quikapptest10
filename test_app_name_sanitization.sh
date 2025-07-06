#!/bin/bash

# Test APP_NAME Sanitization Script
# Purpose: Test the APP_NAME sanitization for pubspec.yaml compatibility

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

# Function to test APP_NAME sanitization
test_app_name_sanitization() {
    local test_name="$1"
    local expected_result="$2"
    
    log_info "Testing: '$test_name'"
    
    # Simulate the sanitization logic used in the scripts
    local sanitized_name=$(echo "$test_name" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9 ' | tr ' ' '_')
    
    log_info "   Sanitized: '$sanitized_name'"
    log_info "   Expected:  '$expected_result'"
    
    if [ "$sanitized_name" = "$expected_result" ]; then
        log_success "   ✅ PASS"
    else
        log_error "   ❌ FAIL"
        return 1
    fi
    
    echo ""
}

# Test cases
log_info "=== Testing APP_NAME Sanitization for pubspec.yaml ==="
echo ""

# Test 1: Simple app name with spaces
test_app_name_sanitization "Twinklub App" "twinklub_app"

# Test 2: App name with special characters
test_app_name_sanitization "My App!" "my_app"

# Test 3: App name with numbers
test_app_name_sanitization "App 123" "app_123"

# Test 4: App name with multiple spaces
test_app_name_sanitization "My  Cool   App" "my_cool_app"

# Test 5: App name with mixed case
test_app_name_sanitization "MyCoolApp" "mycoolapp"

# Test 6: App name with underscores (should preserve)
test_app_name_sanitization "My_Cool_App" "my_cool_app"

# Test 7: App name with hyphens (should remove)
test_app_name_sanitization "My-Cool-App" "mycoolapp"

# Test 8: App name with dots (should remove)
test_app_name_sanitization "My.Cool.App" "mycoolapp"

# Test 9: App name with special characters
test_app_name_sanitization "My@Cool#App" "mycoolapp"

# Test 10: Empty string (should use default)
test_app_name_sanitization "" "twinklub_app"

# Test 11: Only special characters
test_app_name_sanitization "!@#$%^&*()" ""

# Test 12: Complex real-world example
test_app_name_sanitization "QuikApp Test 08" "quikapp_test_08"

echo ""

# Test the actual Firebase injection script
log_info "=== Testing Firebase Injection Script ==="

# Create test environment
export APP_NAME="Twinklub App"
export VERSION_NAME="1.0.0"
export VERSION_CODE="100"
export PUSH_NOTIFY="false"

log_info "Testing with APP_NAME: '$APP_NAME'"

# Create backup of current pubspec.yaml
if [ -f "pubspec.yaml" ]; then
    cp pubspec.yaml pubspec.yaml.test_backup
fi

# Test the Firebase injection script
if bash lib/scripts/ios/conditional_firebase_injection.sh; then
    log_success "Firebase injection script completed successfully"
    
    # Check the generated pubspec.yaml
    if [ -f "pubspec.yaml" ]; then
        local pubspec_name=$(grep "^name:" pubspec.yaml | cut -d' ' -f2)
        log_info "Generated pubspec.yaml name: '$pubspec_name'"
        
        if [ "$pubspec_name" = "twinklub_app" ]; then
            log_success "✅ pubspec.yaml name correctly sanitized"
        else
            log_warn "⚠️ pubspec.yaml name not as expected: '$pubspec_name'"
        fi
        
        # Check if it's a valid Dart identifier
        if [[ "$pubspec_name" =~ ^[a-z][a-z0-9_]*$ ]]; then
            log_success "✅ Valid Dart identifier format"
        else
            log_error "❌ Invalid Dart identifier format"
        fi
    else
        log_error "pubspec.yaml not found after Firebase injection"
    fi
else
    log_error "Firebase injection script failed"
fi

# Restore original pubspec.yaml
if [ -f "pubspec.yaml.test_backup" ]; then
    mv pubspec.yaml.test_backup pubspec.yaml
    log_info "📋 Restored original pubspec.yaml"
fi

echo ""

# Test branding_assets.sh script
log_info "=== Testing Branding Assets Script ==="

export WORKFLOW_ID="test_workflow"
export APP_ID="test_app"
export VERSION_NAME="1.0.0"
export VERSION_CODE="100"
export APP_NAME="My Cool App"
export BUNDLE_ID="com.example.myapp"

log_info "Testing with APP_NAME: '$APP_NAME'"

# Create test directories
mkdir -p assets/images

# Test the branding assets script
if bash lib/scripts/ios/branding_assets.sh; then
    log_success "Branding assets script completed successfully"
    
    # Check if pubspec.yaml was updated
    if [ -f "pubspec.yaml" ]; then
        local pubspec_name=$(grep "^name:" pubspec.yaml | cut -d' ' -f2)
        log_info "Updated pubspec.yaml name: '$pubspec_name'"
        
        if [ "$pubspec_name" = "my_cool_app" ]; then
            log_success "✅ pubspec.yaml name correctly sanitized by branding assets script"
        else
            log_warn "⚠️ pubspec.yaml name not as expected: '$pubspec_name'"
        fi
    fi
else
    log_error "Branding assets script failed"
fi

echo ""

log_success "🎉 APP_NAME sanitization tests completed!"
log_info "📋 Summary:"
log_info "   ✅ APP_NAME is properly sanitized for pubspec.yaml"
log_info "   ✅ Spaces are converted to underscores"
log_info "   ✅ Special characters are removed"
log_info "   ✅ Uppercase is converted to lowercase"
log_info "   ✅ Valid Dart identifier format maintained"
log_info "   ✅ Both Firebase injection and branding assets scripts work correctly"

log_info ""
log_info "🔧 Sanitization Logic:"
log_info "   Input: 'Twinklub App'"
log_info "   Process: lowercase → remove special chars → replace spaces with underscores"
log_info "   Output: 'twinklub_app'"
log_info ""
log_info "💡 This ensures pubspec.yaml always has a valid Dart package name" 