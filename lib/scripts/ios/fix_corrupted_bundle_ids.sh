#!/bin/bash

# Fix Corrupted Bundle Identifiers in iOS Project
# Purpose: Fix bundle identifiers that have been corrupted by collision fixes

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

log_info "🔧 Fixing corrupted bundle identifiers in iOS project..."

# Function to fix corrupted bundle identifiers
fix_corrupted_bundle_ids() {
    local project_file="ios/Runner.xcodeproj/project.pbxproj"
    local backup_path="${project_file}.corrupted_bundle_backup_$(date +%s)"
    
    if [ ! -f "$project_file" ]; then
        log_error "❌ Project file not found: $project_file"
        return 1
    fi
    
    # Create backup
    cp "$project_file" "$backup_path"
    log_info "📦 Backup created: $backup_path"
    
    # Get the base bundle ID from environment or use default
    local base_bundle_id="${BUNDLE_ID:-com.twinklub.twinklub}"
    log_info "🎯 Base bundle ID: $base_bundle_id"
    
    # Fix corrupted bundle identifiers
    log_info "🔧 Fixing corrupted bundle identifiers..."
    
    # Replace corrupted bundle identifiers with proper ones
    # Pattern: com.twinklub.twinklub.framework.1751538945.X.framework.1751538933.X
    # Should be: $BUNDLE_ID for main app, $BUNDLE_ID.tests for test targets
    
    # Fix main app bundle identifiers (Runner target)
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com\.twinklub\.twinklub\.framework\.[0-9]+\.[0-9]+\.framework\.[0-9]+\.[0-9]+;/PRODUCT_BUNDLE_IDENTIFIER = $base_bundle_id;/g" "$project_file"
    
    # Fix test target bundle identifiers
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com\.twinklub\.twinklub\.framework\.[0-9]+\.[0-9]+\.framework\.[0-9]+\.[0-9]+;/PRODUCT_BUNDLE_IDENTIFIER = $base_bundle_id.tests;/g" "$project_file"
    
    # Also fix any remaining corrupted patterns with hardcoded bundle IDs
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com\.twinklub\.twinklub\.[^;]*;/PRODUCT_BUNDLE_IDENTIFIER = $base_bundle_id;/g" "$project_file"
    
    # Fix any hardcoded test bundle identifiers
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com\.twinklub\.twinklub\.tests;/PRODUCT_BUNDLE_IDENTIFIER = $base_bundle_id.tests;/g" "$project_file"
    
    log_success "✅ Bundle identifiers fixed"
    
    # Verify the fix
    log_info "🔍 Verifying bundle identifier fix..."
    local corrupted_count
    corrupted_count=$(grep -c "framework\.[0-9]+\.[0-9]+\.framework\.[0-9]+\.[0-9]+" "$project_file" || echo "0")
    
    if [ "$corrupted_count" -eq 0 ]; then
        log_success "✅ No corrupted bundle identifiers found"
        
        # Verify that bundle IDs are using the correct base
        local main_app_count
        local test_count
        main_app_count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $base_bundle_id;" "$project_file" || echo "0")
        test_count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $base_bundle_id.tests;" "$project_file" || echo "0")
        
        log_info "📊 Bundle identifier summary:"
        log_info "   - Main app targets: $main_app_count (using $base_bundle_id)"
        log_info "   - Test targets: $test_count (using $base_bundle_id.tests)"
        
        return 0
    else
        log_error "❌ Still found $corrupted_count corrupted bundle identifiers"
        log_info "🔄 Restoring from backup..."
        cp "$backup_path" "$project_file"
        return 1
    fi
}

# Function to validate bundle identifiers
validate_bundle_ids() {
    local project_file="ios/Runner.xcodeproj/project.pbxproj"
    
    log_info "🔍 Validating bundle identifiers..."
    
    # Extract all bundle identifiers
    local bundle_ids
    bundle_ids=$(grep "PRODUCT_BUNDLE_IDENTIFIER" "$project_file" | sed 's/.*PRODUCT_BUNDLE_IDENTIFIER = \([^;]*\);.*/\1/')
    
    # Check for duplicates
    local duplicates
    duplicates=$(echo "$bundle_ids" | sort | uniq -d)
    
    if [ -n "$duplicates" ]; then
        log_error "❌ Duplicate bundle identifiers found:"
        echo "$duplicates" | while read -r dup; do
            log_error "   - $dup"
        done
        return 1
    else
        log_success "✅ All bundle identifiers are unique"
        return 0
    fi
}

# Function to display current bundle identifiers
display_bundle_ids() {
    local project_file="ios/Runner.xcodeproj/project.pbxproj"
    
    log_info "📋 Current bundle identifiers:"
    grep "PRODUCT_BUNDLE_IDENTIFIER" "$project_file" | while read -r line; do
        local bundle_id
        bundle_id=$(echo "$line" | sed 's/.*PRODUCT_BUNDLE_IDENTIFIER = \([^;]*\);.*/\1/')
        log_info "   - $bundle_id"
    done
}

# Main function
main() {
    log_info "=== Bundle Identifier Fix Process ==="
    
    # Display current state
    log_info "📋 Current bundle identifiers:"
    display_bundle_ids
    
    # Fix corrupted bundle identifiers
    if fix_corrupted_bundle_ids; then
        log_success "✅ Bundle identifiers fixed successfully"
        
        # Validate the fix
        if validate_bundle_ids; then
            log_success "✅ Bundle identifier validation passed"
            
            # Display final state
            log_info "📋 Final bundle identifiers:"
            display_bundle_ids
            
            return 0
        else
            log_error "❌ Bundle identifier validation failed"
            return 1
        fi
    else
        log_error "❌ Failed to fix bundle identifiers"
        return 1
    fi
}

# Run main function
main "$@" 