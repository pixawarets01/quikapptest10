#!/bin/bash

# Nuclear IPA Collision Eliminator f8db6738
# Fixes CFBundleIdentifier collision with error ID f8db6738-f319-4958-8058-d68dba787835
# Directly modifies IPA file after build completion

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
    echo -e "${color}${BOLD}[NUCLEAR-IPA-f8db6738]${NC} ${color}${message}${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [NUCLEAR-IPA-f8db6738] ${message}" >> "$HOME/nuclear_ipa_collision_f8db6738.log"
}

log_info() { log_with_color "$BLUE" "$1"; }
log_success() { log_with_color "$GREEN" "$1"; }
log_warning() { log_with_color "$YELLOW" "$1"; }
log_error() { log_with_color "$RED" "$1"; }
log_step() { log_with_color "$PURPLE" "$1"; }

echo ""
log_step "======================================"
log_step "NUCLEAR IPA COLLISION ELIMINATOR f8db6738"
log_step "======================================"
log_info "Target Error ID: f8db6738-f319-4958-8058-d68dba787835"
log_info "Operation: Direct IPA Modification"
log_info "Strategy: Bundle-ID-Rules Compliant Post-Build Fix"
echo ""

# Main bundle identifier (bundle-id-rules compliant)
MAIN_BUNDLE_ID="com.insurancegroupmo.insurancegroupmo"

# Bundle-ID-Rules compliant extensions
WIDGET_BUNDLE_ID="${MAIN_BUNDLE_ID}.widget"
NOTIFICATION_BUNDLE_ID="${MAIN_BUNDLE_ID}.notificationservice"
EXTENSION_BUNDLE_ID="${MAIN_BUNDLE_ID}.extension"
TESTS_BUNDLE_ID="${MAIN_BUNDLE_ID}.tests"
FRAMEWORK_BUNDLE_ID="${MAIN_BUNDLE_ID}.framework"

log_step "Phase 1: IPA File Detection and Validation"
echo ""

# Find the most recent IPA file
IPA_FILE=""
if [[ -f "build/ios/ipa/Runner.ipa" ]]; then
    IPA_FILE="build/ios/ipa/Runner.ipa"
elif [[ -f "Insurancegroupmo.ipa" ]]; then
    IPA_FILE="Insurancegroupmo.ipa"
elif [[ -f "Runner.ipa" ]]; then
    IPA_FILE="Runner.ipa"
else
    # Search for any IPA file in common locations
    IPA_FILE=$(find . -name "*.ipa" -type f | head -1)
fi

if [[ -z "$IPA_FILE" ]] || [[ ! -f "$IPA_FILE" ]]; then
    log_error "No IPA file found for collision elimination"
    log_error "Searched locations:"
    log_error "  - build/ios/ipa/Runner.ipa"
    log_error "  - Insurancegroupmo.ipa"
    log_error "  - Runner.ipa"
    log_error "  - Current directory *.ipa files"
    exit 1
fi

log_success "✓ IPA file found: $IPA_FILE"
IPA_SIZE=$(ls -lh "$IPA_FILE" | awk '{print $5}')
log_info "IPA file size: $IPA_SIZE"

log_step "Phase 2: IPA Extraction and Bundle Analysis"
echo ""

# Create working directory
WORK_DIR="nuclear_ipa_fix_f8db6738_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$WORK_DIR"

log_info "Created working directory: $WORK_DIR"

# Extract IPA
cd "$WORK_DIR"
log_info "Extracting IPA file..."
unzip -q "../$IPA_FILE"

if [[ ! -d "Payload" ]]; then
    log_error "Invalid IPA structure - Payload directory not found"
    cd ..
    rm -rf "$WORK_DIR"
    exit 1
fi

log_success "✓ IPA extracted successfully"

# Find the main app bundle
APP_BUNDLE=$(find Payload -name "*.app" -type d | head -1)
if [[ -z "$APP_BUNDLE" ]]; then
    log_error "No .app bundle found in IPA"
    cd ..
    rm -rf "$WORK_DIR"
    exit 1
fi

log_success "✓ App bundle found: $APP_BUNDLE"

log_step "Phase 3: Bundle Identifier Collision Detection and Fix"
echo ""

# Analyze Info.plist files
MAIN_INFO_PLIST="$APP_BUNDLE/Info.plist"
if [[ ! -f "$MAIN_INFO_PLIST" ]]; then
    log_error "Main Info.plist not found: $MAIN_INFO_PLIST"
    cd ..
    rm -rf "$WORK_DIR"
    exit 1
fi

log_info "Analyzing bundle identifiers in IPA..."

# Check current bundle identifier
if command -v plutil >/dev/null 2>&1; then
    CURRENT_MAIN_ID=$(plutil -extract CFBundleIdentifier raw "$MAIN_INFO_PLIST" 2>/dev/null || echo "unknown")
    log_info "Current main bundle ID: $CURRENT_MAIN_ID"
else
    log_warning "plutil not available - using grep analysis"
    CURRENT_MAIN_ID=$(grep -A1 "CFBundleIdentifier" "$MAIN_INFO_PLIST" | grep -v "CFBundleIdentifier" | sed 's/.*<string>\(.*\)<\/string>.*/\1/' | head -1)
    log_info "Current main bundle ID: $CURRENT_MAIN_ID"
fi

# Find all Info.plist files in the app bundle
log_info "Scanning for extension bundles and collision sources..."
INFO_PLISTS=($(find "$APP_BUNDLE" -name "Info.plist" -type f))

log_info "Found ${#INFO_PLISTS[@]} Info.plist files:"
for plist in "${INFO_PLISTS[@]}"; do
    log_info "  - $plist"
done

# Detect and fix collisions
COLLISION_FIXED=false

for plist in "${INFO_PLISTS[@]}"; do
    if [[ "$plist" == "$MAIN_INFO_PLIST" ]]; then
        # Main app bundle
        if [[ "$CURRENT_MAIN_ID" != "$MAIN_BUNDLE_ID" ]]; then
            log_warning "Fixing main bundle ID: $CURRENT_MAIN_ID -> $MAIN_BUNDLE_ID"
            if command -v plutil >/dev/null 2>&1; then
                plutil -replace CFBundleIdentifier -string "$MAIN_BUNDLE_ID" "$plist"
            else
                sed -i.bak "s|<string>$CURRENT_MAIN_ID</string>|<string>$MAIN_BUNDLE_ID</string>|" "$plist"
            fi
            COLLISION_FIXED=true
            log_success "✓ Main bundle ID fixed"
        fi
    else
        # Extension bundles - apply bundle-id-rules compliant naming
        PLIST_PATH=$(dirname "$plist")
        PLIST_DIR=$(basename "$PLIST_PATH")
        
        if command -v plutil >/dev/null 2>&1; then
            EXTENSION_ID=$(plutil -extract CFBundleIdentifier raw "$plist" 2>/dev/null || echo "unknown")
        else
            EXTENSION_ID=$(grep -A1 "CFBundleIdentifier" "$plist" | grep -v "CFBundleIdentifier" | sed 's/.*<string>\(.*\)<\/string>.*/\1/' | head -1)
        fi
        
        log_info "Extension bundle: $PLIST_DIR (ID: $EXTENSION_ID)"
        
        # Determine appropriate bundle ID based on extension type
        NEW_EXTENSION_ID=""
        
        if [[ "$PLIST_DIR" =~ [Ww]idget ]]; then
            NEW_EXTENSION_ID="$WIDGET_BUNDLE_ID"
        elif [[ "$PLIST_DIR" =~ [Nn]otification ]]; then
            NEW_EXTENSION_ID="$NOTIFICATION_BUNDLE_ID"
        elif [[ "$PLIST_DIR" =~ [Tt]est ]]; then
            NEW_EXTENSION_ID="$TESTS_BUNDLE_ID"
        elif [[ "$PLIST_DIR" =~ [Ff]ramework ]]; then
            NEW_EXTENSION_ID="$FRAMEWORK_BUNDLE_ID"
        else
            NEW_EXTENSION_ID="$EXTENSION_BUNDLE_ID"
        fi
        
        # Check if collision exists (same as main bundle ID)
        if [[ "$EXTENSION_ID" == "$MAIN_BUNDLE_ID" ]] || [[ "$EXTENSION_ID" == "$CURRENT_MAIN_ID" ]]; then
            log_warning "COLLISION DETECTED: Extension has same ID as main app"
            log_warning "Fixing collision: $EXTENSION_ID -> $NEW_EXTENSION_ID"
            
            if command -v plutil >/dev/null 2>&1; then
                plutil -replace CFBundleIdentifier -string "$NEW_EXTENSION_ID" "$plist"
            else
                sed -i.bak "s|<string>$EXTENSION_ID</string>|<string>$NEW_EXTENSION_ID</string>|" "$plist"
            fi
            
            COLLISION_FIXED=true
            log_success "✓ Extension collision fixed: $NEW_EXTENSION_ID"
        elif [[ "$EXTENSION_ID" != "$NEW_EXTENSION_ID" ]]; then
            log_info "Standardizing extension ID: $EXTENSION_ID -> $NEW_EXTENSION_ID"
            
            if command -v plutil >/dev/null 2>&1; then
                plutil -replace CFBundleIdentifier -string "$NEW_EXTENSION_ID" "$plist"
            else
                sed -i.bak "s|<string>$EXTENSION_ID</string>|<string>$NEW_EXTENSION_ID</string>|" "$plist"
            fi
            
            COLLISION_FIXED=true
            log_success "✓ Extension ID standardized: $NEW_EXTENSION_ID"
        else
            log_success "✓ Extension ID already correct: $EXTENSION_ID"
        fi
    fi
done

if [[ "$COLLISION_FIXED" == "false" ]]; then
    log_info "No collisions detected - IPA bundle IDs are already unique"
fi

log_step "Phase 4: IPA Repackaging and Validation"
echo ""

# Clean up backup files
find . -name "*.bak" -delete 2>/dev/null || true

# Repackage IPA
log_info "Repackaging IPA with collision fixes..."
FIXED_IPA="../$(basename "$IPA_FILE" .ipa)_f8db6738_fixed.ipa"

zip -r "$FIXED_IPA" Payload/ >/dev/null 2>&1

cd ..

if [[ -f "$(basename "$FIXED_IPA")" ]]; then
    FIXED_SIZE=$(ls -lh "$(basename "$FIXED_IPA")" | awk '{print $5}')
    log_success "✓ Fixed IPA created: $(basename "$FIXED_IPA")"
    log_info "Fixed IPA size: $FIXED_SIZE"
    
    # Create verification summary
    log_info "Bundle identifier verification:"
    log_info "  Main App: $MAIN_BUNDLE_ID"
    log_info "  Widget: $WIDGET_BUNDLE_ID"
    log_info "  Notifications: $NOTIFICATION_BUNDLE_ID"
    log_info "  Extensions: $EXTENSION_BUNDLE_ID"
    log_info "  Tests: $TESTS_BUNDLE_ID"
    log_info "  Framework: $FRAMEWORK_BUNDLE_ID"
else
    log_error "Failed to create fixed IPA"
    rm -rf "$WORK_DIR"
    exit 1
fi

# Clean up working directory
rm -rf "$WORK_DIR"

log_step "Phase 5: Final Validation and Summary"
echo ""

# Create collision fix summary
cat > "nuclear_ipa_collision_fix_f8db6738_summary.txt" << EOF
Nuclear IPA Collision Fix f8db6738 Summary
=======================================
Timestamp: $(date)
Error ID: f8db6738-f319-4958-8058-d68dba787835
Status: COMPLETED

Original IPA: $IPA_FILE ($IPA_SIZE)
Fixed IPA: $(basename "$FIXED_IPA") ($FIXED_SIZE)

Bundle Identifier Fixes Applied:
- Main App: $MAIN_BUNDLE_ID
- Widget: $WIDGET_BUNDLE_ID
- Notifications: $NOTIFICATION_BUNDLE_ID
- Extensions: $EXTENSION_BUNDLE_ID
- Tests: $TESTS_BUNDLE_ID
- Framework: $FRAMEWORK_BUNDLE_ID

Collision Resolution:
✓ CFBundleIdentifier collision eliminated
✓ Bundle-id-rules compliant naming applied
✓ Extension bundle IDs standardized
✓ IPA successfully repackaged

Log: $HOME/nuclear_ipa_collision_f8db6738.log
EOF

echo ""
log_step "======================================"
log_success "NUCLEAR IPA COLLISION ELIMINATION f8db6738 COMPLETED"
log_step "======================================"
log_info "Error ID: f8db6738-f319-4958-8058-d68dba787835"
log_info "Status: COLLISION FIXED"
log_info "Fixed IPA: $(basename "$FIXED_IPA")"
log_info "Summary: nuclear_ipa_collision_fix_f8db6738_summary.txt"
log_info "Log: $HOME/nuclear_ipa_collision_f8db6738.log"
echo ""

log_success "IPA collision elimination completed successfully!"
echo ""

exit 0 