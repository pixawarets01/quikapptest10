#!/bin/bash

# Framework Validation Script
# Purpose: Validate framework embedding to prevent CFBundleIdentifier collisions

set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

log_info "🔧 Starting Framework Validation..."

# Check Xcode project configuration
validate_xcode_project() {
    local project_file="ios/Runner.xcodeproj/project.pbxproj"
    
    if [ ! -f "$project_file" ]; then
        log_error "❌ Xcode project file not found: $project_file"
        return 1
    fi
    
    log_info "📱 Analyzing Xcode project configuration..."
    
    # Check Flutter.xcframework references
    local flutter_refs
    flutter_refs=$(grep -c "Flutter\.xcframework" "$project_file" 2>/dev/null || echo "0")
    
    log_info "🔍 Flutter.xcframework references: $flutter_refs"
    
    if [ "$flutter_refs" -gt 3 ]; then
        log_warn "⚠️ Many Flutter.xcframework references found ($flutter_refs)"
        log_warn "🔧 This may indicate framework embedding conflicts"
    fi
    
    # Check for extension targets
    local extensions
    extensions=$(grep -c "\.extension\|\.widget\|\.notificationservice" "$project_file" 2>/dev/null || echo "0")
    
    if [ "$extensions" -gt 0 ]; then
        log_info "📦 Extension targets found: $extensions"
        
        # Check for embedding issues
        local embed_issues
        embed_issues=$(grep -A 5 -B 5 "\.extension\|\.widget\|\.notificationservice" "$project_file" | grep -c "Embed & Sign" 2>/dev/null || echo "0")
        
        if [ "$embed_issues" -gt 0 ]; then
            log_warn "⚠️ Extension targets may have 'Embed & Sign' enabled"
            log_warn "💡 Recommend setting to 'Do Not Embed' to prevent collisions"
        else
            log_success "✅ Extension targets properly configured"
        fi
    fi
    
    return 0
}

# Check for framework embedding collision fix
check_collision_fix_availability() {
    log_info "🛡️ Checking collision prevention availability..."
    
    if [ -f "${SCRIPT_DIR}/framework_embedding_collision_fix.sh" ]; then
        log_success "✅ Framework embedding collision fix available"
        return 0
    else
        log_warn "⚠️ Framework embedding collision fix script missing"
        log_info "💡 Consider implementing framework_embedding_collision_fix.sh"
        return 1
    fi
}

# Recommend framework configuration
recommend_framework_config() {
    log_info "📋 Framework Configuration Recommendations:"
    log_info "  1. Main app target: Embed & Sign for Flutter.xcframework"
    log_info "  2. Extension targets: Do Not Embed for Flutter.xcframework"
    log_info "  3. Test targets: Do Not Embed for Flutter.xcframework"
    log_info "  4. Use framework embedding collision fix for automation"
    
    return 0
}

# Main validation
main() {
    log_info "🚀 Framework Validation Starting..."
    
    validate_xcode_project
    check_collision_fix_availability
    recommend_framework_config
    
    log_success "✅ Framework validation complete"
    return 0
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi 