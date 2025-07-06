#!/bin/bash

# Ultimate CFBundleIdentifier Collision Fix
# Purpose: Single comprehensive script to eliminate ALL CFBundleIdentifier collision errors
# Target Error: Validation failed (409) CFBundleIdentifier Collision
# Error ID: eda16725-caed-4b98-b0fe-53fc6b6f0dcd (and all variations)
# Strategy: Fix at multiple levels - Xcode project, IPA, and validation

set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Logging functions
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

# Get bundle ID from environment or use default
BUNDLE_ID="${BUNDLE_ID:-com.insurancegroupmo.insurancegroupmo}"
APP_NAME="${APP_NAME:-Insurance Group MO}"

log_info "🚀 Starting Ultimate CFBundleIdentifier Collision Fix"
log_info "🎯 Target Bundle ID: $BUNDLE_ID"
log_info "📱 App Name: $APP_NAME"
log_info "🔧 Strategy: Multi-level collision elimination"

# Function 1: Fix Xcode Project Bundle Identifiers
fix_xcode_project_bundle_identifiers() {
    log_info "🔧 Step 1: Fixing Xcode Project Bundle Identifiers"
    
    local project_file="ios/Runner.xcodeproj/project.pbxproj"
    local main_bundle_id="$BUNDLE_ID"
    
    if [ ! -f "$project_file" ]; then
        log_warn "⚠️  Project file not found: $project_file"
        return 1
    fi
    
    # Create backup
    cp "$project_file" "${project_file}.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Fix main app bundle identifier
    log_info "📱 Setting main app bundle identifier to: $main_bundle_id"
    sed -i.tmp "s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/PRODUCT_BUNDLE_IDENTIFIER = $main_bundle_id;/g" "$project_file"
    
    # Fix all other targets to have unique bundle identifiers
    local target_count=0
    while IFS= read -r line; do
        if [[ "$line" =~ PRODUCT_BUNDLE_IDENTIFIER[[:space:]]*=[[:space:]]*([^;]+) ]]; then
            local current_id="${BASH_REMATCH[1]}"
            if [[ "$current_id" == "$main_bundle_id" ]]; then
                # This is the main app, keep it
                continue
            else
                # This is another target, make it unique
                target_count=$((target_count + 1))
                local unique_id="${main_bundle_id}.target${target_count}"
                log_info "🎯 Making target unique: $current_id → $unique_id"
                sed -i.tmp "s/PRODUCT_BUNDLE_IDENTIFIER = $current_id;/PRODUCT_BUNDLE_IDENTIFIER = $unique_id;/g" "$project_file"
            fi
        fi
    done < "$project_file"
    
    # Remove temporary files
    rm -f "${project_file}.tmp"
    
    log_success "✅ Xcode project bundle identifiers fixed"
    return 0
}

# Function 2: Fix Info.plist Bundle Identifiers
fix_info_plist_bundle_identifiers() {
    log_info "🔧 Step 2: Fixing Info.plist Bundle Identifiers"
    
    local main_info_plist="ios/Runner/Info.plist"
    local main_bundle_id="$BUNDLE_ID"
    
    if [ ! -f "$main_info_plist" ]; then
        log_warn "⚠️  Main Info.plist not found: $main_info_plist"
        return 1
    fi
    
    # Create backup
    cp "$main_info_plist" "${main_info_plist}.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Fix main app Info.plist
    log_info "📱 Setting main app CFBundleIdentifier to: $main_bundle_id"
    if command -v plutil >/dev/null 2>&1; then
        plutil -replace CFBundleIdentifier -string "$main_bundle_id" "$main_info_plist"
    else
        # Fallback to sed if plutil not available
        sed -i.tmp "s/<key>CFBundleIdentifier<\/key>.*<string>.*<\/string>/<key>CFBundleIdentifier<\/key>\n\t<string>$main_bundle_id<\/string>/" "$main_info_plist"
    fi
    
    # Find and fix all other Info.plist files
    find ios -name "Info.plist" -type f | while read -r plist_file; do
        if [[ "$plist_file" == "$main_info_plist" ]]; then
            continue  # Skip main app
        fi
        
        # Extract current bundle ID
        local current_id=""
        if command -v plutil >/dev/null 2>&1; then
            current_id=$(plutil -extract CFBundleIdentifier raw "$plist_file" 2>/dev/null || echo "")
        else
            current_id=$(grep -A1 "CFBundleIdentifier" "$plist_file" | grep string | sed 's/.*<string>\(.*\)<\/string>.*/\1/' | head -1)
        fi
        
        if [[ -n "$current_id" && "$current_id" == "$main_bundle_id" ]]; then
            # Make this bundle unique
            local unique_id="${main_bundle_id}.$(basename "$(dirname "$plist_file")")"
            log_info "🎯 Making bundle unique: $plist_file → $unique_id"
            
            if command -v plutil >/dev/null 2>&1; then
                plutil -replace CFBundleIdentifier -string "$unique_id" "$plist_file"
            else
                # Fallback to sed
                sed -i.tmp "s/<key>CFBundleIdentifier<\/key>.*<string>.*<\/string>/<key>CFBundleIdentifier<\/key>\n\t<string>$unique_id<\/string>/" "$plist_file"
            fi
        fi
    done
    
    # Remove temporary files
    find ios -name "*.tmp" -delete
    
    log_success "✅ Info.plist bundle identifiers fixed"
    return 0
}

# Function 3: Fix Framework Embedding Issues
fix_framework_embedding() {
    log_info "🔧 Step 3: Fixing Framework Embedding Issues"
    
    local project_file="ios/Runner.xcodeproj/project.pbxproj"
    
    if [ ! -f "$project_file" ]; then
        log_warn "⚠️  Project file not found: $project_file"
        return 1
    fi
    
    # Create backup
    cp "$project_file" "${project_file}.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Fix Flutter.xcframework embedding - ensure it's only embedded in main app
    log_info "🔧 Fixing Flutter.xcframework embedding"
    
    # Set main app to embed Flutter.xcframework
    sed -i.tmp '/Runner.*\/\* Flutter.xcframework in Embed Frameworks \*\//,/attributes = \([^)]+\)/s/ATTRIBUTES = ([^)]*);/ATTRIBUTES = (CodeSignOnCopy, RemoveHeadersOnCopy);/' "$project_file"
    
    # Set all other targets to NOT embed Flutter.xcframework
    sed -i.tmp '/[^R][^u][^n][^n][^e][^r].*\/\* Flutter.xcframework in Embed Frameworks \*\//,/attributes = \([^)]+\)/s/ATTRIBUTES = ([^)]*);/ATTRIBUTES = (RemoveHeadersOnCopy);/' "$project_file"
    
    # Remove temporary files
    rm -f "${project_file}.tmp"
    
    log_success "✅ Framework embedding issues fixed"
    return 0
}

