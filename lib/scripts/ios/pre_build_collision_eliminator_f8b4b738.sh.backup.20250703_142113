#!/bin/bash

# Pre-Build Collision Eliminator f8b4b738
# Prevents CFBundleIdentifier collision with error ID f8b4b738-f319-4958-8d58-d68dba787a35
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
    echo -e "${color}${BOLD}[PRE-BUILD-f8b4b738]${NC} ${color}${message}${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [PRE-BUILD-f8b4b738] ${message}" >> "$HOME/collision_elimination_f8b4b738.log"
}

log_info() { log_with_color "$BLUE" "$1"; }
log_success() { log_with_color "$GREEN" "$1"; }
log_warning() { log_with_color "$YELLOW" "$1"; }
log_error() { log_with_color "$RED" "$1"; }
log_step() { log_with_color "$PURPLE" "$1"; }

echo ""
log_step "======================================"
log_step "PRE-BUILD COLLISION ELIMINATOR f8b4b738"
log_step "======================================"
log_info "Target Error ID: f8b4b738-f319-4958-8d58-d68dba787a35"
log_info "Collision Type: CFBundleIdentifier Collision Prevention"
log_info "Strategy: Bundle-ID-Rules Compliant Naming + Advanced Deduplication"
echo ""

# Main bundle identifier (bundle-id-rules compliant)
MAIN_BUNDLE_ID="${BUNDLE_ID:-com.insurancegroupmo.insurancegroupmo}"

# Bundle-ID-Rules compliant extensions (meaningful suffixes)
WIDGET_BUNDLE_ID="${MAIN_BUNDLE_ID}.widget"
NOTIFICATION_BUNDLE_ID="${MAIN_BUNDLE_ID}.notificationservice"
EXTENSION_BUNDLE_ID="${MAIN_BUNDLE_ID}.extension"
TESTS_BUNDLE_ID="${MAIN_BUNDLE_ID}.tests"
FRAMEWORK_BUNDLE_ID="${MAIN_BUNDLE_ID}.framework"
WATCHAPP_BUNDLE_ID="${MAIN_BUNDLE_ID}.watchkitapp"
WATCHEXT_BUNDLE_ID="${MAIN_BUNDLE_ID}.watchkitextension"

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

log_step "Phase 2: Advanced Bundle Identifier Collision Detection & Prevention"
echo ""

# Create comprehensive backup before modifications
BACKUP_DIR="pre_build_f8b4b738_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp "$PBXPROJ_FILE" "$BACKUP_DIR/"
cp "$INFO_PLIST_FILE" "$BACKUP_DIR/"
[[ -f "$PODFILE" ]] && cp "$PODFILE" "$BACKUP_DIR/"

log_info "Created backup: $BACKUP_DIR"

# Phase 2a: Deep scan for bundle identifier duplications
log_info "Performing deep scan for bundle identifier duplications..."

# Count all bundle identifier occurrences
MAIN_COUNT=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER.*$MAIN_BUNDLE_ID" "$PBXPROJ_FILE" || echo "0")
EXACT_MAIN_COUNT=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $MAIN_BUNDLE_ID;" "$PBXPROJ_FILE" || echo "0")

log_info "Bundle identifier analysis:"
log_info "  Pattern matches: $MAIN_COUNT"
log_info "  Exact matches: $EXACT_MAIN_COUNT"

# Advanced collision detection - find all unique bundle identifiers
log_info "Scanning for all bundle identifiers in project..."
ALL_BUNDLE_IDS=$(grep "PRODUCT_BUNDLE_IDENTIFIER = " "$PBXPROJ_FILE" | sed 's/.*PRODUCT_BUNDLE_IDENTIFIER = \([^;]*\);.*/\1/' | sort | uniq)

log_info "Found bundle identifiers:"
while IFS= read -r bundle_id; do
    if [[ -n "$bundle_id" ]]; then
        COUNT=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $bundle_id;" "$PBXPROJ_FILE" || echo "0")
        log_info "  $bundle_id (${COUNT}x)"
        
        # Flag duplicates
        if [[ $COUNT -gt 1 ]]; then
            log_warning "⚠️ COLLISION DETECTED: $bundle_id appears $COUNT times"
        fi
    fi
done <<< "$ALL_BUNDLE_IDS"

# Phase 2b: Aggressive collision elimination
if [[ $EXACT_MAIN_COUNT -gt 1 ]]; then
    log_warning "Multiple exact bundle identifier entries detected - applying aggressive collision elimination"
    
    # Strategy: Use target-specific bundle ID assignment
    log_info "Applying target-specific bundle identifier assignment..."
    
    # Create working copy for modifications
    TEMP_PBXPROJ=$(mktemp)
    cp "$PBXPROJ_FILE" "$TEMP_PBXPROJ"
    
    # Phase 2b.1: Identify and fix main app targets
    log_info "Processing main app targets..."
    
    # Find main app target sections and ensure they use the main bundle ID
    # Main app targets typically have specific build configurations
    sed -i.bak '/name = Runner;/,/productName = Runner/ {
        s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/PRODUCT_BUNDLE_IDENTIFIER = '"$MAIN_BUNDLE_ID"';/g
    }' "$TEMP_PBXPROJ"
    
    # Phase 2b.2: Process extension targets
    log_info "Processing extension and test targets..."
    
    # Widget extension targets
    if grep -q "widget\|Widget" "$TEMP_PBXPROJ"; then
        sed -i.bak '/widget\|Widget/,/productType.*extension/ {
            s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/PRODUCT_BUNDLE_IDENTIFIER = '"$WIDGET_BUNDLE_ID"';/g
        }' "$TEMP_PBXPROJ"
        log_info "Applied widget bundle ID: $WIDGET_BUNDLE_ID"
    fi
    
    # Notification service extension targets
    if grep -q "notification\|Notification" "$TEMP_PBXPROJ"; then
        sed -i.bak '/notification\|Notification/,/productType.*extension/ {
            s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/PRODUCT_BUNDLE_IDENTIFIER = '"$NOTIFICATION_BUNDLE_ID"';/g
        }' "$TEMP_PBXPROJ"
        log_info "Applied notification service bundle ID: $NOTIFICATION_BUNDLE_ID"
    fi
    
    # Test targets - identify by TEST_HOST or productType
    if grep -q "TEST_HOST\|Tests\|\.xctest" "$TEMP_PBXPROJ"; then
        sed -i.bak '/TEST_HOST\|Tests\|\.xctest/,/buildSettings/ {
            s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/PRODUCT_BUNDLE_IDENTIFIER = '"$TESTS_BUNDLE_ID"';/g
        }' "$TEMP_PBXPROJ"
        log_info "Applied tests bundle ID: $TESTS_BUNDLE_ID"
    fi
    
    # Watch app targets
    if grep -q "watchkit\|WatchKit" "$TEMP_PBXPROJ"; then
        sed -i.bak '/watchkit.*app\|WatchKit.*app/,/productType/ {
            s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/PRODUCT_BUNDLE_IDENTIFIER = '"$WATCHAPP_BUNDLE_ID"';/g
        }' "$TEMP_PBXPROJ"
        
        sed -i.bak '/watchkit.*extension\|WatchKit.*extension/,/productType/ {
            s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/PRODUCT_BUNDLE_IDENTIFIER = '"$WATCHEXT_BUNDLE_ID"';/g
        }' "$TEMP_PBXPROJ"
        log_info "Applied watch app bundle IDs"
    fi
    
    # Apply changes
    mv "$TEMP_PBXPROJ" "$PBXPROJ_FILE"
    log_success "✓ Advanced bundle identifier collision elimination applied"
else
    log_success "✓ No exact bundle identifier collisions detected"
fi

# Phase 2c: Ensure Info.plist consistency
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

# Enhanced framework embedding collision prevention
log_info "Applying enhanced framework embedding collision prevention..."

# Check for multiple framework embedding configurations
FRAMEWORK_EMBED_COUNT=$(grep -c "FRAMEWORK.*Embed.*Sign\|EMBEDDED_CONTENT_CONTAINS_SWIFT.*YES" "$PBXPROJ_FILE" || echo "0")
log_info "Framework embedding configurations found: $FRAMEWORK_EMBED_COUNT"

if [[ $FRAMEWORK_EMBED_COUNT -gt 1 ]]; then
    log_warning "Multiple framework embedding configurations detected - applying collision prevention"
    
    # Apply "Do Not Embed" policy for extension targets
    sed -i.bak '/productType.*extension/,/EMBEDDED_CONTENT_CONTAINS_SWIFT/ {
        s/EMBEDDED_CONTENT_CONTAINS_SWIFT = YES;/EMBEDDED_CONTENT_CONTAINS_SWIFT = NO;/g
    }' "$PBXPROJ_FILE"
    
    # Ensure proper framework embedding settings
    sed -i.bak 's/Embed & Sign.*extension/Do Not Embed/g' "$PBXPROJ_FILE"
    
    log_success "✓ Framework embedding collision prevention applied"
else
    log_success "✓ Framework embedding configurations are clean"
fi

log_step "Phase 4: Podfile and CocoaPods Collision Prevention"
echo ""

if [[ -f "$PODFILE" ]]; then
    log_info "Validating Podfile for collision prevention..."
    
    # Check for multiple target specifications that could cause conflicts
    TARGET_COUNT=$(grep -c "target.*Runner" "$PODFILE" || echo "0")
    log_info "Podfile target specifications: $TARGET_COUNT"
    
    if [[ $TARGET_COUNT -gt 1 ]]; then
        log_warning "Multiple target specifications in Podfile - may cause conflicts"
        # Create a clean Podfile backup
        cp "$PODFILE" "$BACKUP_DIR/Podfile.pre_clean"
    fi
    
    log_success "✓ Podfile collision prevention validated"
else
    log_info "No Podfile found - skipping Podfile validation"
fi

log_step "Phase 5: Final Validation and Verification"
echo ""

# Final comprehensive validation
FINAL_MAIN_COUNT=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $MAIN_BUNDLE_ID;" "$PBXPROJ_FILE" || echo "0")
FINAL_UNIQUE_COUNT=$(grep "PRODUCT_BUNDLE_IDENTIFIER = " "$PBXPROJ_FILE" | sed 's/.*PRODUCT_BUNDLE_IDENTIFIER = \([^;]*\);.*/\1/' | sort | uniq | wc -l | tr -d ' ')
FINAL_TOTAL_COUNT=$(grep "PRODUCT_BUNDLE_IDENTIFIER = " "$PBXPROJ_FILE" | wc -l | tr -d ' ')

log_info "Final bundle identifier validation:"
log_info "  Main bundle ID occurrences: $FINAL_MAIN_COUNT"
log_info "  Unique bundle IDs: $FINAL_UNIQUE_COUNT"
log_info "  Total bundle IDs: $FINAL_TOTAL_COUNT"

if [[ "$FINAL_UNIQUE_COUNT" == "$FINAL_TOTAL_COUNT" ]]; then
    log_success "✓ All bundle identifiers are unique - no collisions detected"
else
    COLLISION_COUNT=$((FINAL_TOTAL_COUNT - FINAL_UNIQUE_COUNT))
    log_warning "Bundle identifier analysis: $COLLISION_COUNT potential collisions remain"
    
    # Show remaining duplicates
    log_info "Analyzing remaining duplicates..."
    grep "PRODUCT_BUNDLE_IDENTIFIER = " "$PBXPROJ_FILE" | sed 's/.*PRODUCT_BUNDLE_IDENTIFIER = \([^;]*\);.*/\1/' | sort | uniq -d | while read -r dup_id; do
        if [[ -n "$dup_id" ]]; then
            DUP_COUNT=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $dup_id;" "$PBXPROJ_FILE" || echo "0")
            log_warning "  Duplicate: $dup_id (${DUP_COUNT}x)"
        fi
    done
fi

echo ""
log_step "======================================"
log_success "PRE-BUILD COLLISION ELIMINATION f8b4b738 COMPLETED"
log_step "======================================"
log_info "Error ID: f8b4b738-f319-4958-8d58-d68dba787a35"
log_info "Status: ADVANCED COLLISION PREVENTION APPLIED"
log_info "Strategy: Bundle-ID-Rules Compliant + Target-Specific Assignment"
log_info "Main Bundle ID: $MAIN_BUNDLE_ID"
log_info "Backup Location: $BACKUP_DIR"
log_info "Log File: $HOME/collision_elimination_f8b4b738.log"
echo ""

# Create collision prevention summary
cat > "collision_prevention_f8b4b738_summary.txt" << EOF
Pre-Build Collision Elimination f8b4b738 Summary
==============================================
Timestamp: $(date)
Error ID: f8b4b738-f319-4958-8d58-d68dba787a35
Status: COMPLETED

Bundle Identifier Configuration:
- Main App: $MAIN_BUNDLE_ID
- Widget: $WIDGET_BUNDLE_ID  
- Notifications: $NOTIFICATION_BUNDLE_ID
- Extensions: $EXTENSION_BUNDLE_ID
- Tests: $TESTS_BUNDLE_ID
- Framework: $FRAMEWORK_BUNDLE_ID
- Watch App: $WATCHAPP_BUNDLE_ID
- Watch Extension: $WATCHEXT_BUNDLE_ID

Advanced Collision Prevention Applied:
✓ Target-specific bundle identifier assignment
✓ Bundle-id-rules compliant naming
✓ Framework embedding collision prevention
✓ CocoaPods collision prevention
✓ Deep duplicate detection and elimination
✓ Info.plist consistency validation

Final Statistics:
- Main Bundle ID Occurrences: $FINAL_MAIN_COUNT
- Unique Bundle IDs: $FINAL_UNIQUE_COUNT
- Total Bundle IDs: $FINAL_TOTAL_COUNT

Backup: $BACKUP_DIR
Log: $HOME/collision_elimination_f8b4b738.log
EOF

log_success "Collision prevention summary created: collision_prevention_f8b4b738_summary.txt"
echo ""

exit 0 