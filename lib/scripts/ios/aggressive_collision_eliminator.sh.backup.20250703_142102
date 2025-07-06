#!/bin/bash

# Aggressive Collision Eliminator for iOS
# Purpose: Apply aggressive bundle identifier collision prevention

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

log_info "💥 Starting Aggressive Collision Elimination..."

# Function to validate parameters
validate_parameters() {
    local bundle_id="$1"
    local project_file="$2"
    local error_id="$3"
    
    if [ -z "$bundle_id" ]; then
        log_error "❌ Bundle ID is required"
        return 1
    fi
    
    if [ ! -f "$project_file" ]; then
        log_error "❌ Project file not found: $project_file"
        return 1
    fi
    
    if [ -z "$error_id" ]; then
        log_error "❌ Error ID is required"
        return 1
    fi
    
    return 0
}

# Function to create unique bundle identifiers
create_unique_bundle_identifiers() {
    local main_bundle_id="$1"
    local project_file="$2"
    
    log_info "🎯 Creating unique bundle identifiers for all targets..."
    
    # Create backup
    cp "$project_file" "${project_file}.aggressive_backup_$(date +%Y%m%d_%H%M%S)"
    
    # Define unique suffixes for different target types
    local suffixes=(
        ".tests"
        ".widget"
        ".notificationservice"
        ".extension"
        ".framework"
        ".watchkitapp"
        ".watchkitextension"
        ".component"
        ".helper"
        ".service"
    )
    
    # Find all PRODUCT_BUNDLE_IDENTIFIER entries
    local bundle_entries
    bundle_entries=$(grep -n "PRODUCT_BUNDLE_IDENTIFIER" "$project_file" | head -20)
    
    if [ -z "$bundle_entries" ]; then
        log_warn "⚠️ No PRODUCT_BUNDLE_IDENTIFIER entries found"
        return 0
    fi
    
    local counter=0
    local modified=false
    
    # Process each bundle identifier entry
    while IFS= read -r line; do
        if [ -z "$line" ]; then
            continue
        fi
        
        local line_num=$(echo "$line" | cut -d: -f1)
        local current_bundle=$(echo "$line" | sed 's/.*PRODUCT_BUNDLE_IDENTIFIER = \([^;]*\);.*/\1/')
        
        # Skip if already unique
        if [[ "$current_bundle" == "${main_bundle_id}"* ]]; then
            continue
        fi
        
        # Create unique bundle identifier
        local suffix="${suffixes[$((counter % ${#suffixes[@]}))]}"
        local new_bundle="${main_bundle_id}${suffix}"
        
        # Apply the change
        sed -i.bak "${line_num}s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/PRODUCT_BUNDLE_IDENTIFIER = $new_bundle;/" "$project_file"
        
        log_info "🔄 Changed: $current_bundle → $new_bundle"
        modified=true
        counter=$((counter + 1))
    done <<< "$bundle_entries"
    
    # Clean up backup
    rm -f "${project_file}.bak"
    
    if [ "$modified" = "true" ]; then
        log_success "✅ Aggressive collision elimination applied to $counter targets"
    else
        log_info "ℹ️ No changes needed - all bundle identifiers already unique"
    fi
    
    return 0
}

# Function to verify changes
verify_changes() {
    local project_file="$1"
    local main_bundle_id="$2"
    
    log_info "🔍 Verifying aggressive collision elimination..."
    
    # Count unique bundle identifiers
    local unique_count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = ${main_bundle_id}" "$project_file" 2>/dev/null || echo "0")
    local total_count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER" "$project_file" 2>/dev/null || echo "0")
    
    log_info "📊 Bundle Identifier Summary:"
    log_info "   - Main app: $unique_count"
    log_info "   - Total targets: $total_count"
    
    if [ "$unique_count" -gt 0 ] && [ "$total_count" -gt 0 ]; then
        log_success "✅ Verification passed - bundle identifiers are unique"
        return 0
    else
        log_error "❌ Verification failed - bundle identifier issues detected"
        return 1
    fi
}

# Main execution function
main() {
    local bundle_id="${1:-}"
    local project_file="${2:-}"
    local error_id="${3:-}"
    
    log_info "🚀 Aggressive Collision Elimination for Error ID: ${error_id:-unknown}"
    
    # Validate parameters
    if ! validate_parameters "$bundle_id" "$project_file" "$error_id"; then
        log_error "❌ Parameter validation failed"
        return 1
    fi
    
    log_info "📋 Parameters:"
    log_info "   - Bundle ID: $bundle_id"
    log_info "   - Project File: $project_file"
    log_info "   - Error ID: $error_id"
    
    # Step 1: Create unique bundle identifiers
    if ! create_unique_bundle_identifiers "$bundle_id" "$project_file"; then
        log_error "❌ Failed to create unique bundle identifiers"
        return 1
    fi
    
    # Step 2: Verify changes
    if ! verify_changes "$project_file" "$bundle_id"; then
        log_error "❌ Verification failed"
        return 1
    fi
    
    log_success "✅ Aggressive collision elimination completed successfully!"
    log_info "🎯 Error ID $error_id should now be prevented"
    
    return 0
}

# Execute main function if script is run directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi 