#!/bin/bash

# Script Encoding Fix for iOS Workflow
# Purpose: Fix BOM characters, line endings, and permissions for all shell scripts
# Author: AI Assistant
# Version: 1.0

set -euo pipefail

log_info() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1"; }
log_success() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $1"; }
log_warn() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $1"; }
log_error() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1"; }

log_info "🔧 Starting Script Encoding Fix for iOS Workflow..."

# Function to check if dos2unix is available
check_dos2unix() {
    if command -v dos2unix >/dev/null 2>&1; then
        return 0
    else
        log_warn "dos2unix not found, installing..."
        if command -v brew >/dev/null 2>&1; then
            brew install dos2unix
        elif command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update && sudo apt-get install -y dos2unix
        else
            log_error "Cannot install dos2unix automatically. Please install it manually."
            return 1
        fi
    fi
}

# Function to fix BOM characters
fix_bom_characters() {
    log_info "🧹 Removing BOM characters from shell scripts..."
    
    local fixed_count=0
    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            # Check if file has BOM
            if head -c 3 "$file" | od -t x1 | grep -q "ef bb bf"; then
                log_info "Removing BOM from: $file"
                # Remove BOM using sed
                sed -i '1s/^\xEF\xBB\xBF//' "$file"
                fixed_count=$((fixed_count + 1))
            fi
        fi
    done < <(find . -name "*.sh" -type f -print0)
    
    log_success "✅ Removed BOM from $fixed_count files"
}

# Function to fix line endings
fix_line_endings() {
    log_info "🔄 Converting line endings to Unix format..."
    
    if check_dos2unix; then
        # Use dos2unix if available
        find . -name "*.sh" -type f -exec dos2unix {} \;
        log_success "✅ Converted line endings using dos2unix"
    else
        # Fallback to sed for line ending conversion
        log_info "Using sed fallback for line ending conversion..."
        find . -name "*.sh" -type f -exec sed -i 's/\r$//' {} \;
        log_success "✅ Converted line endings using sed"
    fi
}

# Function to fix shebang lines
fix_shebang_lines() {
    log_info "🔧 Fixing shebang lines..."
    
    local fixed_count=0
    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            # Check if first line is a valid shebang
            local first_line
            first_line=$(head -n 1 "$file" 2>/dev/null || echo "")
            
            if [[ "$first_line" =~ ^#!.*bash ]]; then
                # Shebang looks good
                continue
            elif [[ "$first_line" =~ ^.*#!/bin/bash ]]; then
                # Has hidden characters before shebang
                log_info "Fixing shebang in: $file"
                sed -i '1s/^[^#]*#!/#!/' "$file"
                fixed_count=$((fixed_count + 1))
            elif [[ ! "$first_line" =~ ^#! ]]; then
                # No shebang at all
                log_info "Adding shebang to: $file"
                echo '#!/bin/bash' | cat - "$file" > temp && mv temp "$file"
                fixed_count=$((fixed_count + 1))
            fi
        fi
    done < <(find . -name "*.sh" -type f -print0)
    
    log_success "✅ Fixed shebang in $fixed_count files"
}

# Function to set proper permissions
set_script_permissions() {
    log_info "🔐 Setting executable permissions for shell scripts..."
    
    local script_count=0
    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            chmod +x "$file"
            script_count=$((script_count + 1))
        fi
    done < <(find . -name "*.sh" -type f -print0)
    
    log_success "✅ Set executable permissions for $script_count scripts"
}

# Function to validate script syntax
validate_script_syntax() {
    log_info "🔍 Validating script syntax..."
    
    local valid_count=0
    local invalid_count=0
    
    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            if bash -n "$file" 2>/dev/null; then
                valid_count=$((valid_count + 1))
            else
                log_warn "Syntax error in: $file"
                invalid_count=$((invalid_count + 1))
            fi
        fi
    done < <(find . -name "*.sh" -type f -print0)
    
    if [ "$invalid_count" -eq 0 ]; then
        log_success "✅ All $valid_count scripts have valid syntax"
    else
        log_warn "⚠️ Found $invalid_count scripts with syntax errors"
    fi
}

# Function to create backup
create_backup() {
    log_info "💾 Creating backup of original scripts..."
    
    local backup_dir="script_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    find . -name "*.sh" -type f -exec cp --parents {} "$backup_dir" \;
    
    log_success "✅ Backup created in: $backup_dir"
}

# Main execution
main() {
    log_info "🚀 Starting comprehensive script encoding fix..."
    
    # Create backup first
    create_backup
    
    # Fix BOM characters
    fix_bom_characters
    
    # Fix line endings
    fix_line_endings
    
    # Fix shebang lines
    fix_shebang_lines
    
    # Set permissions
    set_script_permissions
    
    # Validate syntax
    validate_script_syntax
    
    log_success "🎉 Script encoding fix completed successfully!"
    log_info "📋 Summary:"
    log_info "   - BOM characters removed"
    log_info "   - Line endings converted to Unix format"
    log_info "   - Shebang lines fixed"
    log_info "   - Executable permissions set"
    log_info "   - Syntax validation completed"
}

# Run main function
main "$@" 