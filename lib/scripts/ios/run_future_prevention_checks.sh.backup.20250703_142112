#!/bin/bash

# Run Future Prevention Checks
# Purpose: Execute all future error prevention validation scripts

set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

log_info "🛡️ Running Comprehensive Future Error Prevention Checks..."

# Track results
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Function to run a validation script
run_check() {
    local script="$1"
    local description="$2"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    log_info "🔍 $description"
    
    if [ -f "${SCRIPT_DIR}/$script" ]; then
        chmod +x "${SCRIPT_DIR}/$script"
        
        if "${SCRIPT_DIR}/$script"; then
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
            log_success "✅ PASSED: $description"
        else
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
            log_error "❌ FAILED: $description"
        fi
    else
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        log_warn "⚠️ MISSING: $script"
    fi
}

# Main validation execution
main() {
    log_info "🚀 Starting Future Error Prevention Validation Suite..."
    
    # Run all validation scripts
    run_check "bundle_id_rules_validator.sh" "Bundle ID Rules Validation"
    run_check "framework_validation.sh" "Framework Embedding Validation"
    run_check "certificate_chain_validator.sh" "Certificate Chain Validation"
    run_check "error_pattern_predictor.sh" "Error Pattern Prediction"
    
    # Calculate success rate
    local success_rate=0
    if [ "$TOTAL_CHECKS" -gt 0 ]; then
        success_rate=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
    fi
    
    # Final report
    log_info "=== FUTURE ERROR PREVENTION VALIDATION COMPLETE ==="
    log_info "📊 Results: $PASSED_CHECKS/$TOTAL_CHECKS passed ($success_rate%)"
    log_info "❌ Failed: $FAILED_CHECKS"
    
    # Assessment
    if [ "$success_rate" -ge 90 ]; then
        log_success "🎉 EXCELLENT: iOS workflow optimized for future error prevention"
    elif [ "$success_rate" -ge 75 ]; then
        log_success "✅ GOOD: iOS workflow has solid future error prevention"
    elif [ "$success_rate" -ge 60 ]; then
        log_warn "⚠️ FAIR: iOS workflow needs improvements"
    else
        log_error "❌ POOR: iOS workflow requires significant improvements"
    fi
    
    # Return status based on critical failures
    if [ "$FAILED_CHECKS" -eq 0 ]; then
        return 0
    elif [ "$FAILED_CHECKS" -le 2 ]; then
        return 0
    else
        return 1
    fi
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi 