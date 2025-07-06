#!/bin/bash

# iOS Export Validation System
# Purpose: Comprehensive validation of iOS export configuration
# Based on: iOS app IPA export documentation and App Store requirements

set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

log_info "🔍 Starting iOS Export Validation System..."

# Validation results tracking
VALIDATION_PASSED=0
VALIDATION_FAILED=0
WARNINGS=0

# Function to record validation result
record_validation() {
    local result="$1"
    local message="$2"
    
    case "$result" in
        "pass")
            VALIDATION_PASSED=$((VALIDATION_PASSED + 1))
            log_success "✅ PASS: $message"
            ;;
        "fail")
            VALIDATION_FAILED=$((VALIDATION_FAILED + 1))
            log_error "❌ FAIL: $message"
            ;;
        "warn")
            WARNINGS=$((WARNINGS + 1))
            log_warn "⚠️ WARN: $message"
            ;;
    esac
}

# Validation 1: Certificate Configuration
validate_certificate_configuration() {
    log_info "--- Certificate Configuration Validation ---"
    
    # Check for at least one certificate method
    local cert_methods=0
    
    if [ -n "${CERT_P12_URL:-}" ] && [ -n "${CERT_PASSWORD:-}" ]; then
        record_validation "pass" "P12 certificate method configured"
        cert_methods=$((cert_methods + 1))
    fi
    
    if [ -n "${CERT_CER_URL:-}" ] && [ -n "${CERT_KEY_URL:-}" ]; then
        record_validation "pass" "CER+KEY certificate method configured"
        cert_methods=$((cert_methods + 1))
    fi
    
    if [ -n "${APP_STORE_CONNECT_API_KEY_PATH:-}" ] && [ -n "${APP_STORE_CONNECT_KEY_IDENTIFIER:-}" ] && [ -n "${APP_STORE_CONNECT_ISSUER_ID:-}" ]; then
        record_validation "pass" "App Store Connect API configured"
        cert_methods=$((cert_methods + 1))
    fi
    
    if [ "$cert_methods" -eq 0 ]; then
        record_validation "fail" "No certificate methods configured"
    elif [ "$cert_methods" -eq 1 ]; then
        record_validation "warn" "Only one certificate method (recommend redundancy)"
    else
        record_validation "pass" "Multiple certificate methods available ($cert_methods)"
    fi
    
    # Validate Apple Team ID
    if [ -n "${APPLE_TEAM_ID:-}" ]; then
        if [[ "${APPLE_TEAM_ID}" =~ ^[A-Z0-9]{10}$ ]]; then
            record_validation "pass" "Apple Team ID format valid"
        else
            record_validation "warn" "Apple Team ID format unusual: ${APPLE_TEAM_ID}"
        fi
    else
        record_validation "fail" "Apple Team ID not set"
    fi
    
    return 0
}

# Validation 2: Provisioning Profile Configuration
validate_provisioning_profile() {
    log_info "--- Provisioning Profile Validation ---"
    
    if [ -z "${PROFILE_URL:-}" ]; then
        record_validation "fail" "Provisioning profile URL not set"
        return 1
    fi
    
    # Test profile accessibility
    if curl -fsSL --head --connect-timeout 10 "${PROFILE_URL}" >/dev/null 2>&1; then
        record_validation "pass" "Provisioning profile URL accessible"
        
        # Test UUID extraction
        local temp_profile="/tmp/validation_profile.mobileprovision"
        if curl -fsSL -o "$temp_profile" "${PROFILE_URL}" 2>/dev/null; then
            local uuid
            uuid=$(security cms -D -i "$temp_profile" 2>/dev/null | plutil -extract UUID xml1 -o - - 2>/dev/null | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p' | head -1)
            
            if [ -n "$uuid" ] && [[ "$uuid" =~ ^[A-Fa-f0-9]{8}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{12}$ ]]; then
                record_validation "pass" "UUID extraction successful: $uuid"
            else
                record_validation "fail" "UUID extraction failed or invalid format"
            fi
            
            rm -f "$temp_profile"
        else
            record_validation "fail" "Provisioning profile download failed"
        fi
    else
        record_validation "fail" "Provisioning profile URL not accessible"
    fi
    
    return 0
}

# Validation 3: Bundle ID Configuration
validate_bundle_id_configuration() {
    log_info "--- Bundle ID Configuration Validation ---"
    
    if [ -z "${BUNDLE_ID:-}" ]; then
        record_validation "fail" "Bundle ID not set"
        return 1
    fi
    
    local bundle_id="${BUNDLE_ID}"
    
    # Validate format against iOS requirements
    if [[ "$bundle_id" =~ ^[a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?)*$ ]]; then
        record_validation "pass" "Bundle ID format compliant with iOS guidelines"
    else
        record_validation "fail" "Bundle ID format violates iOS guidelines"
    fi
    
    # Check length
    if [ ${#bundle_id} -le 255 ]; then
        record_validation "pass" "Bundle ID length within limits (${#bundle_id}/255)"
    else
        record_validation "fail" "Bundle ID too long (${#bundle_id}/255)"
    fi
    
    # Check for collision-prone patterns
    if [[ "$bundle_id" =~ \_ ]]; then
        record_validation "warn" "Bundle ID contains underscores (may cause issues)"
    fi
    
    if [[ "$bundle_id" =~ ^com\.example\. ]]; then
        record_validation "warn" "Bundle ID uses example domain (should be updated)"
    fi
    
    return 0
}

# Validation 4: Export Method Configuration
validate_export_method_configuration() {
    log_info "--- Export Method Configuration Validation ---"
    
    local profile_type="${PROFILE_TYPE:-app-store}"
    
    # Validate profile type
    case "$profile_type" in
        "app-store")
            record_validation "pass" "App Store export method selected"
            ;;
        "ad-hoc")
            record_validation "pass" "Ad-hoc export method selected"
            ;;
        "enterprise")
            record_validation "pass" "Enterprise export method selected"
            ;;
        "development")
            record_validation "pass" "Development export method selected"
            ;;
        *)
            record_validation "warn" "Non-standard profile type: $profile_type"
            ;;
    esac
    
    # Check for export options scripts availability
    local export_scripts=(
        "export_ipa_framework_fix.sh"
        "ipa_export_with_certificate_validation.sh"
        "enhanced_certificate_setup.sh"
    )
    
    local available_scripts=0
    for script in "${export_scripts[@]}"; do
        if [ -f "${SCRIPT_DIR}/$script" ]; then
            available_scripts=$((available_scripts + 1))
        fi
    done
    
    if [ "$available_scripts" -ge 2 ]; then
        record_validation "pass" "Multiple export scripts available ($available_scripts/${#export_scripts[@]})"
    elif [ "$available_scripts" -eq 1 ]; then
        record_validation "warn" "Limited export script options"
    else
        record_validation "fail" "No enhanced export scripts available"
    fi
    
    return 0
}

# Validation 5: Framework Embedding Configuration
validate_framework_embedding() {
    log_info "--- Framework Embedding Configuration Validation ---"
    
    local project_file="ios/Runner.xcodeproj/project.pbxproj"
    
    if [ ! -f "$project_file" ]; then
        record_validation "fail" "Xcode project file not found"
        return 1
    fi
    
    # Check for Flutter.xcframework configuration
    local flutter_refs
    flutter_refs=$(grep -c "Flutter\.xcframework" "$project_file" 2>/dev/null || echo "0")
    
    if [ "$flutter_refs" -gt 0 ]; then
        record_validation "pass" "Flutter.xcframework references found ($flutter_refs)"
        
        # Check for potential embedding conflicts
        if [ "$flutter_refs" -gt 3 ]; then
            record_validation "warn" "Many Flutter.xcframework references ($flutter_refs) - check embedding settings"
        fi
    else
        record_validation "warn" "No Flutter.xcframework references found"
    fi
    
    # Check for extension targets
    local extension_count
    extension_count=$(grep -c "\.extension\|\.widget\|\.notificationservice" "$project_file" 2>/dev/null || echo "0")
    
    if [ "$extension_count" -gt 0 ]; then
        record_validation "pass" "Extension targets detected ($extension_count)"
        
        # Check for embedding conflicts
        local embed_conflicts
        embed_conflicts=$(grep -A 5 -B 5 "\.extension\|\.widget\|\.notificationservice" "$project_file" | grep -c "Embed & Sign\|embedFrameworks" 2>/dev/null || echo "0")
        
        if [ "$embed_conflicts" -gt 0 ]; then
            record_validation "warn" "Extension targets may have framework embedding enabled"
        else
            record_validation "pass" "Extension targets properly configured"
        fi
    fi
    
    return 0
}

# Validation 6: Build Environment Validation
validate_build_environment() {
    log_info "--- Build Environment Validation ---"
    
    # Check Flutter project structure
    if [ -f "pubspec.yaml" ]; then
        record_validation "pass" "Flutter project structure valid"
    else
        record_validation "fail" "pubspec.yaml not found - not a Flutter project"
    fi
    
    # Check iOS-specific files
    if [ -f "ios/Flutter/Release.xcconfig" ]; then
        record_validation "pass" "iOS Release configuration found"
    else
        record_validation "warn" "iOS Release configuration may be missing"
    fi
    
    if [ -f "ios/Podfile" ]; then
        record_validation "pass" "Podfile found"
    else
        record_validation "fail" "Podfile missing - CocoaPods required"
    fi
    
    # Check Firebase configuration if enabled
    if [ "${PUSH_NOTIFY:-false}" = "true" ]; then
        if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
            record_validation "pass" "Firebase configuration file found"
        else
            record_validation "fail" "Firebase enabled but GoogleService-Info.plist missing"
        fi
    fi
    
    return 0
}

# Validation 7: Collision Prevention Readiness
validate_collision_prevention() {
    log_info "--- Collision Prevention Readiness Validation ---"
    
    # Check for collision prevention scripts
    local prevention_scripts=(
        "pre_build_collision_eliminator_fc526a49.sh"
        "pre_build_collision_eliminator_bcff0b91.sh"
        "nuclear_ipa_collision_eliminator_bcff0b91.sh"
        "framework_embedding_collision_fix.sh"
        "certificate_signing_fix_503ceb9c.sh"
    )
    
    local available_prevention=0
    for script in "${prevention_scripts[@]}"; do
        if [ -f "${SCRIPT_DIR}/$script" ]; then
            available_prevention=$((available_prevention + 1))
        fi
    done
    
    if [ "$available_prevention" -ge 4 ]; then
        record_validation "pass" "Comprehensive collision prevention available ($available_prevention/${#prevention_scripts[@]})"
    elif [ "$available_prevention" -ge 2 ]; then
        record_validation "warn" "Basic collision prevention available ($available_prevention/${#prevention_scripts[@]})"
    else
        record_validation "fail" "Insufficient collision prevention scripts"
    fi
    
    # Check for universal prevention
    if [ -f "${SCRIPT_DIR}/universal_nuclear_collision_eliminator.sh" ]; then
        record_validation "pass" "Universal collision eliminator available"
    else
        record_validation "warn" "Universal collision eliminator missing"
    fi
    
    return 0
}

# Generate validation report
generate_validation_report() {
    log_info "--- Generating Validation Report ---"
    
    local total_validations=$((VALIDATION_PASSED + VALIDATION_FAILED + WARNINGS))
    local success_rate=0
    
    if [ "$total_validations" -gt 0 ]; then
        success_rate=$((VALIDATION_PASSED * 100 / total_validations))
    fi
    
    local report_file="ios_export_validation_report_$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$report_file" << EOF
iOS Export Validation Report
============================
Generated: $(date)

Summary:
--------
Total Validations: $total_validations
Passed: $VALIDATION_PASSED
Failed: $VALIDATION_FAILED
Warnings: $WARNINGS
Success Rate: $success_rate%

Status:
-------
EOF

    if [ "$VALIDATION_FAILED" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
        echo "🎉 EXCELLENT - All validations passed" >> "$report_file"
    elif [ "$VALIDATION_FAILED" -eq 0 ]; then
        echo "✅ GOOD - No failures, but warnings present" >> "$report_file"
    elif [ "$VALIDATION_FAILED" -le 2 ]; then
        echo "⚠️ NEEDS ATTENTION - Some validations failed" >> "$report_file"
    else
        echo "❌ CRITICAL - Multiple validation failures" >> "$report_file"
    fi
    
    cat >> "$report_file" << EOF

Recommendations:
---------------
EOF

    if [ "$VALIDATION_FAILED" -gt 0 ]; then
        echo "1. Address all failed validations before attempting IPA export" >> "$report_file"
    fi
    
    if [ "$WARNINGS" -gt 0 ]; then
        echo "2. Review warnings to improve export reliability" >> "$report_file"
    fi
    
    if [ "$success_rate" -lt 80 ]; then
        echo "3. Consider comprehensive workflow review" >> "$report_file"
    fi
    
    echo "4. Run validation regularly, especially after configuration changes" >> "$report_file"
    
    log_success "Validation report generated: $report_file"
    return 0
}

# Main validation function
main() {
    log_info "🚀 Starting Comprehensive iOS Export Validation..."
    
    # Initialize counters
    VALIDATION_PASSED=0
    VALIDATION_FAILED=0
    WARNINGS=0
    
    # Run all validations
    validate_certificate_configuration
    validate_provisioning_profile
    validate_bundle_id_configuration
    validate_export_method_configuration
    validate_framework_embedding
    validate_build_environment
    validate_collision_prevention
    
    # Generate report
    generate_validation_report
    
    # Final summary
    local total_validations=$((VALIDATION_PASSED + VALIDATION_FAILED + WARNINGS))
    
    log_info "=== iOS Export Validation Complete ==="
    log_info "📊 Results: $VALIDATION_PASSED passed, $VALIDATION_FAILED failed, $WARNINGS warnings"
    
    if [ "$VALIDATION_FAILED" -eq 0 ]; then
        log_success "✅ All critical validations passed - ready for export"
        return 0
    else
        log_error "❌ $VALIDATION_FAILED validations failed - address issues before export"
        return 1
    fi
}

# Run main function if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi 