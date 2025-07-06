#!/bin/bash

# Bundle ID Rules Validator
# Purpose: Validate bundle ID configuration against iOS best practices

set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

log_info "🔍 Starting Bundle ID Rules Validation..."

# Validate main bundle ID
validate_main_bundle_id() {
    local bundle_id="${BUNDLE_ID:-}"
    
    if [ -z "$bundle_id" ]; then
        log_error "❌ Bundle ID not set"
        return 1
    fi
    
    # Check format
    if [[ ! "$bundle_id" =~ ^[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)*$ ]]; then
        log_error "❌ Invalid bundle ID format: $bundle_id"
        return 1
    fi
    
    log_success "✅ Main bundle ID valid: $bundle_id"
    return 0
}

# Check target suffixes
check_target_suffixes() {
    local bundle_id="${BUNDLE_ID:-}"
    local suffixes=(".widget" ".tests" ".notificationservice" ".extension" ".framework")
    
    log_info "🎯 Checking target suffixes..."
    
    for suffix in "${suffixes[@]}"; do
        local target_bundle="${bundle_id}${suffix}"
        if [ ${#target_bundle} -le 255 ]; then
            log_success "  ✅ ${target_bundle}"
        else
            log_warn "  ⚠️ Too long: ${target_bundle}"
        fi
    done
    
    return 0
}

# Main validation
main() {
    validate_main_bundle_id
    check_target_suffixes
    log_success "Bundle ID validation complete"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi 