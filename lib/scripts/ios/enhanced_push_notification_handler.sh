#!/bin/bash

# Enhanced Push Notification Handler for iOS
# Purpose: Handle PUSH_NOTIFY=true/false scenarios with comprehensive Firebase setup/disable

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

log_info "🔔 Starting Enhanced Push Notification Handler..."

# Function to validate PUSH_NOTIFY flag
validate_push_notify_flag() {
    log_info "🔍 Validating PUSH_NOTIFY configuration..."
    
    # Normalize the flag
    case "${PUSH_NOTIFY:-false}" in
        "true"|"TRUE"|"True"|"1"|"yes"|"YES"|"Yes")
            export PUSH_NOTIFY="true"
            export FIREBASE_ENABLED="true"
            export PUSH_NOTIFICATIONS_ENABLED="true"
            log_info "🔔 Push notifications ENABLED - Firebase will be fully configured"
            ;;
        "false"|"FALSE"|"False"|"0"|"no"|"NO"|"No"|"")
            export PUSH_NOTIFY="false"
            export FIREBASE_ENABLED="false"
            export PUSH_NOTIFICATIONS_ENABLED="false"
            log_info "🔕 Push notifications DISABLED - Firebase will be completely excluded"
            ;;
        *)
            log_warn "⚠️ Invalid PUSH_NOTIFY value: ${PUSH_NOTIFY}. Defaulting to false"
            export PUSH_NOTIFY="false"
            export FIREBASE_ENABLED="false"
            export PUSH_NOTIFICATIONS_ENABLED="false"
            ;;
    esac
    
    log_success "✅ PUSH_NOTIFY flag validated: $PUSH_NOTIFY"
    log_info "📊 Configuration Summary:"
    log_info "   - Firebase Enabled: $FIREBASE_ENABLED"
    log_info "   - Push Notifications: $PUSH_NOTIFICATIONS_ENABLED"
    return 0
}

# Function to handle iOS Info.plist push notification permissions
handle_ios_push_notification_permissions() {
    local plist_file="ios/Runner/Info.plist"
    
    if [ "$PUSH_NOTIFICATIONS_ENABLED" = "true" ]; then
        log_info "🔔 Adding push notification permissions to iOS Info.plist..."
        
        # Add background modes for push notifications
        plutil -insert "UIBackgroundModes" -array "$plist_file" 2>/dev/null || true
        plutil -insert "UIBackgroundModes.0" -string "remote-notification" "$plist_file" 2>/dev/null || true
        
        # Add notification usage description
        plutil -insert "NSUserNotificationUsageDescription" -string "This app uses notifications to keep you updated with important information." "$plist_file" 2>/dev/null || \
        plutil -replace "NSUserNotificationUsageDescription" -string "This app uses notifications to keep you updated with important information." "$plist_file" 2>/dev/null || true
        
        log_success "✅ Push notification permissions added to iOS Info.plist"
    else
        log_info "🔕 Removing push notification permissions from iOS Info.plist..."
        
        # Remove background modes for push notifications
        plutil -remove "UIBackgroundModes" "$plist_file" 2>/dev/null || true
        
        # Remove notification usage description
        plutil -remove "NSUserNotificationUsageDescription" "$plist_file" 2>/dev/null || true
        
        log_success "✅ Push notification permissions removed from iOS Info.plist"
    fi
}

# Function to clean up Firebase-related files when disabled
cleanup_firebase_files() {
    log_info "🧹 Cleaning up Firebase-related files..."
    
    # Remove Firebase-related directories and files
    local firebase_files=(
        "ios/Pods/Firebase"
        "ios/Pods/FirebaseCore"
        "ios/Pods/FirebaseMessaging"
        "ios/Pods/FirebaseAnalytics"
        "ios/Pods/GoogleUtilities"
        "ios/Pods/GTMSessionFetcher"
        "ios/Pods/nanopb"
        "ios/Pods/Protobuf"
    )
    
    for file in "${firebase_files[@]}"; do
        if [ -e "$file" ]; then
            rm -rf "$file"
            log_info "🗑️ Removed: $file"
        fi
    done
    
    # Clean up Pods directory if it exists
    if [ -d "ios/Pods" ]; then
        log_info "🧹 Cleaning up Pods directory..."
        find ios/Pods -name "*Firebase*" -type d -exec rm -rf {} + 2>/dev/null || true
        find ios/Pods -name "*GoogleUtilities*" -type d -exec rm -rf {} + 2>/dev/null || true
    fi
    
    log_success "✅ Firebase cleanup completed"
}

# Function to run conditional Firebase injection
run_conditional_firebase_injection() {
    log_info "🔥 Running conditional Firebase injection..."
    
    if [ -f "${SCRIPT_DIR}/conditional_firebase_injection.sh" ]; then
        chmod +x "${SCRIPT_DIR}/conditional_firebase_injection.sh"
        
        if "${SCRIPT_DIR}/conditional_firebase_injection.sh"; then
            log_success "✅ Conditional Firebase injection completed"
            return 0
        else
            log_error "❌ Conditional Firebase injection failed"
            return 1
        fi
    else
        log_warn "⚠️ Conditional Firebase injection script not found"
        return 1
    fi
}

# Function to run Firebase setup (only if enabled)
run_firebase_setup() {
    if [ "$FIREBASE_ENABLED" = "true" ]; then
        log_info "🔥 Running Firebase setup..."
        
        if [ -f "${SCRIPT_DIR}/firebase_setup.sh" ]; then
            chmod +x "${SCRIPT_DIR}/firebase_setup.sh"
            
            if "${SCRIPT_DIR}/firebase_setup.sh"; then
                log_success "✅ Firebase setup completed"
                return 0
            else
                log_error "❌ Firebase setup failed"
                return 1
            fi
        else
            log_warn "⚠️ Firebase setup script not found"
            return 1
        fi
    else
        log_info "🚫 Firebase setup skipped (PUSH_NOTIFY=false)"
        return 0
    fi
}

# Function to run Firebase Xcode 16.0 fixes (only if enabled)
run_firebase_xcode_fixes() {
    if [ "$FIREBASE_ENABLED" = "true" ]; then
        log_info "🔥 Running Firebase Xcode 16.0 compatibility fixes..."
        
        local firebase_fixes_applied=false
        
        # Primary Firebase Fix: Xcode 16.0 compatibility
        if [ -f "${SCRIPT_DIR}/fix_firebase_xcode16.sh" ]; then
            chmod +x "${SCRIPT_DIR}/fix_firebase_xcode16.sh"
            log_info "🎯 Applying Firebase Xcode 16.0 Compatibility Fix (Primary)..."
            if "${SCRIPT_DIR}/fix_firebase_xcode16.sh"; then
                log_success "✅ Firebase Xcode 16.0 fixes applied successfully"
                firebase_fixes_applied=true
            else
                log_warn "⚠️ Firebase Xcode 16.0 fixes failed, trying source file patches..."
            fi
        fi
        
        # Fallback: Source file patches
        if [ "$firebase_fixes_applied" = "false" ] && [ -f "${SCRIPT_DIR}/fix_firebase_source_files.sh" ]; then
            chmod +x "${SCRIPT_DIR}/fix_firebase_source_files.sh"
            log_info "🎯 Applying Firebase Source File Patches (Fallback)..."
            if "${SCRIPT_DIR}/fix_firebase_source_files.sh"; then
                log_success "✅ Firebase source file patches applied successfully"
                firebase_fixes_applied=true
            else
                log_warn "⚠️ Firebase source file patches failed, trying final solution..."
            fi
        fi
        
        # Ultimate Fix: Final Firebase solution
        if [ "$firebase_fixes_applied" = "false" ] && [ -f "${SCRIPT_DIR}/final_firebase_solution.sh" ]; then
            chmod +x "${SCRIPT_DIR}/final_firebase_solution.sh"
            log_info "🎯 Applying Final Firebase Solution (Ultimate Fix)..."
            if "${SCRIPT_DIR}/final_firebase_solution.sh"; then
                log_success "✅ Final Firebase solution applied successfully"
                firebase_fixes_applied=true
            else
                log_warn "⚠️ Final Firebase solution failed - continuing with standard build"
            fi
        fi
        
        # Report Firebase fix status
        if [ "$firebase_fixes_applied" = "true" ]; then
            log_success "🔥 FIREBASE FIXES: Successfully applied Firebase compilation fixes"
        else
            log_warn "⚠️ FIREBASE FIXES: All Firebase fixes failed - build may have compilation issues"
        fi
    else
        log_info "🚫 Firebase Xcode fixes skipped (PUSH_NOTIFY=false)"
    fi
}

# Function to create comprehensive summary
create_comprehensive_summary() {
    local summary_file="PUSH_NOTIFICATION_SUMMARY.txt"
    
    cat > "$summary_file" << SUMMARY_EOF
=== Enhanced Push Notification Handler Summary ===
Date: $(date)
PUSH_NOTIFY Flag: $PUSH_NOTIFY
Firebase Status: $([ "$FIREBASE_ENABLED" = "true" ] && echo "ENABLED" || echo "DISABLED")
Push Notifications: $([ "$PUSH_NOTIFICATIONS_ENABLED" = "true" ] && echo "ENABLED" || echo "DISABLED")

=== Actions Performed ===
- PUSH_NOTIFY Validation: ✅ Completed
- iOS Info.plist Permissions: $([ "$PUSH_NOTIFICATIONS_ENABLED" = "true" ] && echo "ADDED" || echo "REMOVED")
- Conditional Firebase Injection: $([ "$FIREBASE_ENABLED" = "true" ] && echo "ENABLED" || echo "DISABLED")
- Firebase Setup: $([ "$FIREBASE_ENABLED" = "true" ] && echo "RUN" || echo "SKIPPED")
- Firebase Xcode Fixes: $([ "$FIREBASE_ENABLED" = "true" ] && echo "APPLIED" || echo "SKIPPED")
- Firebase Cleanup: $([ "$FIREBASE_ENABLED" = "false" ] && echo "COMPLETED" || echo "NOT NEEDED")

=== Environment Variables ===
PUSH_NOTIFY: ${PUSH_NOTIFY}
FIREBASE_ENABLED: ${FIREBASE_ENABLED}
PUSH_NOTIFICATIONS_ENABLED: ${PUSH_NOTIFICATIONS_ENABLED}
FIREBASE_CONFIG_IOS: ${FIREBASE_CONFIG_IOS:+SET}
FIREBASE_CONFIG_ANDROID: ${FIREBASE_CONFIG_ANDROID:+SET}

=== Next Steps ===
$([ "$PUSH_NOTIFICATIONS_ENABLED" = "true" ] && echo "- Ensure Firebase configuration files are properly set up" || echo "- Firebase and push notifications are completely disabled")
$([ "$PUSH_NOTIFICATIONS_ENABLED" = "true" ] && echo "- Verify FIREBASE_CONFIG_IOS and FIREBASE_CONFIG_ANDROID URLs" || echo "- No Firebase dependencies will be included in the build")

Enhanced push notification handling completed successfully!
SUMMARY_EOF
    
    log_success "✅ Comprehensive summary created: $summary_file"
}

# Main execution function
main() {
    log_info "🚀 Starting Enhanced Push Notification Handler..."
    
    # Step 1: Validate PUSH_NOTIFY flag
    validate_push_notify_flag
    
    # Step 2: Handle iOS push notification permissions
    handle_ios_push_notification_permissions
    
    # Step 3: Run conditional Firebase injection
    if ! run_conditional_firebase_injection; then
        log_error "❌ Conditional Firebase injection failed"
        return 1
    fi
    
    # Step 4: Run Firebase setup (only if enabled)
    if ! run_firebase_setup; then
        log_error "❌ Firebase setup failed"
        return 1
    fi
    
    # Step 5: Run Firebase Xcode fixes (only if enabled)
    run_firebase_xcode_fixes
    
    # Step 6: Clean up Firebase files (only if disabled)
    if [ "$FIREBASE_ENABLED" = "false" ]; then
        cleanup_firebase_files
    fi
    
    # Step 7: Create comprehensive summary
    create_comprehensive_summary
    
    log_success "✅ Enhanced Push Notification Handler completed successfully!"
    log_info "📋 Final Summary: PUSH_NOTIFY=$PUSH_NOTIFY, Firebase=$([ "$FIREBASE_ENABLED" = "true" ] && echo "ENABLED" || echo "DISABLED"), Push Notifications=$([ "$PUSH_NOTIFICATIONS_ENABLED" = "true" ] && echo "ENABLED" || echo "DISABLED")"
    
    return 0
}

# Execute main function if script is run directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi 