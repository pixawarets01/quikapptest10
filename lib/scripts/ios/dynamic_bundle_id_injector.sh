#!/bin/bash

# Dynamic Bundle ID Injector for iOS Project
# Purpose: Inject dynamic bundle identifiers using environment variables from Codemagic
# This script makes the project a template that can work with any bundle ID

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

log_info "🎯 Dynamic Bundle ID Injection for iOS Project"

# Function to inject dynamic bundle identifiers
inject_dynamic_bundle_ids() {
    local project_file="ios/Runner.xcodeproj/project.pbxproj"
    local backup_path="${project_file}.dynamic_backup_$(date +%s)"
    
    if [ ! -f "$project_file" ]; then
        log_error "❌ Project file not found: $project_file"
        return 1
    fi
    
    # Create backup
    cp "$project_file" "$backup_path"
    log_info "📦 Backup created: $backup_path"
    
    # Get the base bundle ID from environment or use default
    local base_bundle_id="${BUNDLE_ID:-com.twinklub.twinklub}"
    log_info "🎯 Base bundle ID from environment: $base_bundle_id"
    
    # Validate bundle ID format
    if [[ ! "$base_bundle_id" =~ ^[a-zA-Z][a-zA-Z0-9]*(\.[a-zA-Z][a-zA-Z0-9]*)*$ ]]; then
        log_error "❌ Invalid bundle ID format: $base_bundle_id"
        log_error "Bundle ID must be in format: com.company.app"
        return 1
    fi
    
    log_info "🔧 Injecting dynamic bundle identifiers..."
    
    # Replace hardcoded bundle identifiers with dynamic ones
    # Main app targets (Runner)
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com\.twinklub\.twinklub;/PRODUCT_BUNDLE_IDENTIFIER = $base_bundle_id;/g" "$project_file"
    # Replace all other occurrences (comments, metadata, etc.)
    sed -i '' "s/com\.twinklub\.twinklub/$base_bundle_id/g" "$project_file"
    
    # Test targets (RunnerTests)
    local test_bundle_id="${base_bundle_id}.tests"
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = $base_bundle_id\.tests;/PRODUCT_BUNDLE_IDENTIFIER = $test_bundle_id;/g" "$project_file"
    
    # Extension targets (if any) - add .extension suffix
    local extension_bundle_id="${base_bundle_id}.extension"
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com\.twinklub\.twinklub\.extension;/PRODUCT_BUNDLE_IDENTIFIER = $extension_bundle_id;/g" "$project_file"
    
    # Widget targets (if any) - add .widget suffix
    local widget_bundle_id="${base_bundle_id}.widget"
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com\.twinklub\.twinklub\.widget;/PRODUCT_BUNDLE_IDENTIFIER = $widget_bundle_id;/g" "$project_file"
    
    log_success "✅ Dynamic bundle identifiers injected successfully"
    
    # Verify the injection
    log_info "🔍 Verifying bundle identifier injection..."
    local main_app_count
    local test_count
    local extension_count
    local widget_count
    
    main_app_count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $base_bundle_id;" "$project_file" | tr -d '\n' || echo "0")
    test_count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $test_bundle_id;" "$project_file" | tr -d '\n' || echo "0")
    extension_count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $extension_bundle_id;" "$project_file" | tr -d '\n' || echo "0")
    widget_count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $widget_bundle_id;" "$project_file" | tr -d '\n' || echo "0")
    
    log_info "📊 Bundle ID Distribution:"
    log_info "   Main App ($base_bundle_id): $main_app_count targets"
    log_info "   Tests ($test_bundle_id): $test_count targets"
    log_info "   Extensions ($extension_bundle_id): $extension_count targets"
    log_info "   Widgets ($widget_bundle_id): $widget_count targets"
    
    # Check for any remaining hardcoded bundle IDs
    local remaining_hardcoded
    remaining_hardcoded=$(grep -c "com\.twinklub\.twinklub" "$project_file" | tr -d '\n' || echo "0")
    
    if [ "$remaining_hardcoded" -gt 0 ]; then
        log_warn "⚠️ Found $remaining_hardcoded remaining hardcoded bundle identifiers"
        log_info "🔍 Remaining hardcoded bundle IDs:"
        grep "com\.twinklub\.twinklub" "$project_file" || true
    else
        log_success "✅ No hardcoded bundle identifiers remaining"
    fi
    
    # Summary
    log_info "=== Dynamic Bundle ID Injection Summary ==="
    log_info "✅ Base Bundle ID: $base_bundle_id"
    log_info "✅ Test Bundle ID: $test_bundle_id"
    log_info "✅ Extension Bundle ID: $extension_bundle_id"
    log_info "✅ Widget Bundle ID: $widget_bundle_id"
    local total_targets=$((main_app_count + test_count + extension_count + widget_count))
    log_info "✅ Total targets updated: $total_targets"
    
    return 0
}

# Function to validate environment variables
validate_environment() {
    log_info "🔍 Validating environment variables..."
    
    # Check if BUNDLE_ID is set
    if [ -z "${BUNDLE_ID:-}" ]; then
        log_warn "⚠️ BUNDLE_ID environment variable not set, using default: com.twinklub.twinklub"
        log_info "💡 To use a custom bundle ID, set BUNDLE_ID environment variable in Codemagic"
    else
        log_info "✅ BUNDLE_ID environment variable found: $BUNDLE_ID"
    fi
    
    # Check other required environment variables
    local required_vars=("CM_BUILD_ID" "CM_PROJECT_ID" "APP_NAME")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var:-}" ]; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -gt 0 ]; then
        log_warn "⚠️ Missing environment variables: ${missing_vars[*]}"
        log_info "💡 These variables are recommended but not required for bundle ID injection"
    else
        log_success "✅ All recommended environment variables are set"
    fi
}

# Main execution
main() {
    log_info "🚀 Starting Dynamic Bundle ID Injection"
    
    # Validate environment
    validate_environment
    
    # Inject dynamic bundle identifiers
    if inject_dynamic_bundle_ids; then
        log_success "🎉 Dynamic bundle ID injection completed successfully"
        return 0
    else
        log_error "❌ Dynamic bundle ID injection failed"
        return 1
    fi
}

# Run main function
main "$@" 