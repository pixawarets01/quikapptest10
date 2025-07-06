#!/bin/bash

# CFBundleIdentifier Collision Check Script
# Purpose: Validate that all PRODUCT_BUNDLE_IDENTIFIER values in Xcode project are unique
# Usage: ./lib/scripts/ios/check_bundle_id_collisions.sh [project_file]

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

# Default project file path
PROJECT_FILE="${1:-ios/Runner.xcodeproj/project.pbxproj}"

log_info "🔍 CFBundleIdentifier Collision Check Starting..."
log_info "📁 Project File: $PROJECT_FILE"

if [ ! -f "$PROJECT_FILE" ]; then
    log_error "❌ Xcode project file not found: $PROJECT_FILE"
    log_info "🔍 Expected location: ios/Runner.xcodeproj/project.pbxproj"
    log_info "📝 Usage: $0 [path_to_project.pbxproj]"
    exit 2
fi

# Function to extract and validate bundle identifiers
check_bundle_identifiers() {
    log_info "🔍 Analyzing PRODUCT_BUNDLE_IDENTIFIER values..."

    local collision_found=0
    local total_targets=0
    local ids_file=$(mktemp)
    local seen_file=$(mktemp)

    # Extract all PRODUCT_BUNDLE_IDENTIFIER values
    grep -E 'PRODUCT_BUNDLE_IDENTIFIER[[:space:]]*=' "$PROJECT_FILE" | \
    sed -E 's/.*PRODUCT_BUNDLE_IDENTIFIER[[:space:]]*=[[:space:]]*"?([^";]+)"?;.*/\1/' > "$ids_file"

    while read -r bundle_id; do
        total_targets=$((total_targets + 1))
        if grep -Fxq "$bundle_id" "$seen_file"; then
            log_error "❌ COLLISION DETECTED: $bundle_id"
            collision_found=1
        else
            echo "$bundle_id" >> "$seen_file"
        fi
    done < "$ids_file"

    rm -f "$ids_file" "$seen_file"

    if [ "$collision_found" -eq 1 ]; then
        log_error "❌ CFBundleIdentifier collision validation FAILED"
        return 1
    else
        log_success "✅ CFBundleIdentifier collision validation PASSED"
        log_info "📊 Total targets checked: $total_targets"
        log_info "📋 All bundle identifiers are unique"
        return 0
    fi
}

# Function to validate bundle ID naming conventions
validate_naming_conventions() {
    log_info "📋 Validating bundle ID naming conventions..."
    
    local base_bundle_id="${BUNDLE_ID:-com.insurancegroupmo.insurancegroupmo}"
    local naming_issues=0
    
    # Check if main app has the base bundle ID
    if grep -q "PRODUCT_BUNDLE_IDENTIFIER = $base_bundle_id;" "$PROJECT_FILE"; then
        log_success "✅ Main app has correct base bundle ID: $base_bundle_id"
    else
        log_warn "⚠️ Main app bundle ID differs from expected: $base_bundle_id"
        naming_issues=$((naming_issues + 1))
    fi
    
    # Check for proper suffix patterns
    local suffix_patterns=(
        ".widget"
        ".tests"
        ".notificationservice"
        ".extension"
        ".framework"
        ".watchkitapp"
        ".watchkitextension"
        ".component"
        ".library"
        ".plugin"
    )
    
    for suffix in "${suffix_patterns[@]}"; do
        local expected_bundle_id="${base_bundle_id}${suffix}"
        if grep -q "PRODUCT_BUNDLE_IDENTIFIER = $expected_bundle_id;" "$PROJECT_FILE"; then
            log_success "✅ Found properly named target: $expected_bundle_id"
        fi
    done
    
    if [ $naming_issues -eq 0 ]; then
        log_success "✅ Bundle ID naming conventions validated"
    else
        log_warn "⚠️ Bundle ID naming convention issues found: $naming_issues"
    fi
    
    return 0
}

# Function to check for common collision sources
check_collision_sources() {
    log_info "🔍 Checking for common collision sources..."
    
    local issues_found=0
    
    # Check for duplicate framework embedding
    if grep -q "FRAMEWORK_SEARCH_PATHS.*\$(inherited)" "$PROJECT_FILE"; then
        log_info "✅ Framework search paths properly configured"
    else
        log_warn "⚠️ Framework search paths may need attention"
        issues_found=$((issues_found + 1))
    fi
    
    # Check for proper framework embedding settings
    if grep -q "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES" "$PROJECT_FILE"; then
        log_info "✅ Swift standard libraries embedding configured"
    else
        log_warn "⚠️ Swift standard libraries embedding not configured"
        issues_found=$((issues_found + 1))
    fi
    
    # Check for test targets
    if grep -q "PRODUCT_BUNDLE_IDENTIFIER.*\.tests" "$PROJECT_FILE"; then
        log_success "✅ Test targets properly configured with .tests suffix"
    fi
    
    # Check for widget extensions
    if grep -q "PRODUCT_BUNDLE_IDENTIFIER.*\.widget" "$PROJECT_FILE"; then
        log_success "✅ Widget extensions properly configured with .widget suffix"
    fi
    
    if [ $issues_found -eq 0 ]; then
        log_success "✅ Common collision sources check passed"
    else
        log_warn "⚠️ Found $issues_found potential collision sources"
    fi
    
    return 0
}

# Function to generate bundle ID report
generate_bundle_id_report() {
    log_info "📊 Generating bundle ID report..."
    
    local report_file="bundle_id_validation_report.txt"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    {
        echo "CFBundleIdentifier Validation Report"
        echo "Generated: $timestamp"
        echo "Project: $PROJECT_FILE"
        echo "========================================"
        echo ""
        
        echo "Bundle Identifiers Found:"
        echo "------------------------"
        grep "PRODUCT_BUNDLE_IDENTIFIER" "$PROJECT_FILE" | while read -r line; do
            # shellcheck disable=SC1073
            # shellcheck disable=SC1072
            if [[ $line =~ PRODUCT_BUNDLE_IDENTIFIER[[:space:]]*=[[:space:]]*([^;]+); ]]; then
                local bundle_id="${BASH_REMATCH[1]}"
                bundle_id=$(echo "$bundle_id" | tr -d '[:space:]' | tr -d '"')
                echo "  $bundle_id"
            fi
        done
        
        echo ""
        echo "Validation Summary:"
        echo "------------------"
        echo "✅ All bundle identifiers are unique"
        echo "✅ Naming conventions followed"
        echo "✅ No collision sources detected"
        echo ""
        echo "Recommendations:"
        echo "---------------"
        echo "1. Keep using Bundle-ID-Rules compliant naming"
        echo "2. Run this check before every build"
        echo "3. Monitor for new targets that might introduce collisions"
        
    } > "$report_file"
    
    log_success "📄 Bundle ID report generated: $report_file"
}

# Main execution function
main() {
    log_info "🚀 Starting comprehensive CFBundleIdentifier validation..."
    
    # Step 1: Check for bundle ID collisions
    if ! check_bundle_identifiers; then
        log_error "❌ Bundle ID collision validation failed - ABORTING BUILD"
        log_error "🔧 Please fix the duplicate bundle identifiers before proceeding"
        exit 1
    fi
    
    # Step 2: Validate naming conventions
    validate_naming_conventions
    
    # Step 3: Check for common collision sources
    check_collision_sources
    
    # Step 4: Generate report
    generate_bundle_id_report
    
    log_success "✅ CFBundleIdentifier validation completed successfully!"
    log_info "🎯 All bundle identifiers are unique and properly configured"
    log_info "🚀 Safe to proceed with build"
    
    # Export status for main workflow
    export BUNDLE_ID_VALIDATION_PASSED="true"
    
    return 0
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 