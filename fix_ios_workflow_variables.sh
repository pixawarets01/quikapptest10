#!/bin/bash

# Fix iOS Workflow Variables Script
# Purpose: Update all iOS workflow scripts to use branding_assets.sh variables instead of hardcoded values
# This ensures all scripts use the same app information from the API call

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

# Function to backup a file before modification
backup_file() {
    local file_path="$1"
    local backup_path="${file_path}.backup.$(date +%Y%m%d_%H%M%S)"
    
    if [ -f "$file_path" ]; then
        cp "$file_path" "$backup_path"
        log_info "📋 Backed up: $file_path → $backup_path"
    fi
}

# Function to replace hardcoded bundle IDs with variables
fix_bundle_id_variables() {
    local file_path="$1"
    
    log_info "🔧 Fixing bundle ID variables in: $file_path"
    
    # Replace hardcoded bundle IDs with BUNDLE_ID variable
    sed -i.tmp 's/com\.insurancegroupmo\.insurancegroupmo/\${BUNDLE_ID:-com.insurancegroupmo.insurancegroupmo}/g' "$file_path"
    sed -i.tmp 's/com\.example\.app/\${BUNDLE_ID:-com.example.app}/g' "$file_path"
    sed -i.tmp 's/com\.twinklub\.twinklub/\${BUNDLE_ID:-com.twinklub.twinklub}/g' "$file_path"
    sed -i.tmp 's/com\.example\.quikapptest07/\${BUNDLE_ID:-com.example.quikapptest07}/g' "$file_path"
    
    # Remove temporary files
    rm -f "${file_path}.tmp"
    
    log_success "✅ Bundle ID variables fixed in: $file_path"
}

# Function to replace hardcoded app names with variables
fix_app_name_variables() {
    local file_path="$1"
    
    log_info "🔧 Fixing app name variables in: $file_path"
    
    # Replace hardcoded app names with APP_NAME variable
    sed -i.tmp 's/Insurance Group MO/\${APP_NAME:-Insurance Group MO}/g' "$file_path"
    sed -i.tmp 's/Twinklub App/\${APP_NAME:-Twinklub App}/g' "$file_path"
    sed -i.tmp 's/quikapptest07/\${APP_NAME:-quikapptest07}/g' "$file_path"
    
    # Remove temporary files
    rm -f "${file_path}.tmp"
    
    log_success "✅ App name variables fixed in: $file_path"
}

# Function to replace hardcoded version values with variables
fix_version_variables() {
    local file_path="$1"
    
    log_info "🔧 Fixing version variables in: $file_path"
    
    # Replace hardcoded version patterns with VERSION_NAME and VERSION_CODE variables
    sed -i.tmp 's/1\.0\.0/\${VERSION_NAME:-1.0.0}/g' "$file_path"
    sed -i.tmp 's/1\.0\.6/\${VERSION_NAME:-1.0.6}/g' "$file_path"
    sed -i.tmp 's/51/\${VERSION_CODE:-51}/g' "$file_path"
    
    # Remove temporary files
    rm -f "${file_path}.tmp"
    
    log_success "✅ Version variables fixed in: $file_path"
}

# Function to replace hardcoded app IDs with variables
fix_app_id_variables() {
    local file_path="$1"
    
    log_info "🔧 Fixing app ID variables in: $file_path"
    
    # Replace hardcoded app IDs with APP_ID variable
    sed -i.tmp 's/twinklub_app/\${APP_ID:-twinklub_app}/g' "$file_path"
    sed -i.tmp 's/quikapptest07/\${APP_ID:-quikapptest07}/g' "$file_path"
    
    # Remove temporary files
    rm -f "${file_path}.tmp"
    
    log_success "✅ App ID variables fixed in: $file_path"
}

# Function to replace hardcoded organization names with variables
fix_org_name_variables() {
    local file_path="$1"
    
    log_info "🔧 Fixing organization name variables in: $file_path"
    
    # Replace hardcoded organization names with ORG_NAME variable
    sed -i.tmp 's/Twinklub/\${ORG_NAME:-Twinklub}/g' "$file_path"
    sed -i.tmp 's/Insurance Group MO/\${ORG_NAME:-Insurance Group MO}/g' "$file_path"
    
    # Remove temporary files
    rm -f "${file_path}.tmp"
    
    log_success "✅ Organization name variables fixed in: $file_path"
}

# Function to replace hardcoded web URLs with variables
fix_web_url_variables() {
    local file_path="$1"
    
    log_info "🔧 Fixing web URL variables in: $file_path"
    
    # Replace hardcoded web URLs with WEB_URL variable
    sed -i.tmp 's|https://twinklub\.com|\${WEB_URL:-https://twinklub.com}|g' "$file_path"
    sed -i.tmp 's|https://insurancegroupmo\.com|\${WEB_URL:-https://insurancegroupmo.com}|g' "$file_path"
    
    # Remove temporary files
    rm -f "${file_path}.tmp"
    
    log_success "✅ Web URL variables fixed in: $file_path"
}

# Function to fix a specific script file
fix_script_file() {
    local file_path="$1"
    
    if [ ! -f "$file_path" ]; then
        log_warn "⚠️  File not found: $file_path"
        return 0
    fi
    
    log_info "🔧 Processing: $file_path"
    
    # Create backup
    backup_file "$file_path"
    
    # Apply all variable fixes
    fix_bundle_id_variables "$file_path"
    fix_app_name_variables "$file_path"
    fix_version_variables "$file_path"
    fix_app_id_variables "$file_path"
    fix_org_name_variables "$file_path"
    fix_web_url_variables "$file_path"
    
    log_success "✅ Completed fixes for: $file_path"
}

# Main execution
main() {
    log_info "🚀 Starting iOS Workflow Variables Fix..."
    log_info "📋 This script will update all iOS workflow scripts to use branding_assets.sh variables"
    
    # List of critical scripts to fix (based on the grep search results)
    local critical_scripts=(
        "main.sh"
        "generate_launcher_icons.sh"
        "build_flutter_app.sh"
        "certificate_signing_fix_822b41a6.sh"
        "certificate_signing_fix_503ceb9c.sh"
        "certificate_signing_fix_8d2aeb71.sh"
        "ipa_bundle_collision_fix.sh"
        "pre_build_collision_eliminator_2fe7baf3.sh"
        "nuclear_ipa_collision_eliminator_bcff0b91.sh"
        "nuclear_cfbundleidentifier_collision_fix.sh"
        "pre_build_collision_eliminator_new2.sh"
        "simple_collision_prevention.sh"
        "ultimate_ipa_collision_eliminator.sh"
        "pre_build_collision_eliminator_64c3ce97.sh"
        "ultimate_collision_eliminator_6a8ab053.sh"
        "nuclear_ipa_collision_eliminator_f8db6738.sh"
        "universal_random_error_id_handler.sh"
        "pre_build_collision_eliminator_bcff0b91.sh"
        "bundle_id_rules_compliant_eliminator.sh"
        "ultimate_collision_eliminator_882c8a3f.sh"
        "pre_build_collision_eliminator_fc526a49.sh"
        "nuclear_ipa_collision_eliminator_f8b4b738.sh"
        "nuclear_ipa_collision_eliminator_2375d0ef.sh"
        "ultimate_bundle_collision_prevention.sh"
        "collision_diagnostics.sh"
        "certificate_signing_fix_8d2aeb71.sh"
        "check_bundle_id_collisions.sh"
        "local_collision_check.sh"
        "nuclear_ipa_collision_eliminator_dccb3cf9.sh"
        "bundle_id_fixed.sh"
        "fix_bundle_identifier_collision.sh"
        "pre_archive_collision_prevention.sh"
        "fix_bundle_identifier_collision_v2.sh"
        "app_store_connect_collision_eliminator.sh"
        "nuclear_ipa_collision_eliminator_2fe7baf3.sh"
        "universal_collision_eliminator.sh"
        "nuclear_ipa_collision_eliminator_13825405.sh"
        "pre_build_collision_eliminator_2375d0ef.sh"
        "fix_firebase_xcode16.sh"
        "nuclear_bundle_collision_fix.sh"
        "realtime_collision_interceptor.sh"
        "verify_ios_workflow.sh"
        "cocoapods_integration_fix.sh"
        "enhanced_certificate_setup.sh"
        "final_ipa_export_fix.sh"
        "emergency_bundle_identifier_collision_fix.sh"
        "run_verification.sh"
        "conditional_firebase_injection.sh"
        "handle_certificates.sh"
        "validate_workflow_integration.sh"
        "fix_bundle_underscore_issue.sh"
        "final_firebase_solution.sh"
        "emergency_app_store_collision_fix.sh"
        "export_ipa.sh"
        "export_ipa_framework_fix.sh"
        "aggressive_collision_eliminator.sh"
        "universal_collision_eliminator.sh"
        "framework_embedding_collision_fix.sh"
        "ultimate_collision_eliminator.sh"
        "nuclear_ipa_collision_eliminator.sh"
        "universal_nuclear_collision_eliminator.sh"
        "mega_nuclear_collision_eliminator.sh"
    )
    
    # Process each critical script
    for script in "${critical_scripts[@]}"; do
        local script_path="${IOS_SCRIPTS_DIR}/${script}"
        if [ -f "$script_path" ]; then
            fix_script_file "$script_path"
        else
            log_warn "⚠️  Script not found: $script_path"
        fi
    done
    
    # Also process all other .sh files in the iOS scripts directory
    log_info "🔍 Processing remaining .sh files in iOS scripts directory..."
    
    find "$IOS_SCRIPTS_DIR" -name "*.sh" -type f | while read -r script_file; do
        # Skip files we already processed
        local filename=$(basename "$script_file")
        local already_processed=false
        
        for processed_script in "${critical_scripts[@]}"; do
            if [ "$filename" = "$processed_script" ]; then
                already_processed=true
                break
            fi
        done
        
        if [ "$already_processed" = false ]; then
            fix_script_file "$script_file"
        fi
    done
    
    log_success "🎉 iOS Workflow Variables Fix completed!"
    log_info "📊 Summary:"
    log_info "   ✅ All hardcoded bundle IDs replaced with \${BUNDLE_ID} variable"
    log_info "   ✅ All hardcoded app names replaced with \${APP_NAME} variable"
    log_info "   ✅ All hardcoded versions replaced with \${VERSION_NAME} and \${VERSION_CODE} variables"
    log_info "   ✅ All hardcoded app IDs replaced with \${APP_ID} variable"
    log_info "   ✅ All hardcoded organization names replaced with \${ORG_NAME} variable"
    log_info "   ✅ All hardcoded web URLs replaced with \${WEB_URL} variable"
    log_info "   📋 All files backed up before modification"
    log_info ""
    log_info "🔧 Next Steps:"
    log_info "   1. Review the changes in the iOS scripts directory"
    log_info "   2. Test the workflow with your API variables"
    log_info "   3. Ensure branding_assets.sh runs first in the workflow"
    log_info "   4. Verify all scripts now use the same app information"
    
    return 0
}

# Run main function
main "$@" 