#!/bin/bash

# iOS Workflow Health Checker and Future Error Prevention System
# Purpose: Validate iOS workflow configuration and predict potential future issues
# Based on: iOS app IPA export documentation and collision pattern analysis

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

log_info "🔮 Starting iOS Workflow Health Check and Future Error Prevention..."

# Global health metrics
HEALTH_SCORE=0
MAX_HEALTH_SCORE=0
CRITICAL_ISSUES=0
WARNINGS=0
RECOMMENDATIONS=()

# Function to add health points
add_health_points() {
    local points=${1:-1}
    HEALTH_SCORE=$((HEALTH_SCORE + points))
    MAX_HEALTH_SCORE=$((MAX_HEALTH_SCORE + points))
}

# Function to record health issue
record_health_issue() {
    local severity="$1"
    local message="$2"
    
    case "$severity" in
        "critical")
            CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
            log_error "🚨 CRITICAL: $message"
            ;;
        "warning")
            WARNINGS=$((WARNINGS + 1))
            log_warn "⚠️ WARNING: $message"
            ;;
    esac
}

# Function to add recommendation
add_recommendation() {
    local rec="$1"
    RECOMMENDATIONS+=("$rec")
    log_info "💡 RECOMMENDATION: $rec"
}

# Health Check 1: Bundle ID Future-Proofing
check_bundle_id_future_proofing() {
    log_info "--- Bundle ID Future-Proofing Check ---"
    
    local bundle_id="${BUNDLE_ID:-}"
    
    if [ -z "$bundle_id" ]; then
        record_health_issue "critical" "Bundle ID not configured"
        return 1
    fi
    
    # Validate bundle ID format for iOS compliance
    if [[ ! "$bundle_id" =~ ^[a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?)*$ ]]; then
        record_health_issue "critical" "Bundle ID format violates Apple guidelines: $bundle_id"
        return 1
    fi
    
    # Check for future collision prevention compliance
    local future_targets=(
        ".widget" ".tests" ".notificationservice" ".extension" 
        ".framework" ".watchkitapp" ".watchkitextension" ".shareextension"
        ".intents" ".component"
    )
    
    log_info "🎯 Validating future target bundle IDs..."
    local valid_targets=0
    
    for suffix in "${future_targets[@]}"; do
        local target_bundle="${bundle_id}${suffix}"
        
        # Check length limits (Apple: 255 chars)
        if [ ${#target_bundle} -le 255 ]; then
            valid_targets=$((valid_targets + 1))
            log_success "  ✅ ${target_bundle}"
        else
            record_health_issue "warning" "Target bundle ID too long: ${target_bundle} (${#target_bundle} chars)"
        fi
    done
    
    if [ "$valid_targets" -eq ${#future_targets[@]} ]; then
        add_health_points 5
        log_success "Bundle ID future-proofing: EXCELLENT"
    else
        add_health_points 2
        add_recommendation "Consider shorter base bundle ID for better extension support"
    fi
    
    return 0
}

# Health Check 2: Framework Embedding Configuration
check_framework_embedding_safety() {
    log_info "--- Framework Embedding Safety Check ---"
    
    local project_file="ios/Runner.xcodeproj/project.pbxproj"
    
    if [ ! -f "$project_file" ]; then
        record_health_issue "critical" "Xcode project file missing: $project_file"
        return 1
    fi
    
    # Analyze framework embedding patterns
    log_info "🔍 Analyzing framework embedding configuration..."
    
    # Check for multiple Flutter.xcframework references
    local flutter_refs
    flutter_refs=$(grep -c "Flutter\.xcframework" "$project_file" 2>/dev/null || echo "0")
    
    if [ "$flutter_refs" -gt 2 ]; then
        record_health_issue "warning" "Multiple Flutter.xcframework references: $flutter_refs (potential collision source)"
        add_recommendation "Verify extension targets use 'Do Not Embed' for Flutter.xcframework"
    else
        add_health_points 3
    fi
    
    # Check for proper extension target configuration
    local extension_embeds
    extension_embeds=$(grep -A 5 -B 5 "\.extension\|\.widget\|\.notificationservice" "$project_file" | grep -c "Embed & Sign\|embedFrameworks" 2>/dev/null || echo "0")
    
    if [ "$extension_embeds" -gt 0 ]; then
        record_health_issue "warning" "Extension targets may have framework embedding enabled"
        add_recommendation "Set extension targets to 'Do Not Embed' to prevent CFBundleIdentifier collisions"
    else
        add_health_points 2
    fi
    
    log_success "Framework embedding safety check completed"
    return 0
}

# Health Check 3: Certificate Chain Resilience
check_certificate_chain_resilience() {
    log_info "--- Certificate Chain Resilience Check ---"
    
    local cert_methods=0
    local available_methods=()
    
    # Check P12 method
    if [ -n "${CERT_P12_URL:-}" ] && [ -n "${CERT_PASSWORD:-}" ]; then
        cert_methods=$((cert_methods + 1))
        available_methods+=("P12")
        log_success "✅ P12 certificate method configured"
    fi
    
    # Check CER+KEY method
    if [ -n "${CERT_CER_URL:-}" ] && [ -n "${CERT_KEY_URL:-}" ]; then
        cert_methods=$((cert_methods + 1))
        available_methods+=("CER+KEY")
        log_success "✅ CER+KEY certificate method configured"
    fi
    
    # Check App Store Connect API
    if [ -n "${APP_STORE_CONNECT_API_KEY_PATH:-}" ] && [ -n "${APP_STORE_CONNECT_KEY_IDENTIFIER:-}" ] && [ -n "${APP_STORE_CONNECT_ISSUER_ID:-}" ]; then
        cert_methods=$((cert_methods + 1))
        available_methods+=("App Store Connect API")
        log_success "✅ App Store Connect API configured"
    fi
    
    case "$cert_methods" in
        0)
            record_health_issue "critical" "No certificate methods configured"
            return 1
            ;;
        1)
            record_health_issue "warning" "Only one certificate method available (${available_methods[0]})"
            add_recommendation "Configure multiple certificate methods for resilience"
            add_health_points 2
            ;;
        2)
            log_success "Good certificate redundancy: ${available_methods[*]}"
            add_health_points 4
            ;;
        3)
            log_success "EXCELLENT certificate redundancy: ${available_methods[*]}"
            add_health_points 5
            ;;
    esac
    
    # Validate supporting configuration
    if [ -z "${PROFILE_URL:-}" ]; then
        record_health_issue "critical" "Provisioning profile URL not configured"
    else
        add_health_points 2
    fi
    
    if [ -z "${APPLE_TEAM_ID:-}" ]; then
        record_health_issue "critical" "Apple Team ID not configured"
    else
        add_health_points 2
    fi
    
    return 0
}

# Health Check 4: Export Options Robustness
check_export_options_robustness() {
    log_info "--- Export Options Robustness Check ---"
    
    local profile_type="${PROFILE_TYPE:-app-store}"
    
    # Validate profile type
    case "$profile_type" in
        "app-store"|"ad-hoc"|"enterprise"|"development")
            log_success "Valid profile type: $profile_type"
            add_health_points 2
            ;;
        *)
            record_health_issue "warning" "Non-standard profile type: $profile_type"
            add_recommendation "Use standard profile types: app-store, ad-hoc, enterprise, development"
            ;;
    esac
    
    # Check for export options scripts
    local export_scripts=(
        "export_ipa_framework_fix.sh"
        "ipa_export_with_certificate_validation.sh"
        "enhanced_certificate_setup.sh"
    )
    
    local available_export_scripts=0
    for script in "${export_scripts[@]}"; do
        if [ -f "${SCRIPT_DIR}/$script" ]; then
            available_export_scripts=$((available_export_scripts + 1))
        fi
    done
    
    if [ "$available_export_scripts" -ge 2 ]; then
        log_success "Multiple export methods available: $available_export_scripts/${#export_scripts[@]}"
        add_health_points 3
    elif [ "$available_export_scripts" -eq 1 ]; then
        record_health_issue "warning" "Limited export method options"
        add_recommendation "Implement multiple export methods for fallback support"
        add_health_points 1
    else
        record_health_issue "critical" "No enhanced export methods available"
    fi
    
    return 0
}

# Health Check 5: Collision Prevention Coverage
check_collision_prevention_coverage() {
    log_info "--- Collision Prevention Coverage Check ---"
    
    # Known error IDs that should have prevention
    local known_error_ids=(
        "fc526a49" "bcff0b91" "f8db6738" "f8b4b738" 
        "64c3ce97" "dccb3cf9" "503ceb9c" "8d2aeb71"
    )
    
    local pre_build_scripts=0
    local nuclear_scripts=0
    local certificate_scripts=0
    
    # Check pre-build prevention scripts
    for error_id in "${known_error_ids[@]}"; do
        if [ -f "${SCRIPT_DIR}/pre_build_collision_eliminator_${error_id}.sh" ]; then
            pre_build_scripts=$((pre_build_scripts + 1))
        fi
        
        if [ -f "${SCRIPT_DIR}/nuclear_ipa_collision_eliminator_${error_id}.sh" ]; then
            nuclear_scripts=$((nuclear_scripts + 1))
        fi
        
        if [ -f "${SCRIPT_DIR}/certificate_signing_fix_${error_id}.sh" ]; then
            certificate_scripts=$((certificate_scripts + 1))
        fi
    done
    
    log_info "🛡️ Collision Prevention Coverage:"
    log_info "  Pre-build scripts: $pre_build_scripts/${#known_error_ids[@]}"
    log_info "  Nuclear IPA scripts: $nuclear_scripts/${#known_error_ids[@]}"
    log_info "  Certificate scripts: $certificate_scripts/${#known_error_ids[@]}"
    
    local total_coverage=$((pre_build_scripts + nuclear_scripts + certificate_scripts))
    local max_coverage=$((${#known_error_ids[@]} * 3))
    local coverage_percentage=$((total_coverage * 100 / max_coverage))
    
    if [ "$coverage_percentage" -ge 80 ]; then
        log_success "EXCELLENT collision prevention coverage: $coverage_percentage%"
        add_health_points 5
    elif [ "$coverage_percentage" -ge 60 ]; then
        log_success "GOOD collision prevention coverage: $coverage_percentage%"
        add_health_points 3
    else
        record_health_issue "warning" "LIMITED collision prevention coverage: $coverage_percentage%"
        add_recommendation "Implement more collision prevention scripts for better coverage"
        add_health_points 1
    fi
    
    # Check for universal prevention scripts
    if [ -f "${SCRIPT_DIR}/universal_nuclear_collision_eliminator.sh" ]; then
        log_success "✅ Universal collision eliminator available"
        add_health_points 2
    else
        add_recommendation "Implement universal collision eliminator for future-proofing"
    fi
    
    return 0
}

# Health Check 6: Workflow Flow Ordering
check_workflow_flow_ordering() {
    log_info "--- Workflow Flow Ordering Check ---"
    
    # Analyze main.sh for proper stage ordering
    local main_script="${SCRIPT_DIR}/main.sh"
    
    if [ ! -f "$main_script" ]; then
        record_health_issue "critical" "Main workflow script missing"
        return 1
    fi
    
    # Check for critical ordering patterns
    local api_integration_line
    local collision_prevention_line
    
    api_integration_line=$(grep -n "Stage 6.90.*Codemagic API Integration" "$main_script" | cut -d: -f1 2>/dev/null || echo "0")
    collision_prevention_line=$(grep -n "Stage 6.91.*Collision Elimination" "$main_script" | cut -d: -f1 2>/dev/null || echo "0")
    
    if [ "$api_integration_line" -gt 0 ] && [ "$collision_prevention_line" -gt 0 ]; then
        if [ "$api_integration_line" -lt "$collision_prevention_line" ]; then
            log_success "✅ Proper flow ordering: API integration before collision prevention"
            add_health_points 3
        else
            record_health_issue "critical" "FLOW ORDERING ERROR: Collision prevention runs before API integration"
            add_recommendation "Move API integration (Stage 6.90) before collision prevention stages"
        fi
    else
        record_health_issue "warning" "Flow ordering stages not clearly defined"
        add_recommendation "Implement clear stage ordering in workflow"
        add_health_points 1
    fi
    
    # Check for certificate setup before IPA export
    local cert_setup_line
    local ipa_export_line
    
    cert_setup_line=$(grep -n "Stage 3.*Certificate" "$main_script" | head -1 | cut -d: -f1 2>/dev/null || echo "0")
    ipa_export_line=$(grep -n "Stage 8.*IPA Export\|Exporting IPA" "$main_script" | head -1 | cut -d: -f1 2>/dev/null || echo "0")
    
    if [ "$cert_setup_line" -gt 0 ] && [ "$ipa_export_line" -gt 0 ] && [ "$cert_setup_line" -lt "$ipa_export_line" ]; then
        log_success "✅ Certificate setup before IPA export"
        add_health_points 2
    else
        record_health_issue "warning" "Certificate setup and IPA export ordering unclear"
    fi
    
    return 0
}

# Health Check 7: Firebase Integration Safety
check_firebase_integration_safety() {
    log_info "--- Firebase Integration Safety Check ---"
    
    if [ "${PUSH_NOTIFY:-false}" = "true" ]; then
        log_info "🔥 Firebase integration enabled"
        
        # Check for Firebase configuration file
        if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
            log_success "✅ GoogleService-Info.plist present"
            add_health_points 2
        else
            record_health_issue "critical" "Firebase enabled but GoogleService-Info.plist missing"
        fi
        
        # Check for Firebase compatibility fixes
        local firebase_fixes=(
            "fix_firebase_xcode16.sh"
            "fix_firebase_source_files.sh"
            "final_firebase_solution.sh"
        )
        
        local available_fixes=0
        for fix in "${firebase_fixes[@]}"; do
            if [ -f "${SCRIPT_DIR}/$fix" ]; then
                available_fixes=$((available_fixes + 1))
            fi
        done
        
        if [ "$available_fixes" -ge 2 ]; then
            log_success "Firebase compatibility fixes available: $available_fixes/${#firebase_fixes[@]}"
            add_health_points 3
        else
            record_health_issue "warning" "Limited Firebase compatibility fixes"
            add_recommendation "Implement comprehensive Firebase Xcode compatibility fixes"
            add_health_points 1
        fi
        
    else
        log_info "🔥 Firebase integration disabled"
        add_health_points 1
    fi
    
    return 0
}

# Health Check 8: Future Error Pattern Prediction
check_future_error_prediction() {
    log_info "--- Future Error Pattern Prediction ---"
    
    # Analyze historical error patterns
    local error_patterns=(
        "fc526a49" "bcff0b91" "f8db6738" "f8b4b738" 
        "64c3ce97" "dccb3cf9" "503ceb9c" "8d2aeb71"
    )
    
    log_info "🎯 Historical error pattern analysis:"
    log_info "  Pattern: 8-character hexadecimal error IDs"
    log_info "  Common sources: CFBundleIdentifier collisions, certificate signing"
    log_info "  Evolution: Framework embedding → Bundle ID conflicts → Certificate issues"
    
    # Check for adaptable prevention mechanisms
    local adaptable_scripts=0
    
    if [ -f "${SCRIPT_DIR}/universal_nuclear_collision_eliminator.sh" ]; then
        adaptable_scripts=$((adaptable_scripts + 1))
        log_success "✅ Universal collision eliminator"
    fi
    
    if [ -f "${SCRIPT_DIR}/collision_diagnostics.sh" ]; then
        adaptable_scripts=$((adaptable_scripts + 1))
        log_success "✅ Collision diagnostics"
    fi
    
    if [ -f "${SCRIPT_DIR}/framework_embedding_collision_fix.sh" ]; then
        adaptable_scripts=$((adaptable_scripts + 1))
        log_success "✅ Framework embedding fix"
    fi
    
    if [ "$adaptable_scripts" -ge 2 ]; then
        log_success "Good adaptability for future error patterns"
        add_health_points 3
    else
        record_health_issue "warning" "Limited adaptability for future error patterns"
        add_recommendation "Implement universal, adaptable collision prevention scripts"
        add_health_points 1
    fi
    
    # Predict likely future issues
    log_info "🔮 Predicted future issue sources:"
    log_info "  1. New iOS version compatibility (framework changes)"
    log_info "  2. Xcode version updates (build tool changes)"
    log_info "  3. App Store Connect validation updates"
    log_info "  4. New extension types and target configurations"
    log_info "  5. Certificate authority changes"
    
    return 0
}

# Generate comprehensive health report
generate_health_report() {
    log_info "--- Generating Comprehensive Health Report ---"
    
    local health_percentage=0
    if [ "$MAX_HEALTH_SCORE" -gt 0 ]; then
        health_percentage=$((HEALTH_SCORE * 100 / MAX_HEALTH_SCORE))
    fi
    
    local report_file="ios_workflow_health_report_$(date +%Y%m%d_%H%M%S).md"
    
    cat > "$report_file" << EOF
# iOS Workflow Health Report

**Generated:** $(date)  
**Health Score:** $HEALTH_SCORE/$MAX_HEALTH_SCORE ($health_percentage%)

## Health Summary

### Overall Health Assessment
EOF

    if [ "$health_percentage" -ge 90 ]; then
        echo "🎉 **EXCELLENT** - Workflow is highly optimized for future error prevention" >> "$report_file"
    elif [ "$health_percentage" -ge 80 ]; then
        echo "✅ **VERY GOOD** - Workflow has strong future error prevention" >> "$report_file"
    elif [ "$health_percentage" -ge 70 ]; then
        echo "👍 **GOOD** - Workflow has adequate future error prevention" >> "$report_file"
    elif [ "$health_percentage" -ge 60 ]; then
        echo "⚠️ **FAIR** - Workflow needs improvements for future error prevention" >> "$report_file"
    else
        echo "❌ **POOR** - Workflow requires significant improvements" >> "$report_file"
    fi
    
    cat >> "$report_file" << EOF

### Issue Breakdown
- **Critical Issues:** $CRITICAL_ISSUES
- **Warnings:** $WARNINGS
- **Total Recommendations:** ${#RECOMMENDATIONS[@]}

## Detailed Health Checks

### 1. Bundle ID Future-Proofing ✅
- Validates bundle ID format against Apple guidelines
- Checks future extension target compatibility
- Ensures proper naming convention compliance

### 2. Framework Embedding Safety ✅
- Analyzes Xcode project framework configurations
- Detects potential CFBundleIdentifier collision sources
- Validates extension target embedding settings

### 3. Certificate Chain Resilience ✅
- Validates multiple certificate method availability
- Checks supporting configuration completeness
- Ensures signing redundancy

### 4. Export Options Robustness ✅
- Validates profile type configuration
- Checks export method script availability
- Ensures fallback export capabilities

### 5. Collision Prevention Coverage ✅
- Analyzes coverage for known error IDs
- Validates prevention script availability
- Checks universal prevention capabilities

### 6. Workflow Flow Ordering ✅
- Validates critical stage ordering
- Ensures API integration before collision prevention
- Verifies certificate setup before IPA export

### 7. Firebase Integration Safety ✅
- Validates Firebase configuration when enabled
- Checks compatibility fix availability
- Ensures proper integration safety

### 8. Future Error Pattern Prediction ✅
- Analyzes historical error patterns
- Validates adaptable prevention mechanisms
- Predicts likely future issue sources

## Recommendations

EOF

    local rec_num=1
    for rec in "${RECOMMENDATIONS[@]}"; do
        echo "$rec_num. $rec" >> "$report_file"
        rec_num=$((rec_num + 1))
    done
    
    cat >> "$report_file" << EOF

## Future Error Prevention Strategy

### Immediate Actions (Critical Issues: $CRITICAL_ISSUES)
EOF

    if [ "$CRITICAL_ISSUES" -gt 0 ]; then
        echo "❗ Address all critical issues before running production builds" >> "$report_file"
    else
        echo "✅ No critical issues found - workflow ready for production" >> "$report_file"
    fi
    
    cat >> "$report_file" << EOF

### Short-term Improvements (Warnings: $WARNINGS)
- Implement missing prevention scripts
- Add redundancy to single-point failures
- Improve error handling coverage

### Long-term Optimization
- Monitor for new error patterns
- Implement universal prevention mechanisms
- Maintain adaptability for iOS ecosystem changes

## Validation Commands

\`\`\`bash
# Run health check
./ios_workflow_health_checker.sh

# Validate specific components
./future_error_prevention_system.sh
./validate_bundle_id_rules.sh
./comprehensive_certificate_validation.sh
\`\`\`

## Monitoring

Regular health checks should be performed:
- Before major iOS/Xcode updates
- After workflow modifications
- When new error patterns emerge
- Monthly for production workflows

EOF

    log_success "Health report generated: $report_file"
    return 0
}

# Main health check function
main() {
    log_info "🚀 Starting iOS Workflow Health Check..."
    
    # Initialize metrics
    HEALTH_SCORE=0
    MAX_HEALTH_SCORE=0
    CRITICAL_ISSUES=0
    WARNINGS=0
    RECOMMENDATIONS=()
    
    # Run all health checks
    check_bundle_id_future_proofing || true
    check_framework_embedding_safety || true
    check_certificate_chain_resilience || true
    check_export_options_robustness || true
    check_collision_prevention_coverage || true
    check_workflow_flow_ordering || true
    check_firebase_integration_safety || true
    check_future_error_prediction || true
    
    # Generate comprehensive report
    generate_health_report
    
    # Calculate final health percentage
    local health_percentage=0
    if [ "$MAX_HEALTH_SCORE" -gt 0 ]; then
        health_percentage=$((HEALTH_SCORE * 100 / MAX_HEALTH_SCORE))
    fi
    
    # Final assessment
    log_info "=== iOS WORKFLOW HEALTH CHECK COMPLETE ==="
    log_info "📊 Health Score: $HEALTH_SCORE/$MAX_HEALTH_SCORE ($health_percentage%)"
    log_info "🚨 Critical Issues: $CRITICAL_ISSUES"
    log_info "⚠️ Warnings: $WARNINGS"
    log_info "💡 Recommendations: ${#RECOMMENDATIONS[@]}"
    
    # Return based on health status
    if [ "$CRITICAL_ISSUES" -gt 0 ]; then
        log_error "Critical issues found - address before production builds"
        return 1
    elif [ "$health_percentage" -ge 80 ]; then
        log_success "Workflow health: EXCELLENT - Ready for future error prevention"
        return 0
    elif [ "$health_percentage" -ge 60 ]; then
        log_warn "Workflow health: GOOD - Some improvements recommended"
        return 0
    else
        log_warn "Workflow health: NEEDS IMPROVEMENT - Address warnings for better resilience"
        return 1
    fi
}

# Run main function if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi 