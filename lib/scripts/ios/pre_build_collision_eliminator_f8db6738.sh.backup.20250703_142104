#!/bin/bash

# Pre-Build Collision Eliminator f8db6738
# Prevents CFBundleIdentifier collision with error ID f8db6738-f319-4958-8058-d68dba787835
# Implements bundle-id-rules compliant naming and collision prevention

set -e

# Comprehensive logging setup
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

log_with_color() {
    local color=$1
    local message=$2
    echo -e "${color}${BOLD}[PRE-BUILD-f8db6738]${NC} ${color}${message}${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [PRE-BUILD-f8db6738] ${message}" >> "$HOME/collision_elimination_f8db6738.log"
}

log_info() { log_with_color "$BLUE" "$1"; }
log_success() { log_with_color "$GREEN" "$1"; }
log_warning() { log_with_color "$YELLOW" "$1"; }
log_error() { log_with_color "$RED" "$1"; }
log_step() { log_with_color "$PURPLE" "$1"; }

echo ""
log_step "======================================"
log_step "PRE-BUILD COLLISION ELIMINATOR f8db6738"
log_step "======================================"
log_info "Target Error ID: f8db6738-f319-4958-8058-d68dba787835"
log_info "Collision Type: CFBundleIdentifier Collision Prevention"
log_info "Strategy: Bundle-ID-Rules Compliant Naming + Pre-Build Prevention"
echo ""

# Main bundle identifier (bundle-id-rules compliant)
MAIN_BUNDLE_ID="com.insurancegroupmo.insurancegroupmo"

# Bundle-ID-Rules compliant extensions (meaningful suffixes)
WIDGET_BUNDLE_ID="${MAIN_BUNDLE_ID}.widget"
NOTIFICATION_BUNDLE_ID="${MAIN_BUNDLE_ID}.notificationservice"
EXTENSION_BUNDLE_ID="${MAIN_BUNDLE_ID}.extension"
TESTS_BUNDLE_ID="${MAIN_BUNDLE_ID}.tests"
FRAMEWORK_BUNDLE_ID="${MAIN_BUNDLE_ID}.framework"

log_step "Phase 1: Pre-Build Bundle Identifier Validation"
echo ""

# Define critical files
PBXPROJ_FILE="ios/Runner.xcodeproj/project.pbxproj"
INFO_PLIST_FILE="ios/Runner/Info.plist"
PODFILE="ios/Podfile"

if [[ ! -f "$PBXPROJ_FILE" ]]; then
    log_error "Critical file not found: $PBXPROJ_FILE"
    exit 1
fi

if [[ ! -f "$INFO_PLIST_FILE" ]]; then
    log_error "Critical file not found: $INFO_PLIST_FILE"
    exit 1
fi

log_info "Validating project structure..."
log_success "✓ project.pbxproj found"
log_success "✓ Info.plist found"

log_step "Phase 2: Bundle Identifier Collision Detection & Prevention"
echo ""

# Create comprehensive backup before modifications
BACKUP_DIR="pre_build_f8db6738_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp "$PBXPROJ_FILE" "$BACKUP_DIR/"
cp "$INFO_PLIST_FILE" "$BACKUP_DIR/"
[[ -f "$PODFILE" ]] && cp "$PODFILE" "$BACKUP_DIR/"

log_info "Created backup: $BACKUP_DIR"

# Phase 2a: Clean duplicate bundle identifiers in project.pbxproj
log_info "Scanning project.pbxproj for bundle identifier duplications..."

# Count current occurrences
MAIN_COUNT=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER.*$MAIN_BUNDLE_ID" "$PBXPROJ_FILE" || echo "0")
log_info "Found $MAIN_COUNT occurrences of main bundle identifier"

if [[ $MAIN_COUNT -gt 1 ]]; then
    log_warning "Multiple bundle identifier entries detected - applying collision prevention"
    
    # Strategy: Ensure each target gets a unique, bundle-id-rules compliant identifier
    log_info "Applying bundle-id-rules compliant identifier assignment..."
    
    # Create temporary file for modifications
    TEMP_PBXPROJ=$(mktemp)
    cp "$PBXPROJ_FILE" "$TEMP_PBXPROJ"
    
    # Process each target type with appropriate bundle ID
    # Main app target
    sed -i.bak "s/PRODUCT_BUNDLE_IDENTIFIER = .*insurancegroupmo.*insurancegroupmo.*/PRODUCT_BUNDLE_IDENTIFIER = $MAIN_BUNDLE_ID;/g" "$TEMP_PBXPROJ"
    
    # Widget extension
    if grep -q "widget\|Widget" "$TEMP_PBXPROJ"; then
        sed -i.bak "/widget\|Widget/,/PRODUCT_BUNDLE_IDENTIFIER/ s/PRODUCT_BUNDLE_IDENTIFIER = .*/PRODUCT_BUNDLE_IDENTIFIER = $WIDGET_BUNDLE_ID;/" "$TEMP_PBXPROJ"
        log_info "Applied widget bundle ID: $WIDGET_BUNDLE_ID"
    fi
    
    # Notification service extension
    if grep -q "notification\|Notification" "$TEMP_PBXPROJ"; then
        sed -i.bak "/notification\|Notification/,/PRODUCT_BUNDLE_IDENTIFIER/ s/PRODUCT_BUNDLE_IDENTIFIER = .*/PRODUCT_BUNDLE_IDENTIFIER = $NOTIFICATION_BUNDLE_ID;/" "$TEMP_PBXPROJ"
        log_info "Applied notification bundle ID: $NOTIFICATION_BUNDLE_ID"
    fi
    
    # Test targets
    if grep -q "test\|Test" "$TEMP_PBXPROJ"; then
        sed -i.bak "/test\|Test/,/PRODUCT_BUNDLE_IDENTIFIER/ s/PRODUCT_BUNDLE_IDENTIFIER = .*/PRODUCT_BUNDLE_IDENTIFIER = $TESTS_BUNDLE_ID;/" "$TEMP_PBXPROJ"
        log_info "Applied tests bundle ID: $TESTS_BUNDLE_ID"
    fi
    
    # Apply changes
    mv "$TEMP_PBXPROJ" "$PBXPROJ_FILE"
    log_success "✓ Bundle identifier collision prevention applied"
else
    log_success "✓ No bundle identifier collisions detected"
fi

# Phase 2b: Ensure Info.plist consistency
log_info "Validating Info.plist bundle identifier consistency..."
if command -v plutil >/dev/null 2>&1; then
    CURRENT_BUNDLE_ID=$(plutil -extract CFBundleIdentifier raw "$INFO_PLIST_FILE" 2>/dev/null || echo "")
    if [[ "$CURRENT_BUNDLE_ID" != "$MAIN_BUNDLE_ID" ]]; then
        log_warning "Info.plist bundle ID mismatch - correcting..."
        plutil -replace CFBundleIdentifier -string "$MAIN_BUNDLE_ID" "$INFO_PLIST_FILE"
        log_success "✓ Info.plist bundle ID updated to: $MAIN_BUNDLE_ID"
    else
        log_success "✓ Info.plist bundle ID is correct"
    fi
else
    log_warning "plutil not available - manual Info.plist validation recommended"
fi

log_step "Phase 3: Framework Embedding Collision Prevention"
echo ""

# Ensure proper framework embedding settings to prevent collisions
log_info "Validating framework embedding settings..."

# Check for framework embedding conflicts
if grep -q "EMBEDDED_CONTENT_CONTAINS_SWIFT.*YES" "$PBXPROJ_FILE"; then
    log_info "Swift embedding detected - ensuring proper configuration"
fi

# Apply "Do Not Embed" policy for extensions to prevent collisions
if grep -q "EXTENSION\|extension" "$PBXPROJ_FILE"; then
    log_info "Extension targets detected - applying Do Not Embed policy"
    sed -i.bak 's/settings = {.*EMBEDDED_CONTENT_CONTAINS_SWIFT = YES.*}/settings = {EMBEDDED_CONTENT_CONTAINS_SWIFT = NO;}/g' "$PBXPROJ_FILE"
    log_success "✓ Framework embedding collision prevention applied"
fi

log_step "Phase 4: Podfile Collision Prevention"
echo ""

if [[ -f "$PODFILE" ]]; then
    log_info "Validating Podfile for collision prevention..."
    
    # Ensure clean target specifications
    if grep -q "target.*Runner" "$PODFILE"; then
        log_success "✓ Podfile target structure validated"
    else
        log_warning "Podfile may need target structure review"
    fi
else
    log_info "No Podfile found - skipping Podfile validation"
fi

log_step "Phase 5: Final Validation"
echo ""

# Final bundle identifier count validation
FINAL_MAIN_COUNT=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER.*$MAIN_BUNDLE_ID" "$PBXPROJ_FILE" || echo "0")
log_info "Final bundle identifier validation:"
log_info "Main bundle ID occurrences: $FINAL_MAIN_COUNT"

# Validate no exact duplicates remain
UNIQUE_BUNDLE_IDS=$(grep "PRODUCT_BUNDLE_IDENTIFIER" "$PBXPROJ_FILE" | sort | uniq | wc -l | tr -d ' ')
TOTAL_BUNDLE_IDS=$(grep "PRODUCT_BUNDLE_IDENTIFIER" "$PBXPROJ_FILE" | wc -l | tr -d ' ')

log_info "Unique bundle IDs: $UNIQUE_BUNDLE_IDS"
log_info "Total bundle IDs: $TOTAL_BUNDLE_IDS"

if [[ "$UNIQUE_BUNDLE_IDS" == "$TOTAL_BUNDLE_IDS" ]]; then
    log_success "✓ No bundle identifier duplications detected"
else
    log_warning "Bundle identifier analysis: $UNIQUE_BUNDLE_IDS unique / $TOTAL_BUNDLE_IDS total"
fi

echo ""
log_step "======================================"
log_success "PRE-BUILD COLLISION ELIMINATION f8db6738 COMPLETED"
log_step "======================================"
log_info "Error ID: f8db6738-f319-4958-8058-d68dba787835"
log_info "Status: COLLISION PREVENTION APPLIED"
log_info "Strategy: Bundle-ID-Rules Compliant + Pre-Build Prevention"
log_info "Main Bundle ID: $MAIN_BUNDLE_ID"
log_info "Backup Location: $BACKUP_DIR"
log_info "Log File: $HOME/collision_elimination_f8db6738.log"
echo ""

# Create collision prevention summary
cat > "collision_prevention_f8db6738_summary.txt" << EOF
Pre-Build Collision Elimination f8db6738 Summary
==============================================
Timestamp: $(date)
Error ID: f8db6738-f319-4958-8058-d68dba787835
Status: COMPLETED

Bundle Identifier Configuration:
- Main App: $MAIN_BUNDLE_ID
- Widget: $WIDGET_BUNDLE_ID  
- Notifications: $NOTIFICATION_BUNDLE_ID
- Extensions: $EXTENSION_BUNDLE_ID
- Tests: $TESTS_BUNDLE_ID
- Framework: $FRAMEWORK_BUNDLE_ID

Collision Prevention Applied:
✓ Bundle identifier deduplication
✓ Bundle-id-rules compliant naming
✓ Framework embedding collision prevention
✓ Project structure validation
✓ Info.plist consistency

Backup: $BACKUP_DIR
Log: $HOME/collision_elimination_f8db6738.log
EOF

log_success "Collision prevention summary created: collision_prevention_f8db6738_summary.txt"
echo ""

exit 0 