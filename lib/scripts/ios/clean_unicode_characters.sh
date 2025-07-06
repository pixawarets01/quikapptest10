#!/bin/bash

# Clean Unicode Characters from iOS Project Files
# Purpose: Remove Unicode characters that cause CocoaPods parsing errors

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

log_info "🧹 Cleaning Unicode characters from iOS project files..."

# Function to clean Unicode characters from a file
clean_unicode_from_file() {
    local file_path="$1"
    local backup_path="${file_path}.unicode_backup_$(date +%s)"
    
    if [ ! -f "$file_path" ]; then
        log_warn "⚠️ File not found: $file_path"
        return 0
    fi
    
    log_info "🔍 Checking for Unicode characters in: $file_path"
    
    # Check if file contains Unicode characters
    if grep -q -P '[\x80-\xFF]' "$file_path" 2>/dev/null; then
        log_warn "⚠️ Unicode characters detected in $file_path"
        
        # Create backup
        cp "$file_path" "$backup_path"
        log_info "📦 Backup created: $backup_path"
        
        # Remove Unicode characters (keep only ASCII)
        # This removes emojis and other non-ASCII characters
        sed -i '' 's/[^\x00-\x7F]//g' "$file_path"
        
        log_success "✅ Unicode characters removed from $file_path"
        
        # Verify the fix
        if grep -q -P '[\x80-\xFF]' "$file_path" 2>/dev/null; then
            log_error "❌ Unicode characters still present after cleaning"
            log_info "🔄 Restoring from backup..."
            cp "$backup_path" "$file_path"
            return 1
        else
            log_success "✅ Unicode characters successfully removed from $file_path"
            return 0
        fi
    else
        log_info "✅ No Unicode characters found in $file_path"
        return 0
    fi
}

# Function to clean specific Unicode patterns
clean_specific_unicode_patterns() {
    local file_path="$1"
    
    if [ ! -f "$file_path" ]; then
        return 0
    fi
    
    log_info "🔧 Cleaning specific Unicode patterns in: $file_path"
    
    # Remove specific Unicode patterns that we know cause issues
    # Remove emoji wrench (🔧) and other common Unicode characters
    sed -i '' 's/🔧//g' "$file_path"
    sed -i '' 's/✅//g' "$file_path"
    sed -i '' 's/❌//g' "$file_path"
    sed -i '' 's/⚠️//g' "$file_path"
    sed -i '' 's/🚀//g' "$file_path"
    sed -i '' 's/📦//g' "$file_path"
    sed -i '' 's/🔍//g' "$file_path"
    sed -i '' 's/🧹//g' "$file_path"
    sed -i '' 's/📋//g' "$file_path"
    sed -i '' 's/🎯//g' "$file_path"
    sed -i '' 's/🔐//g' "$file_path"
    sed -i '' 's/📱//g' "$file_path"
    sed -i '' 's/🔄//g' "$file_path"
    sed -i '' 's/💡//g' "$file_path"
    sed -i '' 's/📝//g' "$file_path"
    sed -i '' 's/🔧//g' "$file_path"
    
    log_success "✅ Specific Unicode patterns cleaned from $file_path"
}

# Main cleaning function
main() {
    log_info "=== Unicode Character Cleaning Process ==="
    
    # Files to clean
    local files_to_clean=(
        "ios/Runner.xcodeproj/project.pbxproj"
        "ios/Podfile"
        "ios/Podfile.lock"
    )
    
    local cleaned_count=0
    local error_count=0
    
    for file_path in "${files_to_clean[@]}"; do
        if [ -f "$file_path" ]; then
            log_info "Processing: $file_path"
            
            # First, clean specific patterns
            if clean_specific_unicode_patterns "$file_path"; then
                # Then, do general Unicode cleaning
                if clean_unicode_from_file "$file_path"; then
                    ((cleaned_count++))
                else
                    ((error_count++))
                fi
            else
                ((error_count++))
            fi
        else
            log_warn "⚠️ File not found: $file_path"
        fi
    done
    
    # Summary
    log_info "=== Unicode Cleaning Summary ==="
    log_info "✅ Successfully cleaned: $cleaned_count files"
    if [ $error_count -gt 0 ]; then
        log_warn "⚠️ Errors encountered: $error_count files"
        return 1
    else
        log_success "🎉 All files cleaned successfully!"
        return 0
    fi
}

# Run main function
main "$@" 