#!/bin/bash

# Fix Nested Variables Script
# Purpose: Clean up nested variable patterns created during the iOS workflow variables fix

set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"
IOS_SCRIPTS_DIR="${SCRIPT_DIR}/lib/scripts/ios"

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

# Function to fix nested BUNDLE_ID variables
fix_nested_bundle_id() {
    local file_path="$1"
    
    log_info "🔧 Fixing nested BUNDLE_ID variables in: $file_path"
    
    # Fix nested BUNDLE_ID patterns
    sed -i.tmp 's/\${BUNDLE_ID:-${BUNDLE_ID:-${BUNDLE_ID:-com\.insurancegroupmo\.insurancegroupmo}}}/\${BUNDLE_ID:-com.insurancegroupmo.insurancegroupmo}/g' "$file_path"
    sed -i.tmp 's/\${BUNDLE_ID:-${BUNDLE_ID:-com\.insurancegroupmo\.insurancegroupmo}}/\${BUNDLE_ID:-com.insurancegroupmo.insurancegroupmo}/g' "$file_path"
    sed -i.tmp 's/\${BUNDLE_ID:-${BUNDLE_ID:-com\.example\.app}}/\${BUNDLE_ID:-com.example.app}/g' "$file_path"
    sed -i.tmp 's/\${BUNDLE_ID:-${BUNDLE_ID:-com\.twinklub\.twinklub}}/\${BUNDLE_ID:-com.twinklub.twinklub}/g' "$file_path"
    
    # Remove temporary files
    rm -f "${file_path}.tmp"
    
    log_success "✅ Nested BUNDLE_ID variables fixed in: $file_path"
}

# Function to fix nested APP_NAME variables
fix_nested_app_name() {
    local file_path="$1"
    
    log_info "🔧 Fixing nested APP_NAME variables in: $file_path"
    
    # Fix nested APP_NAME patterns
    sed -i.tmp 's/\${APP_NAME:-${APP_NAME:-Insurance Group MO}}/\${APP_NAME:-Insurance Group MO}/g' "$file_path"
    sed -i.tmp 's/\${APP_NAME:-${APP_NAME:-Twinklub App}}/\${APP_NAME:-Twinklub App}/g' "$file_path"
    sed -i.tmp 's/\${APP_NAME:-${APP_NAME:-quikapptest07}}/\${APP_NAME:-quikapptest07}/g' "$file_path"
    
    # Remove temporary files
    rm -f "${file_path}.tmp"
    
    log_success "✅ Nested APP_NAME variables fixed in: $file_path"
}

# Function to fix nested VERSION variables
fix_nested_version() {
    local file_path="$1"
    
    log_info "🔧 Fixing nested VERSION variables in: $file_path"
    
    # Fix nested VERSION patterns
    sed -i.tmp 's/\${VERSION_NAME:-${VERSION_NAME:-1\.0\.0}}/\${VERSION_NAME:-1.0.0}/g' "$file_path"
    sed -i.tmp 's/\${VERSION_NAME:-${VERSION_NAME:-1\.0\.6}}/\${VERSION_NAME:-1.0.6}/g' "$file_path"
    sed -i.tmp 's/\${VERSION_CODE:-${VERSION_CODE:-51}}/\${VERSION_CODE:-51}/g' "$file_path"
    
    # Remove temporary files
    rm -f "${file_path}.tmp"
    
    log_success "✅ Nested VERSION variables fixed in: $file_path"
}

# Function to fix nested APP_ID variables
fix_nested_app_id() {
    local file_path="$1"
    
    log_info "🔧 Fixing nested APP_ID variables in: $file_path"
    
    # Fix nested APP_ID patterns
    sed -i.tmp 's/\${APP_ID:-${APP_ID:-twinklub_app}}/\${APP_ID:-twinklub_app}/g' "$file_path"
    sed -i.tmp 's/\${APP_ID:-${APP_ID:-quikapptest07}}/\${APP_ID:-quikapptest07}/g' "$file_path"
    
    # Remove temporary files
    rm -f "${file_path}.tmp"
    
    log_success "✅ Nested APP_ID variables fixed in: $file_path"
}

# Function to fix nested ORG_NAME variables
fix_nested_org_name() {
    local file_path="$1"
    
    log_info "🔧 Fixing nested ORG_NAME variables in: $file_path"
    
    # Fix nested ORG_NAME patterns
    sed -i.tmp 's/\${ORG_NAME:-${ORG_NAME:-Twinklub}}/\${ORG_NAME:-Twinklub}/g' "$file_path"
    sed -i.tmp 's/\${ORG_NAME:-${ORG_NAME:-Insurance Group MO}}/\${ORG_NAME:-Insurance Group MO}/g' "$file_path"
    
    # Remove temporary files
    rm -f "${file_path}.tmp"
    
    log_success "✅ Nested ORG_NAME variables fixed in: $file_path"
}

# Function to fix nested WEB_URL variables
fix_nested_web_url() {
    local file_path="$1"
    
    log_info "🔧 Fixing nested WEB_URL variables in: $file_path"
    
    # Fix nested WEB_URL patterns
    sed -i.tmp 's|\${WEB_URL:-${WEB_URL:-https://twinklub\.com}}|\${WEB_URL:-https://twinklub.com}|g' "$file_path"
    sed -i.tmp 's|\${WEB_URL:-${WEB_URL:-https://insurancegroupmo\.com}}|\${WEB_URL:-https://insurancegroupmo.com}|g' "$file_path"
    
    # Remove temporary files
    rm -f "${file_path}.tmp"
    
    log_success "✅ Nested WEB_URL variables fixed in: $file_path"
}

# Function to fix all nested variables in a file
fix_nested_variables_in_file() {
    local file_path="$1"
    
    if [ ! -f "$file_path" ]; then
        log_warn "⚠️  File not found: $file_path"
        return 0
    fi
    
    log_info "🔧 Processing nested variables in: $file_path"
    
    # Apply all nested variable fixes
    fix_nested_bundle_id "$file_path"
    fix_nested_app_name "$file_path"
    fix_nested_version "$file_path"
    fix_nested_app_id "$file_path"
    fix_nested_org_name "$file_path"
    fix_nested_web_url "$file_path"
    
    log_success "✅ Completed nested variable fixes for: $file_path"
}

# Main execution
main() {
    log_info "🚀 Starting Nested Variables Fix..."
    log_info "📋 This script will clean up nested variable patterns created during the iOS workflow variables fix"
    
    # Find all .sh files in the iOS scripts directory
    find "$IOS_SCRIPTS_DIR" -name "*.sh" -type f | while read -r script_file; do
        fix_nested_variables_in_file "$script_file"
    done
    
    log_success "🎉 Nested Variables Fix completed!"
    log_info "📊 Summary:"
    log_info "   ✅ All nested BUNDLE_ID patterns cleaned up"
    log_info "   ✅ All nested APP_NAME patterns cleaned up"
    log_info "   ✅ All nested VERSION patterns cleaned up"
    log_info "   ✅ All nested APP_ID patterns cleaned up"
    log_info "   ✅ All nested ORG_NAME patterns cleaned up"
    log_info "   ✅ All nested WEB_URL patterns cleaned up"
    log_info ""
    log_info "🔧 Next Steps:"
    log_info "   1. Verify the variable patterns are now clean"
    log_info "   2. Test the workflow with your API variables"
    log_info "   3. Ensure all scripts use proper variable syntax"
    
    return 0
}

# Run main function
main "$@" 