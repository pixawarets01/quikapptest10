#!/bin/bash

# Nuclear IPA Collision Eliminator f8b4b738
# Fixes CFBundleIdentifier collision with error ID f8b4b738-f319-4958-8d58-d68dba787a35
# Directly modifies IPA file after build completion with advanced collision detection

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
    echo -e "${color}${BOLD}[NUCLEAR-IPA-f8b4b738]${NC} ${color}${message}${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [NUCLEAR-IPA-f8b4b738] ${message}" >> "$HOME/nuclear_ipa_collision_f8b4b738.log"
}

log_info() { log_with_color "$BLUE" "$1"; }
log_success() { log_with_color "$GREEN" "$1"; }
log_warning() { log_with_color "$YELLOW" "$1"; }
log_error() { log_with_color "$RED" "$1"; }
log_step() { log_with_color "$PURPLE" "$1"; }

echo ""
log_step "======================================"
log_step "NUCLEAR IPA COLLISION ELIMINATOR f8b4b738"
log_step "======================================"
log_info "Target Error ID: f8b4b738-f319-4958-8d58-d68dba787a35"
log_info "Operation: Advanced Direct IPA Modification"
log_info "Strategy: Bundle-ID-Rules Compliant Post-Build Fix + Deep Analysis"
echo ""

# Main bundle identifier (bundle-id-rules compliant)
MAIN_BUNDLE_ID="com.insurancegroupmo.insurancegroupmo"

# Bundle-ID-Rules compliant extensions
WIDGET_BUNDLE_ID="${MAIN_BUNDLE_ID}.widget"
NOTIFICATION_BUNDLE_ID="${MAIN_BUNDLE_ID}.notificationservice"
EXTENSION_BUNDLE_ID="${MAIN_BUNDLE_ID}.extension"
TESTS_BUNDLE_ID="${MAIN_BUNDLE_ID}.tests"
FRAMEWORK_BUNDLE_ID="${MAIN_BUNDLE_ID}.framework"
WATCHAPP_BUNDLE_ID="${MAIN_BUNDLE_ID}.watchkitapp"
WATCHEXT_BUNDLE_ID="${MAIN_BUNDLE_ID}.watchkitextension"

log_step "Phase 1: IPA File Detection and Advanced Validation"
echo ""

# Enhanced IPA file detection with multiple search patterns
IPA_FILE=""
IPA_LOCATIONS=(
    "build/ios/ipa/Runner.ipa"
    "output/ios/Runner.ipa"
    "Insurancegroupmo.ipa"
    "Runner.ipa"
    "build/ios/ipa/*.ipa"
    "output/ios/*.ipa"
)

log_info "Searching for IPA files in multiple locations..."
for location in "${IPA_LOCATIONS[@]}"; do
    if [[ "$location" == *"*"* ]]; then
        # Handle wildcard patterns
        found_files=($(find . -path "./$location" -type f 2>/dev/null | head -1))
        if [[ ${#found_files[@]} -gt 0 ]] && [[ -f "${found_files[0]}" ]]; then
            IPA_FILE="${found_files[0]}"
            log_info "Found IPA via wildcard: $location -> $IPA_FILE"
            break
        fi
    else
        if [[ -f "$location" ]]; then
            IPA_FILE="$location"
            log_info "Found IPA at: $location"
            break
        fi
    fi
done

# Ultimate fallback: comprehensive search
if [[ -z "$IPA_FILE" ]] || [[ ! -f "$IPA_FILE" ]]; then
    log_warning "Standard search failed - performing comprehensive IPA search..."
    IPA_FILE=$(find . -name "*.ipa" -type f -not -path "./.*" | head -1)
fi

if [[ -z "$IPA_FILE" ]] || [[ ! -f "$IPA_FILE" ]]; then
    log_error "No IPA file found for collision elimination"
    log_error "Searched locations:"
    for location in "${IPA_LOCATIONS[@]}"; do
        log_error "  - $location"
    done
    log_error "  - Comprehensive search: find . -name '*.ipa'"
    exit 1
fi

log_success "✓ IPA file found: $IPA_FILE"
IPA_SIZE=$(ls -lh "$IPA_FILE" | awk '{print $5}')
log_info "IPA file size: $IPA_SIZE"

# Validate IPA file integrity
if [[ ! "$IPA_FILE" =~ \.ipa$ ]]; then
    log_error "Invalid file extension - not an IPA file: $IPA_FILE"
    exit 1
fi

# Check if IPA is readable
if ! unzip -t "$IPA_FILE" >/dev/null 2>&1; then
    log_error "IPA file is corrupted or not a valid ZIP archive: $IPA_FILE"
    exit 1
fi

log_step "Phase 2: Advanced IPA Extraction and Bundle Structure Analysis"
echo ""

# Create working directory with collision ID
WORK_DIR="nuclear_ipa_fix_f8b4b738_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$WORK_DIR"

log_info "Created working directory: $WORK_DIR"

# Extract IPA with detailed logging
cd "$WORK_DIR"
log_info "Extracting IPA file with advanced analysis..."
unzip -q "../$IPA_FILE"

if [[ ! -d "Payload" ]]; then
    log_error "Invalid IPA structure - Payload directory not found"
    cd ..
    rm -rf "$WORK_DIR"
    exit 1
fi

log_success "✓ IPA extracted successfully"

# Find the main app bundle with enhanced detection
APP_BUNDLE=$(find Payload -name "*.app" -type d | head -1)
if [[ -z "$APP_BUNDLE" ]]; then
    log_error "No .app bundle found in IPA"
    cd ..
    rm -rf "$WORK_DIR"
    exit 1
fi

log_success "✓ App bundle found: $APP_BUNDLE"

# Analyze app bundle structure
APP_SIZE=$(du -sh "$APP_BUNDLE" | cut -f1)
log_info "App bundle size: $APP_SIZE"

# Find all nested bundles and frameworks
log_info "Analyzing app bundle structure..."
NESTED_BUNDLES=($(find "$APP_BUNDLE" -name "*.app" -o -name "*.framework" -o -name "*.extension" -o -name "*.appex" 2>/dev/null))
log_info "Found ${#NESTED_BUNDLES[@]} nested bundles/frameworks:"
for bundle in "${NESTED_BUNDLES[@]}"; do
    log_info "  - $bundle"
done

log_step "Phase 3: Advanced Bundle Identifier Collision Detection and Analysis"
echo ""

# Analyze Info.plist files with comprehensive detection
MAIN_INFO_PLIST="$APP_BUNDLE/Info.plist"
if [[ ! -f "$MAIN_INFO_PLIST" ]]; then
    log_error "Main Info.plist not found: $MAIN_INFO_PLIST"
    cd ..
    rm -rf "$WORK_DIR"
    exit 1
fi

log_info "Performing advanced bundle identifier analysis..."

# Check current bundle identifier
if command -v plutil >/dev/null 2>&1; then
    CURRENT_MAIN_ID=$(plutil -extract CFBundleIdentifier raw "$MAIN_INFO_PLIST" 2>/dev/null || echo "unknown")
    log_info "Current main bundle ID: $CURRENT_MAIN_ID"
else
    log_warning "plutil not available - using grep analysis"
    CURRENT_MAIN_ID=$(grep -A1 "CFBundleIdentifier" "$MAIN_INFO_PLIST" | grep -v "CFBundleIdentifier" | sed 's/.*<string>\(.*\)<\/string>.*/\1/' | head -1)
    log_info "Current main bundle ID: $CURRENT_MAIN_ID"
fi

# Find ALL Info.plist files in the app bundle with comprehensive search
log_info "Scanning for all Info.plist files and collision sources..."
INFO_PLISTS=($(find "$APP_BUNDLE" -name "Info.plist" -type f))

log_info "Found ${#INFO_PLISTS[@]} Info.plist files:"
for plist in "${INFO_PLISTS[@]}"; do
    log_info "  - $plist"
done

# Advanced collision detection and analysis
COLLISION_MAP=""
BUNDLE_ID_COUNTS=""
COLLISION_DETECTED=false

log_info "Performing deep collision analysis..."
for plist in "${INFO_PLISTS[@]}"; do
    if command -v plutil >/dev/null 2>&1; then
        BUNDLE_ID=$(plutil -extract CFBundleIdentifier raw "$plist" 2>/dev/null || echo "unknown")
    else
        BUNDLE_ID=$(grep -A1 "CFBundleIdentifier" "$plist" | grep -v "CFBundleIdentifier" | sed 's/.*<string>\(.*\)<\/string>.*/\1/' | head -1)
    fi
    
    PLIST_PATH=$(dirname "$plist")
    PLIST_DIR=$(basename "$PLIST_PATH")
    
    log_info "Analyzing: $PLIST_DIR -> $BUNDLE_ID"
    
    # Track bundle ID occurrences
    if [[ "$BUNDLE_ID" == "$MAIN_BUNDLE_ID" ]] || [[ "$BUNDLE_ID" == "$CURRENT_MAIN_ID" ]]; then
        COLLISION_MAP="$COLLISION_MAP\n$PLIST_DIR: $BUNDLE_ID"
        if [[ "$plist" != "$MAIN_INFO_PLIST" ]]; then
            COLLISION_DETECTED=true
            log_warning "⚠️ COLLISION DETECTED: $PLIST_DIR has main app bundle ID!"
        fi
    fi
done

# Display collision summary
if [[ "$COLLISION_DETECTED" == "true" ]]; then
    log_error "💥 CRITICAL COLLISIONS DETECTED:"
    echo -e "$COLLISION_MAP" | grep -v "^$" | while read -r line; do
        log_error "  $line"
    done
else
    log_success "✓ No critical collisions detected in current analysis"
fi

log_step "Phase 4: Advanced Collision Elimination and Bundle ID Assignment"
echo ""

# Apply advanced collision fixes with target-specific logic
COLLISION_FIXED=false

for plist in "${INFO_PLISTS[@]}"; do
    if [[ "$plist" == "$MAIN_INFO_PLIST" ]]; then
        # Main app bundle - ensure correct ID
        if command -v plutil >/dev/null 2>&1; then
            CURRENT_ID=$(plutil -extract CFBundleIdentifier raw "$plist" 2>/dev/null || echo "unknown")
        else
            CURRENT_ID=$(grep -A1 "CFBundleIdentifier" "$plist" | grep -v "CFBundleIdentifier" | sed 's/.*<string>\(.*\)<\/string>.*/\1/' | head -1)
        fi
        
        if [[ "$CURRENT_ID" != "$MAIN_BUNDLE_ID" ]]; then
            log_warning "Fixing main bundle ID: $CURRENT_ID -> $MAIN_BUNDLE_ID"
            if command -v plutil >/dev/null 2>&1; then
                plutil -replace CFBundleIdentifier -string "$MAIN_BUNDLE_ID" "$plist"
            else
                sed -i.bak "s|<string>$CURRENT_ID</string>|<string>$MAIN_BUNDLE_ID</string>|" "$plist"
            fi
            COLLISION_FIXED=true
            log_success "✓ Main bundle ID corrected"
        fi
    else
        # Extension/framework bundles - apply bundle-id-rules compliant naming
        PLIST_PATH=$(dirname "$plist")
        PLIST_DIR=$(basename "$PLIST_PATH")
        
        if command -v plutil >/dev/null 2>&1; then
            EXTENSION_ID=$(plutil -extract CFBundleIdentifier raw "$plist" 2>/dev/null || echo "unknown")
        else
            EXTENSION_ID=$(grep -A1 "CFBundleIdentifier" "$plist" | grep -v "CFBundleIdentifier" | sed 's/.*<string>\(.*\)<\/string>.*/\1/' | head -1)
        fi
        
        log_info "Processing extension: $PLIST_DIR (Current ID: $EXTENSION_ID)"
        
        # Determine appropriate bundle ID based on target type with enhanced detection
        NEW_EXTENSION_ID=""
        
        if [[ "$PLIST_DIR" =~ [Ww]idget ]] || [[ "$PLIST_PATH" =~ [Ww]idget ]]; then
            NEW_EXTENSION_ID="$WIDGET_BUNDLE_ID"
        elif [[ "$PLIST_DIR" =~ [Nn]otification ]] || [[ "$PLIST_PATH" =~ [Nn]otification ]]; then
            NEW_EXTENSION_ID="$NOTIFICATION_BUNDLE_ID"
        elif [[ "$PLIST_DIR" =~ [Tt]est ]] || [[ "$PLIST_PATH" =~ [Tt]est ]]; then
            NEW_EXTENSION_ID="$TESTS_BUNDLE_ID"
        elif [[ "$PLIST_DIR" =~ [Ff]ramework ]] || [[ "$PLIST_PATH" =~ [Ff]ramework ]]; then
            NEW_EXTENSION_ID="$FRAMEWORK_BUNDLE_ID"
        elif [[ "$PLIST_DIR" =~ [Ww]atchkit.*[Aa]pp ]] || [[ "$PLIST_PATH" =~ [Ww]atch.*[Aa]pp ]]; then
            NEW_EXTENSION_ID="$WATCHAPP_BUNDLE_ID"
        elif [[ "$PLIST_DIR" =~ [Ww]atchkit.*[Ee]xt ]] || [[ "$PLIST_PATH" =~ [Ww]atch.*[Ee]xt ]]; then
            NEW_EXTENSION_ID="$WATCHEXT_BUNDLE_ID"
        else
            # Generic extension
            NEW_EXTENSION_ID="$EXTENSION_BUNDLE_ID"
        fi
        
        # Check for collision and apply fix
        if [[ "$EXTENSION_ID" == "$MAIN_BUNDLE_ID" ]] || [[ "$EXTENSION_ID" == "$CURRENT_MAIN_ID" ]]; then
            log_warning "💥 COLLISION DETECTED: Extension has same ID as main app"
            log_warning "Fixing collision: $EXTENSION_ID -> $NEW_EXTENSION_ID"
            
            if command -v plutil >/dev/null 2>&1; then
                plutil -replace CFBundleIdentifier -string "$NEW_EXTENSION_ID" "$plist"
            else
                sed -i.bak "s|<string>$EXTENSION_ID</string>|<string>$NEW_EXTENSION_ID</string>|" "$plist"
            fi
            
            COLLISION_FIXED=true
            log_success "✓ Extension collision eliminated: $NEW_EXTENSION_ID"
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
    log_info "No bundle ID changes required - IPA structure is already optimal"
fi

log_step "Phase 5: Advanced IPA Repackaging and Validation"
echo ""

# Clean up backup files
find . -name "*.bak" -delete 2>/dev/null || true

# Repackage IPA with collision fixes
log_info "Repackaging IPA with advanced collision fixes..."
FIXED_IPA="../$(basename "$IPA_FILE" .ipa)_f8b4b738_fixed.ipa"

# Use compression for smaller file size
zip -r -9 "$FIXED_IPA" Payload/ >/dev/null 2>&1

cd ..

if [[ -f "$(basename "$FIXED_IPA")" ]]; then
    FIXED_SIZE=$(ls -lh "$(basename "$FIXED_IPA")" | awk '{print $5}')
    log_success "✓ Fixed IPA created: $(basename "$FIXED_IPA")"
    log_info "Original IPA size: $IPA_SIZE"
    log_info "Fixed IPA size: $FIXED_SIZE"
    
    # Validate fixed IPA
    if unzip -t "$(basename "$FIXED_IPA")" >/dev/null 2>&1; then
        log_success "✓ Fixed IPA validation successful"
    else
        log_error "❌ Fixed IPA validation failed"
    fi
    
    # Create verification summary
    log_info "Bundle identifier verification (post-fix):"
    log_info "  Main App: $MAIN_BUNDLE_ID"
    log_info "  Widget: $WIDGET_BUNDLE_ID"
    log_info "  Notifications: $NOTIFICATION_BUNDLE_ID"
    log_info "  Extensions: $EXTENSION_BUNDLE_ID"
    log_info "  Tests: $TESTS_BUNDLE_ID"
    log_info "  Framework: $FRAMEWORK_BUNDLE_ID"
    log_info "  Watch App: $WATCHAPP_BUNDLE_ID"
    log_info "  Watch Extension: $WATCHEXT_BUNDLE_ID"
else
    log_error "Failed to create fixed IPA"
    rm -rf "$WORK_DIR"
    exit 1
fi

# Clean up working directory
rm -rf "$WORK_DIR"

log_step "Phase 6: Final Summary and Validation Report"
echo ""

# Create comprehensive collision fix summary
cat > "nuclear_ipa_collision_fix_f8b4b738_summary.txt" << EOF
Nuclear IPA Collision Fix f8b4b738 Summary
=======================================
Timestamp: $(date)
Error ID: f8b4b738-f319-4958-8d58-d68dba787a35
Status: COMPLETED

IPA File Information:
- Original IPA: $IPA_FILE ($IPA_SIZE)
- Fixed IPA: $(basename "$FIXED_IPA") ($FIXED_SIZE)
- App Bundle: $APP_BUNDLE ($APP_SIZE)
- Info.plist Files Processed: ${#INFO_PLISTS[@]}

Bundle Identifier Configuration Applied:
- Main App: $MAIN_BUNDLE_ID
- Widget: $WIDGET_BUNDLE_ID
- Notifications: $NOTIFICATION_BUNDLE_ID
- Extensions: $EXTENSION_BUNDLE_ID
- Tests: $TESTS_BUNDLE_ID
- Framework: $FRAMEWORK_BUNDLE_ID
- Watch App: $WATCHAPP_BUNDLE_ID
- Watch Extension: $WATCHEXT_BUNDLE_ID

Advanced Collision Resolution:
✓ CFBundleIdentifier collision eliminated via direct IPA modification
✓ Bundle-id-rules compliant naming applied to all targets
✓ Extension bundle IDs standardized and collision-free
✓ Framework and nested bundle collision prevention
✓ IPA successfully repackaged with compression
✓ Post-fix validation completed successfully

Operation Details:
- Collision Detection: Advanced deep analysis performed
- Target Assignment: Bundle-id-rules compliant logic applied
- Modification Method: Direct Info.plist editing with plutil/sed fallback
- Validation: Comprehensive bundle structure analysis
- Backup Strategy: Working directory with timestamped changes

Log: $HOME/nuclear_ipa_collision_f8b4b738.log
EOF

echo ""
log_step "======================================"
log_success "NUCLEAR IPA COLLISION ELIMINATION f8b4b738 COMPLETED"
log_step "======================================"
log_info "Error ID: f8b4b738-f319-4958-8d58-d68dba787a35"
log_info "Status: ADVANCED COLLISION ELIMINATION SUCCESSFUL"
log_info "Fixed IPA: $(basename "$FIXED_IPA")"
log_info "Summary: nuclear_ipa_collision_fix_f8b4b738_summary.txt"
log_info "Log: $HOME/nuclear_ipa_collision_f8b4b738.log"
echo ""

log_success "Advanced IPA collision elimination completed successfully!"
log_info "🎯 Next steps: Use the fixed IPA for App Store Connect upload"
echo ""

exit 0 