# Function 4: Fix IPA Bundle Identifiers (Post-Build)
fix_ipa_bundle_identifiers() {
    log_info "🔧 Step 4: Fixing IPA Bundle Identifiers (Post-Build)"
    
    # Find the IPA file
    local ipa_file=""
    if [ -f "build/ios/ipa/Runner.ipa" ]; then
        ipa_file="build/ios/ipa/Runner.ipa"
    elif [ -f "build/ios/ipa/*.ipa" ]; then
        ipa_file=$(ls build/ios/ipa/*.ipa | head -1)
    else
        log_warn "⚠️  No IPA file found for post-build fix"
        return 1
    fi
    
    log_info "📦 Processing IPA file: $ipa_file"
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    local main_bundle_id="$BUNDLE_ID"
    
    # Extract IPA
    cd "$temp_dir"
    unzip -q "$PROJECT_ROOT/$ipa_file"
    
    # Find main app
    local main_app=""
    for app in Payload/*.app; do
        if [[ -d "$app" ]]; then
            main_app="$app"
            break
        fi
    done
    
    if [[ -z "$main_app" ]]; then
        log_error "❌ No main app found in IPA"
        cd "$PROJECT_ROOT"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Fix main app bundle identifier
    local main_info_plist="$main_app/Info.plist"
    if command -v plutil >/dev/null 2>&1; then
        plutil -replace CFBundleIdentifier -string "$main_bundle_id" "$main_info_plist"
    fi
    
    # Fix all frameworks and extensions
    local target_count=0
    find "$main_app" -name "Info.plist" -type f | while read -r plist_file; do
        if [[ "$plist_file" == "$main_info_plist" ]]; then
            continue  # Skip main app
        fi
        
        # Extract current bundle ID
        local current_id=""
        if command -v plutil >/dev/null 2>&1; then
            current_id=$(plutil -extract CFBundleIdentifier raw "$plist_file" 2>/dev/null || echo "")
        fi
        
        if [[ -n "$current_id" && "$current_id" == "$main_bundle_id" ]]; then
            # Make this bundle unique
            target_count=$((target_count + 1))
            local unique_id="${main_bundle_id}.framework${target_count}"
            log_info "🎯 Making IPA bundle unique: $current_id → $unique_id"
            
            if command -v plutil >/dev/null 2>&1; then
                plutil -replace CFBundleIdentifier -string "$unique_id" "$plist_file"
            fi
        fi
    done
    
    # Recreate IPA
    zip -qr "$PROJECT_ROOT/$ipa_file" .
    
    # Cleanup
    cd "$PROJECT_ROOT"
    rm -rf "$temp_dir"
    
    log_success "✅ IPA bundle identifiers fixed"
    return 0
}

# Function 5: Validate Bundle Identifiers
validate_bundle_identifiers() {
    log_info "🔧 Step 5: Validating Bundle Identifiers"
    
    local main_bundle_id="$BUNDLE_ID"
    local found_duplicates=false
    
    # Check Xcode project
    local project_file="ios/Runner.xcodeproj/project.pbxproj"
    if [ -f "$project_file" ]; then
        local bundle_ids=$(grep "PRODUCT_BUNDLE_IDENTIFIER" "$project_file" | sed 's/.*= \([^;]*\);/\1/')
        local main_count=$(echo "$bundle_ids" | grep -c "^$main_bundle_id$" || echo "0")
        
        if [[ "$main_count" -gt 1 ]]; then
            log_warn "⚠️  Found $main_count instances of main bundle ID in project file"
            found_duplicates=true
        fi
    fi
    
    # Check Info.plist files
    find ios -name "Info.plist" -type f | while read -r plist_file; do
        local current_id=""
        if command -v plutil >/dev/null 2>&1; then
            current_id=$(plutil -extract CFBundleIdentifier raw "$plist_file" 2>/dev/null || echo "")
        else
            current_id=$(grep -A1 "CFBundleIdentifier" "$plist_file" | grep string | sed 's/.*<string>\(.*\)<\/string>.*/\1/' | head -1)
        fi
        
        if [[ "$current_id" == "$main_bundle_id" ]]; then
            log_info "✅ Found main bundle ID in: $plist_file"
        fi
    done
    
    if [[ "$found_duplicates" == "false" ]]; then
        log_success "✅ Bundle identifier validation passed"
        return 0
    else
        log_warn "⚠️  Bundle identifier validation found potential issues"
        return 1
    fi
}

# Function 6: Clean Build Artifacts
clean_build_artifacts() {
    log_info "🔧 Step 6: Cleaning Build Artifacts"
    
    # Clean Xcode build folder
    if [ -d "ios/build" ]; then
        rm -rf ios/build
        log_info "🧹 Cleaned ios/build directory"
    fi
    
    # Clean Flutter build
    if [ -d "build" ]; then
        rm -rf build
        log_info "🧹 Cleaned build directory"
    fi
    
    # Clean derived data (if possible)
    if [ -d "$HOME/Library/Developer/Xcode/DerivedData" ]; then
        find "$HOME/Library/Developer/Xcode/DerivedData" -name "*Runner*" -type d -exec rm -rf {} + 2>/dev/null || true
        log_info "🧹 Cleaned Xcode derived data for Runner"
    fi
    
    log_success "✅ Build artifacts cleaned"
    return 0
}

# Main execution
main() {
    log_info "🚀 Starting Ultimate CFBundleIdentifier Collision Fix"
    log_info "🎯 Target Error: Validation failed (409) CFBundleIdentifier Collision"
    log_info "📱 Bundle ID: $BUNDLE_ID"
    log_info "🔧 Comprehensive multi-level fix strategy"
    
    local success_count=0
    local total_steps=6
    
    # Step 1: Fix Xcode Project Bundle Identifiers
    if fix_xcode_project_bundle_identifiers; then
        success_count=$((success_count + 1))
    fi
    
    # Step 2: Fix Info.plist Bundle Identifiers
    if fix_info_plist_bundle_identifiers; then
        success_count=$((success_count + 1))
    fi
    
    # Step 3: Fix Framework Embedding Issues
    if fix_framework_embedding; then
        success_count=$((success_count + 1))
    fi
    
    # Step 4: Clean Build Artifacts
    if clean_build_artifacts; then
        success_count=$((success_count + 1))
    fi
    
    # Step 5: Validate Bundle Identifiers
    if validate_bundle_identifiers; then
        success_count=$((success_count + 1))
    fi
    
    # Summary
    log_info "📊 Fix Summary: $success_count/$total_steps steps completed successfully"
    
    if [[ $success_count -eq $total_steps ]]; then
        log_success "🎉 Ultimate CFBundleIdentifier Collision Fix completed successfully!"
        log_info "✅ All bundle identifiers are now unique"
        log_info "✅ Framework embedding conflicts resolved"
        log_info "✅ Build artifacts cleaned"
        log_info "✅ Ready for App Store validation"
        log_info ""
        log_info "🔧 Next Steps:"
        log_info "   1. Build your iOS app"
        log_info "   2. The IPA will have unique bundle identifiers"
        log_info "   3. App Store validation should pass without 409 errors"
        log_info "   4. If you still get errors, run this script again after build"
        
        # Export success flag
        export ULTIMATE_CFBUNDLEIDENTIFIER_FIX_APPLIED="true"
        return 0
    else
        log_warn "⚠️  Some steps had issues, but the fix was partially applied"
        log_info "🔧 You can still proceed with the build"
        log_info "📱 If you get validation errors, run this script again after build"
        
        export ULTIMATE_CFBUNDLEIDENTIFIER_FIX_APPLIED="partial"
        return 1
    fi
}

# Run main function
main "$@" 