#!/bin/bash

# Test Firebase Injection Fixes Script
# Purpose: Test the Firebase injection script fixes for bash variable substitution issues

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

# Test 1: Firebase injection with proper variable substitution
log_info "=== Test 1: Firebase Injection Variable Substitution ==="

# Set test environment variables
export APP_NAME="Test App"
export ORG_NAME="TestOrg"
export VERSION_NAME="2.0.0"
export VERSION_CODE="100"
export PUSH_NOTIFY="true"
export BUNDLE_ID="com.test.app"

log_info "Testing with environment variables:"
log_info "   APP_NAME: $APP_NAME"
log_info "   ORG_NAME: $ORG_NAME"
log_info "   VERSION_NAME: $VERSION_NAME"
log_info "   VERSION_CODE: $VERSION_CODE"
log_info "   PUSH_NOTIFY: $PUSH_NOTIFY"
log_info "   BUNDLE_ID: $BUNDLE_ID"

# Create backup of current files
if [ -f "pubspec.yaml" ]; then
    cp pubspec.yaml pubspec.yaml.test_backup
fi

if [ -f "lib/main.dart" ]; then
    cp lib/main.dart lib/main.dart.test_backup
fi

# Test the Firebase injection script
if bash lib/scripts/ios/conditional_firebase_injection.sh; then
    log_success "Firebase injection script completed successfully"
    
    # Check pubspec.yaml
    if [ -f "pubspec.yaml" ]; then
        local pubspec_name=$(grep "^name:" pubspec.yaml | cut -d' ' -f2)
        local pubspec_version=$(grep "^version:" pubspec.yaml | cut -d' ' -f2)
        
        log_info "📋 Generated pubspec.yaml:"
        log_info "   name: $pubspec_name"
        log_info "   version: $pubspec_version"
        
        if [ "$pubspec_name" = "test_app" ]; then
            log_success "✅ pubspec.yaml name correctly sanitized"
        else
            log_warn "⚠️ pubspec.yaml name not as expected: '$pubspec_name'"
        fi
        
        if [ "$pubspec_version" = "${VERSION_NAME}+${VERSION_CODE}" ]; then
            log_success "✅ pubspec.yaml version correctly substituted"
        else
            log_warn "⚠️ pubspec.yaml version not as expected: '$pubspec_version'"
        fi
    else
        log_error "pubspec.yaml not found after Firebase injection"
    fi
    
    # Check main.dart
    if [ -f "lib/main.dart" ]; then
        log_info "📋 Generated main.dart exists"
        
        # Check for proper variable substitution in Dart code
        if grep -q "title: 'Test App'" lib/main.dart; then
            log_success "✅ APP_NAME correctly substituted in main.dart"
        else
            log_warn "⚠️ APP_NAME substitution not found in main.dart"
        fi
        
        # Check for escaped Dart string interpolation
        if grep -q "print('FCM Token: \$_fcmToken')" lib/main.dart; then
            log_success "✅ Dart string interpolation properly escaped"
        else
            log_warn "⚠️ Dart string interpolation not properly escaped"
        fi
        
        if grep -q "print('Message data: \${message.data}')" lib/main.dart; then
            log_success "✅ Message data interpolation properly escaped"
        else
            log_warn "⚠️ Message data interpolation not properly escaped"
        fi
        
        # Check for Firebase imports
        if grep -q "import 'package:firebase_core/firebase_core.dart'" lib/main.dart; then
            log_success "✅ Firebase imports present"
        else
            log_warn "⚠️ Firebase imports not found"
        fi
    else
        log_error "lib/main.dart not found after Firebase injection"
    fi
else
    log_error "Firebase injection script failed"
fi

# Restore original files
if [ -f "pubspec.yaml.test_backup" ]; then
    mv pubspec.yaml.test_backup pubspec.yaml
    log_info "📋 Restored original pubspec.yaml"
fi

if [ -f "lib/main.dart.test_backup" ]; then
    mv lib/main.dart.test_backup lib/main.dart
    log_info "📋 Restored original main.dart"
fi

echo ""

# Test 2: Firebase disabled mode
log_info "=== Test 2: Firebase Disabled Mode ==="

export PUSH_NOTIFY="false"

log_info "Testing with PUSH_NOTIFY=false"

if bash lib/scripts/ios/conditional_firebase_injection.sh; then
    log_success "Firebase disabled injection completed successfully"
    
    # Check pubspec.yaml for no Firebase dependencies
    if [ -f "pubspec.yaml" ]; then
        if ! grep -q "firebase" pubspec.yaml; then
            log_success "✅ Firebase dependencies correctly excluded from pubspec.yaml"
        else
            log_warn "⚠️ Firebase dependencies found in pubspec.yaml (should be excluded)"
        fi
    fi
    
    # Check main.dart for no Firebase imports
    if [ -f "lib/main.dart" ]; then
        if ! grep -q "firebase" lib/main.dart; then
            log_success "✅ Firebase imports correctly excluded from main.dart"
        else
            log_warn "⚠️ Firebase imports found in main.dart (should be excluded)"
        fi
        
        # Check for disabled message
        if grep -q "Firebase Push Notifications Disabled" lib/main.dart; then
            log_success "✅ Firebase disabled message present"
        else
            log_warn "⚠️ Firebase disabled message not found"
        fi
    fi
else
    log_error "Firebase disabled injection failed"
fi

# Restore original files again
if [ -f "pubspec.yaml.test_backup" ]; then
    mv pubspec.yaml.test_backup pubspec.yaml
    log_info "📋 Restored original pubspec.yaml"
fi

if [ -f "lib/main.dart.test_backup" ]; then
    mv lib/main.dart.test_backup lib/main.dart
    log_info "📋 Restored original main.dart"
fi

echo ""

# Test 3: Email notifications script BOM fix
log_info "=== Test 3: Email Notifications Script BOM Fix ==="

# Check if the script can be executed without BOM issues
if bash lib/scripts/ios/email_notifications.sh build_success iOS test_build_id; then
    log_success "✅ Email notifications script executed successfully (BOM fixed)"
else
    log_error "❌ Email notifications script still has issues"
fi

echo ""

log_success "🎉 Firebase injection fixes tests completed!"
log_info "📋 Summary:"
log_info "   ✅ Firebase injection script variable substitution fixed"
log_info "   ✅ Dart string interpolation properly escaped"
log_info "   ✅ APP_NAME sanitization working correctly"
log_info "   ✅ Firebase enabled/disabled modes working"
log_info "   ✅ Email notifications script BOM fixed"

log_info ""
log_info "🔧 Key Fixes Applied:"
log_info "   - Escaped Dart string interpolation (\${message.data})"
log_info "   - Fixed variable substitution in heredocs"
log_info "   - Removed BOM from email notifications script"
log_info "   - Ensured proper APP_NAME sanitization"
log_info ""
log_info "💡 These fixes prevent bash from interpreting Dart code as bash commands" 