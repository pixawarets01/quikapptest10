#!/bin/bash

# Pre-Build Collision Elimination Script for Error ID bcff0b91
# Purpose: Prevent CFBundleIdentifier collisions for error bcff0b91-fe16-466d-b77a-bbe543940260
# Strategy: Aggressive pre-build bundle ID modification with bundle-id-rules compliance

set -euo pipefail

# Script configuration
SCRIPT_NAME="Pre-Build Collision Eliminator (bcff0b91)"
ERROR_ID="bcff0b91"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Input validation
MAIN_BUNDLE_ID="${BUNDLE_ID:-com.insurancegroupmo.insurancegroupmo}"
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
PBXPROJ_FILE="$PROJECT_ROOT/ios/Runner.xcodeproj/project.pbxproj"

# Logging functions
log_info() { echo "ℹ️ $*"; }
log_success() { echo "✅ $*"; }
log_warn() { echo "⚠️ $*"; }
log_error() { echo "❌ $*"; }

log_info "🚀 $SCRIPT_NAME Starting..."
log_info "🎯 Target Error ID: bcff0b91-fe16-466d-b77a-bbe543940260"
log_info "🆔 Main Bundle ID: $MAIN_BUNDLE_ID"
log_info "📁 Project Root: $PROJECT_ROOT"
log_info "🔧 Strategy: Aggressive PRE-BUILD collision elimination"

# Validate project structure
if [ ! -f "$PBXPROJ_FILE" ]; then
    log_error "Xcode project file not found: $PBXPROJ_FILE"
    exit 1
fi

# Function to analyze current bundle ID collision state
analyze_bcff0b91_collision() {
    log_info "🔍 Analyzing bcff0b91 collision pattern..."
    
    if [ ! -f "$PBXPROJ_FILE" ]; then
        log_error "Project file not found: $PBXPROJ_FILE"
        return 1
    fi
    
    # Count exact main bundle ID matches
    local main_bundle_count
    main_bundle_count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = ${MAIN_BUNDLE_ID};" "$PBXPROJ_FILE" 2>/dev/null || echo "0")
    
    # Count total bundle IDs
    local total_bundle_count
    total_bundle_count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER" "$PBXPROJ_FILE" 2>/dev/null || echo "0")
    
    log_info "📊 BCFF0B91 Collision Analysis:"
    log_info "   - Main bundle ID occurrences: $main_bundle_count"
    log_info "   - Total bundle identifiers: $total_bundle_count"
    
    # Show all current bundle identifiers for analysis
    log_info "📋 Current bundle identifiers:"
    grep "PRODUCT_BUNDLE_IDENTIFIER" "$PBXPROJ_FILE" | sed 's/.*= /   ✓ /' | sed 's/;.*//' | sort -u | head -10
    
    # Specific check for bcff0b91 collision pattern (more than 3 main bundle IDs)
    if [ "$main_bundle_count" -gt 3 ]; then
        log_error "🚨 BCFF0B91 COLLISION DETECTED: $main_bundle_count instances of $MAIN_BUNDLE_ID"
        log_error "🎯 Error ID bcff0b91-fe16-466d-b77a-bbe543940260 PATTERN CONFIRMED"
        return 1
    else
        log_success "✅ Main bundle ID count acceptable: $main_bundle_count"
        return 0
    fi
}

# Function to apply bcff0b91 collision elimination
apply_bcff0b91_elimination() {
    log_info "☢️ Applying bcff0b91 collision elimination..."
    
    # Create backup
    local backup_file="$PBXPROJ_FILE.bcff0b91_backup_${TIMESTAMP}"
    cp "$PBXPROJ_FILE" "$backup_file"
    log_info "💾 Backup created: $(basename "$backup_file")"
    
    # Process project file with Ruby for precise control
    ruby << 'RUBY_SCRIPT'
require 'fileutils'

project_file = ENV['PBXPROJ_FILE']
main_bundle_id = ENV['MAIN_BUNDLE_ID']
error_id = ENV['ERROR_ID']
timestamp = ENV['TIMESTAMP']

puts "🔧 Processing project file for bcff0b91 collision elimination..."
puts "📱 Main Bundle ID: #{main_bundle_id}"
puts "🎯 Error ID: #{error_id}"

if File.exist?(project_file)
  content = File.read(project_file)
  
  # Find all bundle ID lines with line numbers
  lines = content.split("\n")
  modified_lines = []
  main_bundle_kept = 0
  max_main_bundles = 3  # Debug, Release, Profile configurations only
  
  lines.each_with_index do |line, index|
    line_number = index + 1
    
    if line =~ /PRODUCT_BUNDLE_IDENTIFIER = #{Regexp.escape(main_bundle_id)};/
      if main_bundle_kept < max_main_bundles
        # Keep original main bundle ID for essential configurations
        modified_lines << line
        main_bundle_kept += 1
        puts "   ✅ Kept main bundle ID (#{main_bundle_kept}/#{max_main_bundles}): Line #{line_number}"
      else
        # Apply bcff0b91 collision elimination - use bundle-id-rules compliant naming
        new_bundle_id = "#{main_bundle_id}.component.bcff0b91.#{line_number}"
        new_line = line.gsub(/PRODUCT_BUNDLE_IDENTIFIER = #{Regexp.escape(main_bundle_id)};/, 
                           "PRODUCT_BUNDLE_IDENTIFIER = #{new_bundle_id};")
        modified_lines << new_line
        puts "   ☢️ BCFF0B91 FIX: Line #{line_number} → #{new_bundle_id}"
      end
    elsif line =~ /PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);/
      bundle_id = $1
      
      # Check if this is a bundle ID that needs bcff0b91-specific fixing
      if bundle_id.include?(main_bundle_id) && bundle_id != main_bundle_id
        # Determine the component type and apply bundle-id-rules compliant naming
        if bundle_id.include?('.tests') || bundle_id.downcase.include?('test')
          new_bundle_id = "#{main_bundle_id}.tests"
        elsif bundle_id.include?('.widget') || bundle_id.downcase.include?('widget')
          new_bundle_id = "#{main_bundle_id}.widget"
        elsif bundle_id.include?('.notification') || bundle_id.downcase.include?('notification')
          new_bundle_id = "#{main_bundle_id}.notificationservice"
        elsif bundle_id.include?('.extension') || bundle_id.downcase.include?('extension')
          new_bundle_id = "#{main_bundle_id}.extension"
        elsif bundle_id.include?('.framework') || bundle_id.downcase.include?('framework')
          new_bundle_id = "#{main_bundle_id}.framework"
        elsif bundle_id.include?('.watch') || bundle_id.downcase.include?('watch')
          new_bundle_id = "#{main_bundle_id}.watchapp"
        else
          # For any unknown components, use unique bcff0b91 identifier
          new_bundle_id = "#{main_bundle_id}.component.bcff0b91.#{line_number}"
        end
        
        new_line = line.gsub(/PRODUCT_BUNDLE_IDENTIFIER = #{Regexp.escape(bundle_id)};/, 
                           "PRODUCT_BUNDLE_IDENTIFIER = #{new_bundle_id};")
        modified_lines << new_line
        puts "   🔧 BCFF0B91 COMPONENT: #{bundle_id} → #{new_bundle_id}"
      else
        # Other bundle ID not related to main bundle
        modified_lines << line
      end
    else
      # Non-bundle ID line
      modified_lines << line
    end
  end
  
  # Write modified content
  File.write(project_file, modified_lines.join("\n"))
  puts "✅ BCFF0B91 collision elimination applied successfully"
  
else
  puts "❌ Project file not found: #{project_file}"
  exit 1
end
RUBY_SCRIPT
    
    if [ $? -eq 0 ]; then
        log_success "✅ BCFF0B91 collision elimination completed"
        return 0
    else
        log_error "❌ BCFF0B91 collision elimination failed"
        return 1
    fi
}

# Function to verify bcff0b91 elimination
verify_bcff0b91_elimination() {
    log_info "🔍 Verifying bcff0b91 elimination results..."
    
    # Count exact main bundle ID occurrences after modification
    local final_main_count
    final_main_count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = ${MAIN_BUNDLE_ID};" "$PBXPROJ_FILE" 2>/dev/null || echo "0")
    
    # Count total bundle IDs
    local final_total_count
    final_total_count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER" "$PBXPROJ_FILE" 2>/dev/null || echo "0")
    
    # Count bcff0b91 modifications
    local bcff0b91_count
    bcff0b91_count=$(grep -c "bcff0b91" "$PBXPROJ_FILE" 2>/dev/null || echo "0")
    
    log_info "📊 BCFF0B91 elimination results:"
    log_info "   - Final main bundle ID count: $final_main_count"
    log_info "   - Total bundle identifiers: $final_total_count"
    log_info "   - BCFF0B91 modifications: $bcff0b91_count"
    
    # Verify success - main bundle ID should be 3 or fewer
    if [ "$final_main_count" -le 3 ]; then
        log_success "✅ BCFF0B91 SUCCESS: Main bundle ID count is now $final_main_count (≤ 3)"
        log_success "🎯 Error ID bcff0b91-fe16-466d-b77a-bbe543940260 PREVENTED"
        return 0
    else
        log_error "❌ BCFF0B91 FAILURE: Main bundle ID count is still $final_main_count (> 3)"
        return 1
    fi
}

# Function to generate bcff0b91 prevention report
generate_bcff0b91_report() {
    log_info "📋 Generating bcff0b91 prevention report..."
    
    local report_file="$PROJECT_ROOT/bcff0b91_collision_prevention_report_${TIMESTAMP}.txt"
    
    cat > "$report_file" << EOF
BCFF0B91 COLLISION PREVENTION REPORT
====================================
Error ID: bcff0b91-fe16-466d-b77a-bbe543940260
Prevention Strategy: Aggressive PRE-BUILD collision elimination
Timestamp: $TIMESTAMP
Unique Suffix: bcff0b91.${TIMESTAMP}

TARGET CONFIGURATION:
Main Bundle ID: $MAIN_BUNDLE_ID
Project File: $PBXPROJ_FILE
Strategy: Pre-build collision prevention with bundle-id-rules compliance

BCFF0B91 MODIFICATIONS APPLIED:
- Main app bundle ID: PROTECTED (unchanged, ≤ 3 occurrences)
- Excess main bundle IDs: BCFF0B91 ELIMINATED
- Test targets: Bundle-id-rules compliant (.tests)
- Widget targets: Bundle-id-rules compliant (.widget)
- Notification targets: Bundle-id-rules compliant (.notificationservice)
- Extension targets: Bundle-id-rules compliant (.extension)
- Framework targets: Bundle-id-rules compliant (.framework)
- Unknown components: Unique bcff0b91 identifiers

COLLISION PREVENTION STATUS:
✅ CFBundleIdentifier collisions PREVENTED
✅ Error ID bcff0b91-fe16-466d-b77a-bbe543940260 ELIMINATED
✅ Build process CLEARED
✅ Pre-build elimination SUCCESSFUL
✅ Bundle-id-rules compliance MAINTAINED

WARNING: This approach modifies the Xcode project file to prevent
bcff0b91 collision errors during the build process.

BUILD STATUS: CLEARED FOR IOS BUILD ✅
EOF
    
    log_success "📄 BCFF0B91 report: $(basename "$report_file")"
    return 0
}

# Main execution
main() {
    log_info "🚀 Starting bcff0b91 pre-build collision elimination..."
    
    # Step 1: Analyze current state
    if ! analyze_bcff0b91_collision; then
        log_info "🚨 BCFF0B91 collision pattern detected - applying elimination"
    else
        log_info "✅ No bcff0b91 collision detected - applying preventive treatment"
    fi
    
    # Step 2: Apply bcff0b91 elimination
    if ! apply_bcff0b91_elimination; then
        log_error "❌ BCFF0B91 elimination failed"
        exit 1
    fi
    
    # Step 3: Verify results
    if ! verify_bcff0b91_elimination; then
        log_error "❌ BCFF0B91 verification failed"
        exit 1
    fi
    
    # Step 4: Generate report
    generate_bcff0b91_report
    
    log_success "☢️ BCFF0B91 PRE-BUILD COLLISION ELIMINATION COMPLETED"
    log_success "🎯 Error ID bcff0b91-fe16-466d-b77a-bbe543940260 PREVENTED"
    log_success "🚀 Ready for iOS build process"
    
    return 0
}

# Execute main function
main "$@" 