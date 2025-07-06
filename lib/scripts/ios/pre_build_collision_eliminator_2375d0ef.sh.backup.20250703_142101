#!/bin/bash

# Pre-Build Collision Elimination for Error ID: 2375d0ef-7f95-4a0d-b424-9782f5092cd1
# Purpose: Prevent CFBundleIdentifier collisions before build starts
# Error: CFBundleIdentifier Collision. There is more than one bundle with the CFBundleIdentifier value 'com.insurancegroupmo.insurancegroupmo' under the iOS application 'Runner.app'.

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

log_info "🎯 2375D0EF Pre-Build Collision Elimination Starting..."
log_info "🎯 Target Error ID: 2375d0ef-7f95-4a0d-b424-9782f5092cd1"
log_info "⚠️  Issue: Multiple bundles with same CFBundleIdentifier 'com.insurancegroupmo.insurancegroupmo'"
log_info "🔧 Strategy: Bundle-ID-Rules compliant unique bundle assignment"

# Function to analyze current bundle identifiers
analyze_bundle_identifiers() {
    log_info "🔍 Analyzing current bundle identifiers in Xcode project..."
    
    local project_file="ios/Runner.xcodeproj/project.pbxproj"
    
    if [ ! -f "$project_file" ]; then
        log_error "❌ Xcode project file not found: $project_file"
        return 1
    fi
    
    # Extract all bundle identifiers
    local bundle_ids
    bundle_ids=$(grep -o "PRODUCT_BUNDLE_IDENTIFIER = [^;]*;" "$project_file" | sed 's/PRODUCT_BUNDLE_IDENTIFIER = //g' | sed 's/;//g' | sort | uniq)
    
    log_info "📋 Current Bundle Identifiers Found:"
    echo "$bundle_ids" | while read -r bundle_id; do
        if [ -n "$bundle_id" ]; then
            local count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $bundle_id;" "$project_file")
            log_info "   $bundle_id (used $count times)"
        fi
    done
    
    # Check for duplicates
    local duplicates
    duplicates=$(echo "$bundle_ids" | while read -r bundle_id; do
        if [ -n "$bundle_id" ]; then
            local count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $bundle_id;" "$project_file")
            if [ "$count" -gt 1 ]; then
                echo "$bundle_id"
            fi
        fi
    done)
    
    if [ -n "$duplicates" ]; then
        log_warn "⚠️ Found duplicate bundle identifiers:"
        echo "$duplicates" | while read -r dup; do
            log_warn "   $dup"
        done
        return 1
    else
        log_success "✅ No duplicate bundle identifiers found"
        return 0
    fi
}

# Function to identify target types and assign unique bundle IDs
assign_unique_bundle_identifiers() {
    log_info "🔧 Assigning unique bundle identifiers using Bundle-ID-Rules..."
    
    local project_file="ios/Runner.xcodeproj/project.pbxproj"
    local base_bundle_id="${BUNDLE_ID:-com.insurancegroupmo.insurancegroupmo}"
    
    # Create backup
    cp "$project_file" "${project_file}.2375d0ef_backup_$(date +%Y%m%d_%H%M%S)"
    
    log_info "📱 Base Bundle ID: $base_bundle_id"
    
    # Define target type patterns and their suffixes
    declare -A target_patterns=(
        ["RunnerTests"]=".tests"
        ["WidgetExtension"]=".widget"
        ["NotificationServiceExtension"]=".notificationservice"
        ["AppExtension"]=".extension"
        ["Framework"]=".framework"
        ["WatchKitApp"]=".watchkitapp"
        ["WatchKitExtension"]=".watchkitextension"
        ["Component"]=".component"
        ["Library"]=".library"
        ["Plugin"]=".plugin"
    )
    
    # Process each target type
    for target_pattern in "${!target_patterns[@]}"; do
        local suffix="${target_patterns[$target_pattern]}"
        local new_bundle_id="${base_bundle_id}${suffix}"
        
        log_info "🎯 Processing $target_pattern targets with suffix: $suffix"
        
        # Find and update bundle identifiers for this target type
        # Look for build configurations that contain the target pattern
        local updated=false
        
        # Method 1: Update by target name pattern
        if grep -q "$target_pattern" "$project_file"; then
            # Find build configurations for this target
            local target_sections
            target_sections=$(awk -v pattern="$target_pattern" '
                /^[[:space:]]*[A-Z0-9A-F]{24}[[:space:]]*\/\*[[:space:]]*.*'$target_pattern'.*[[:space:]]*\*\/[[:space:]]*=/ {
                    print $1
                }
            ' "$project_file")
            
            if [ -n "$target_sections" ]; then
                echo "$target_sections" | while read -r section_id; do
                    if [ -n "$section_id" ]; then
                        log_info "   🔧 Updating section $section_id for $target_pattern"
                        
                        # Update bundle identifier in this section
                        sed -i.bak "/$section_id/,/};/{
                            s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/PRODUCT_BUNDLE_IDENTIFIER = $new_bundle_id;/g
                        }" "$project_file"
                        
                        updated=true
                    fi
                done
            fi
        fi
        
        # Method 2: Update by PRODUCT_NAME pattern
        if ! $updated; then
            if grep -q "PRODUCT_NAME = $target_pattern" "$project_file"; then
                log_info "   🔧 Updating by PRODUCT_NAME pattern for $target_pattern"
                
                # Update bundle identifiers in sections with this PRODUCT_NAME
                sed -i.bak "/PRODUCT_NAME = $target_pattern/,/};/{
                    s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/PRODUCT_BUNDLE_IDENTIFIER = $new_bundle_id;/g
                }" "$project_file"
                
                updated=true
            fi
        fi
        
        # Method 3: Update by TARGETED_DEVICE_FAMILY patterns for specific targets
        if ! $updated; then
            case "$target_pattern" in
                "WatchKitApp")
                    if grep -q "TARGETED_DEVICE_FAMILY = 4" "$project_file"; then
                        log_info "   🔧 Updating Watch app targets"
                        sed -i.bak "/TARGETED_DEVICE_FAMILY = 4/,/};/{
                            s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/PRODUCT_BUNDLE_IDENTIFIER = $new_bundle_id;/g
                        }" "$project_file"
                        updated=true
                    fi
                    ;;
                "WidgetExtension")
                    if grep -q "INFOPLIST_KEY_NSExtension" "$project_file"; then
                        log_info "   🔧 Updating widget extension targets"
                        sed -i.bak "/INFOPLIST_KEY_NSExtension/,/};/{
                            s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/PRODUCT_BUNDLE_IDENTIFIER = $new_bundle_id;/g
                        }" "$project_file"
                        updated=true
                    fi
                    ;;
            esac
        fi
        
        if $updated; then
            log_success "   ✅ Updated $target_pattern targets to: $new_bundle_id"
        else
            log_info "   ℹ️  No $target_pattern targets found"
        fi
    done
    
    # Clean up backup files
    rm -f "${project_file}.bak"
    
    log_success "✅ Bundle identifier assignment completed"
}

# Function to validate framework embedding settings
fix_framework_embedding() {
    log_info "🔧 Fixing framework embedding to prevent collisions..."
    
    local project_file="ios/Runner.xcodeproj/project.pbxproj"
    
    # Ensure main app keeps framework embedding, but extensions don't embed the same frameworks
    log_info "📱 Setting main app to embed frameworks, extensions to 'Do Not Embed'"
    
    # Find main app target (usually the first target that's not a test)
    local main_app_sections
    main_app_sections=$(awk '
        /^[[:space:]]*[A-Z0-9A-F]{24}[[:space:]]*\/\*[[:space:]]*Runner[[:space:]]*\*\/[[:space:]]*=/ {
            print $1
        }
    ' "$project_file")
    
    if [ -n "$main_app_sections" ]; then
        echo "$main_app_sections" | while read -r section_id; do
            if [ -n "$section_id" ]; then
                log_info "   🔧 Ensuring main app $section_id embeds frameworks"
                
                # Set main app to embed frameworks
                sed -i.bak "/$section_id/,/};/{
                    s/FRAMEWORK_SEARCH_PATHS = [^;]*;/FRAMEWORK_SEARCH_PATHS = \"\$(inherited)\";/g
                    s/ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = [^;]*;/ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES;/g
                }" "$project_file"
            fi
        done
    fi
    
    # Find extension targets and set them to not embed frameworks
    local extension_patterns=("WidgetExtension" "NotificationServiceExtension" "AppExtension" "WatchKitExtension")
    
    for pattern in "${extension_patterns[@]}"; do
        local extension_sections
        extension_sections=$(awk -v pattern="$pattern" '
            /^[[:space:]]*[A-Z0-9A-F]{24}[[:space:]]*\/\*[[:space:]]*.*'$pattern'.*[[:space:]]*\*\/[[:space:]]*=/ {
                print $1
            }
        ' "$project_file")
        
        if [ -n "$extension_sections" ]; then
            echo "$extension_sections" | while read -r section_id; do
                if [ -n "$section_id" ]; then
                    log_info "   🔧 Setting extension $section_id to not embed frameworks"
                    
                    # Set extensions to not embed frameworks
                    sed -i.bak "/$section_id/,/};/{
                        s/ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = [^;]*;/ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = NO;/g
                    }" "$project_file"
                fi
            done
        fi
    done
    
    # Clean up backup files
    rm -f "${project_file}.bak"
    
    log_success "✅ Framework embedding settings updated"
}

# Function to verify the fixes
verify_collision_prevention() {
    log_info "🔍 Verifying collision prevention measures..."
    
    local project_file="ios/Runner.xcodeproj/project.pbxproj"
    local base_bundle_id="${BUNDLE_ID:-com.insurancegroupmo.insurancegroupmo}"
    
    # Check for remaining duplicates
    local duplicates
    duplicates=$(grep -o "PRODUCT_BUNDLE_IDENTIFIER = [^;]*;" "$project_file" | sed 's/PRODUCT_BUNDLE_IDENTIFIER = //g' | sed 's/;//g' | sort | uniq -d)
    
    if [ -n "$duplicates" ]; then
        log_error "❌ Still found duplicate bundle identifiers:"
        echo "$duplicates" | while read -r dup; do
            log_error "   $dup"
        done
        return 1
    fi
    
    # Verify unique bundle identifiers were assigned
    local unique_bundle_ids
    unique_bundle_ids=$(grep -o "PRODUCT_BUNDLE_IDENTIFIER = [^;]*;" "$project_file" | sed 's/PRODUCT_BUNDLE_IDENTIFIER = //g' | sed 's/;//g' | sort | uniq)
    
    log_success "✅ Bundle identifier verification completed"
    log_info "📋 Final Bundle Identifiers:"
    echo "$unique_bundle_ids" | while read -r bundle_id; do
        if [ -n "$bundle_id" ]; then
            local count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $bundle_id;" "$project_file")
            log_info "   $bundle_id (used $count times)"
        fi
    done
    
    # Verify main app still has the base bundle ID
    if grep -q "PRODUCT_BUNDLE_IDENTIFIER = $base_bundle_id;" "$project_file"; then
        log_success "✅ Main app retains base bundle ID: $base_bundle_id"
    else
        log_warn "⚠️ Main app bundle ID was changed from base: $base_bundle_id"
    fi
    
    return 0
}

# Main execution function
main() {
    log_info "🚀 Starting 2375D0EF collision elimination..."
    
    # Step 1: Analyze current bundle identifiers
    if ! analyze_bundle_identifiers; then
        log_warn "⚠️ Found existing duplicates, will fix them"
    fi
    
    # Step 2: Assign unique bundle identifiers
    if ! assign_unique_bundle_identifiers; then
        log_error "❌ Failed to assign unique bundle identifiers"
        return 1
    fi
    
    # Step 3: Fix framework embedding
    if ! fix_framework_embedding; then
        log_warn "⚠️ Framework embedding fix had issues, but continuing"
    fi
    
    # Step 4: Verify the fixes
    if ! verify_collision_prevention; then
        log_error "❌ Collision prevention verification failed"
        return 1
    fi
    
    log_success "✅ 2375D0EF Pre-Build Collision Elimination completed successfully!"
    log_info "🎯 Error ID 2375d0ef-7f95-4a0d-b424-9782f5092cd1 PREVENTED"
    log_info "📋 Bundle-ID-Rules compliant naming applied"
    log_info "🔧 Framework embedding conflicts resolved"
    
    # Export status for main workflow
    export C2375D0EF_PREVENTION_APPLIED="true"
    
    return 0
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 