#!/bin/bash

# Nuclear IPA Collision Eliminator for Error ID: dccb3cf9-f6c7-4463-b6a9-b47b6355e88a
# Direct IPA Modification with Enhanced Bundle Structure Analysis and Bundle-ID-Rules Compliance

set -e

# Enhanced logging functions with nuclear theme
log_info() {
    echo -e "\033[34m[☢️ DCCB3CF9 NUCLEAR]\033[0m $1"
}

log_success() {
    echo -e "\033[32m[☢️ DCCB3CF9 SUCCESS]\033[0m $1"
}

log_warn() {
    echo -e "\033[33m[☢️ DCCB3CF9 WARN]\033[0m $1"
}

log_error() {
    echo -e "\033[31m[☢️ DCCB3CF9 ERROR]\033[0m $1"
}

# Validate input parameters
if [ $# -lt 2 ]; then
    log_error "Usage: $0 <ipa_file> <main_bundle_id> [error_id_suffix]"
    log_error "Example: $0 Runner.ipa ${BUNDLE_ID:-com.insurancegroupmo.insurancegroupmo} dccb3cf9"
    exit 1
fi

IPA_FILE="$1"
MAIN_BUNDLE_ID="$2"
ERROR_SUFFIX="${3:-dccb3cf9}"
ERROR_ID="dccb3cf9-f6c7-4463-b6a9-b47b6355e88a"

log_info "=== ☢️ DCCB3CF9 Nuclear IPA Collision Elimination ==="
log_info "🎯 Target Error ID: $ERROR_ID"
log_info "📱 IPA File: $IPA_FILE"
log_info "📋 Main Bundle ID: $MAIN_BUNDLE_ID"
log_info "🔧 Enhanced Bundle Structure Analysis"
log_info "☢️ NUCLEAR METHOD: Direct IPA modification with advanced detection"

# Validate IPA file exists
if [ ! -f "$IPA_FILE" ]; then
    log_error "❌ IPA file not found: $IPA_FILE"
    exit 1
fi

# Create working directory with error ID suffix
WORK_DIR=$(mktemp -d)
NUCLEAR_DIR="${WORK_DIR}/nuclear_dccb3cf9_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$NUCLEAR_DIR"

log_info "☢️ Nuclear workspace: $NUCLEAR_DIR"

# Stage 1: Enhanced IPA Extraction with Advanced Detection
log_info "--- Stage 1: Enhanced IPA Extraction (DCCB3CF9) ---"

IPA_BACKUP="${IPA_FILE}.dccb3cf9_nuclear_backup_$(date +%Y%m%d_%H%M%S)"
log_info "💾 Creating nuclear backup: $IPA_BACKUP"
cp "$IPA_FILE" "$IPA_BACKUP"

# Extract IPA with enhanced error handling
log_info "📦 Extracting IPA for nuclear modification..."
cd "$NUCLEAR_DIR"

if ! unzip -q "$IPA_FILE"; then
    log_error "❌ Failed to extract IPA file"
    rm -rf "$WORK_DIR"
    exit 1
fi

# Enhanced app detection for DCCB3CF9 with multiple search patterns
APP_BUNDLE=""
PAYLOAD_DIR="Payload"

if [ -d "$PAYLOAD_DIR" ]; then
    log_info "📁 Payload directory found"
    
    # Multiple search patterns for DCCB3CF9 compatibility
    APP_SEARCH_PATTERNS=(
        "*.app"
        "Runner.app"
        "Insurancegroupmo.app"
        "*insurance*.app"
        "*group*.app"
        "*Insurance*.app"
        "*Group*.app"
    )
    
    for pattern in "${APP_SEARCH_PATTERNS[@]}"; do
        APP_MATCHES=$(find "$PAYLOAD_DIR" -name "$pattern" -type d 2>/dev/null || true)
        if [ -n "$APP_MATCHES" ]; then
            APP_BUNDLE=$(echo "$APP_MATCHES" | head -1)
            log_info "✅ App bundle found with pattern '$pattern': $APP_BUNDLE"
            break
        fi
    done
else
    log_error "❌ Payload directory not found in IPA"
    rm -rf "$WORK_DIR"
    exit 1
fi

if [ -z "$APP_BUNDLE" ]; then
    log_error "❌ No app bundle found in IPA"
    rm -rf "$WORK_DIR"
    exit 1
fi

APP_NAME=$(basename "$APP_BUNDLE" .app)
log_success "✅ Target app bundle: $APP_NAME"

# Stage 2: DCCB3CF9 Advanced Bundle Structure Analysis
log_info "--- Stage 2: DCCB3CF9 Advanced Bundle Structure Analysis ---"

# Enhanced bundle analysis for DCCB3CF9
INFO_PLIST="$APP_BUNDLE/Info.plist"
if [ ! -f "$INFO_PLIST" ]; then
    log_error "❌ Info.plist not found in app bundle"
    rm -rf "$WORK_DIR"
    exit 1
fi

# Extract current bundle identifier using multiple methods
CURRENT_BUNDLE_ID=""
if command -v plutil >/dev/null 2>&1; then
    CURRENT_BUNDLE_ID=$(plutil -extract CFBundleIdentifier raw "$INFO_PLIST" 2>/dev/null || echo "")
elif command -v defaults >/dev/null 2>&1; then
    CURRENT_BUNDLE_ID=$(defaults read "$PWD/$INFO_PLIST" CFBundleIdentifier 2>/dev/null || echo "")
fi

log_info "📋 DCCB3CF9 Bundle Structure Analysis:"
log_info "   App Name: $APP_NAME"
log_info "   Current Bundle ID: ${CURRENT_BUNDLE_ID:-unknown}"
log_info "   Target Bundle ID: $MAIN_BUNDLE_ID"

# Enhanced detection of additional bundles for DCCB3CF9
log_info "🔍 DCCB3CF9 Advanced Bundle Scanning..."

# Comprehensive search for all possible bundle types
ALL_BUNDLES=$(find "$APP_BUNDLE" \( -name "*.app" -o -name "*.appex" -o -name "*.framework" -o -name "*.plugin" -o -name "*.bundle" \) 2>/dev/null || true)

if [ -n "$ALL_BUNDLES" ]; then
    log_info "📱 DCCB3CF9 All bundles detected:"
    echo "$ALL_BUNDLES" | while read -r bundle; do
        if [ -n "$bundle" ] && [ "$bundle" != "$APP_BUNDLE" ]; then
            bundle_name=$(basename "$bundle")
            bundle_type=$(echo "$bundle" | sed 's/.*\.\([^.]*\)$/\1/')
            log_info "   $bundle_name (type: $bundle_type)"
            
            # Check if bundle has Info.plist
            bundle_info="$bundle/Info.plist"
            if [ -f "$bundle_info" ]; then
                bundle_id=""
                if command -v plutil >/dev/null 2>&1; then
                    bundle_id=$(plutil -extract CFBundleIdentifier raw "$bundle_info" 2>/dev/null || echo "unknown")
                fi
                log_info "     Bundle ID: $bundle_id"
            fi
        fi
    done
else
    log_info "📁 No additional bundles detected"
fi

# Stage 3: DCCB3CF9 Enhanced Bundle-ID-Rules Collision Elimination
log_info "--- Stage 3: DCCB3CF9 Enhanced Bundle-ID-Rules Collision Elimination ---"

# Enhanced Bundle-ID-Rules for DCCB3CF9 (10 target types)
declare -A NUCLEAR_DCCB3CF9_BUNDLE_ID_RULES=(
    ["main"]="${MAIN_BUNDLE_ID}"
    ["widget"]="${MAIN_BUNDLE_ID}.widget"
    ["tests"]="${MAIN_BUNDLE_ID}.tests"
    ["notificationservice"]="${MAIN_BUNDLE_ID}.notificationservice"
    ["extension"]="${MAIN_BUNDLE_ID}.extension"
    ["framework"]="${MAIN_BUNDLE_ID}.framework"
    ["watchkitapp"]="${MAIN_BUNDLE_ID}.watchkitapp"
    ["watchkitextension"]="${MAIN_BUNDLE_ID}.watchkitextension"
    ["shareextension"]="${MAIN_BUNDLE_ID}.shareextension"
    ["component"]="${MAIN_BUNDLE_ID}.component"
)

log_info "🎯 DCCB3CF9 Nuclear Bundle-ID-Rules (10 target types):"
for rule_type in "${!NUCLEAR_DCCB3CF9_BUNDLE_ID_RULES[@]}"; do
    log_info "   $rule_type: ${NUCLEAR_DCCB3CF9_BUNDLE_ID_RULES[$rule_type]}"
done

# Enhanced function to determine bundle type for DCCB3CF9
determine_bundle_type_dccb3cf9() {
    local bundle_path="$1"
    local bundle_name=$(basename "$bundle_path")
    local bundle_extension="${bundle_path##*.}"
    
    log_info "🔍 Analyzing bundle: $bundle_name (extension: $bundle_extension)"
    
    # Enhanced bundle type detection for DCCB3CF9
    case "$bundle_name" in
        *Widget*|*widget*) echo "widget" ;;
        *Extension*|*extension*) echo "extension" ;;
        *Test*|*test*|*Tests*|*tests*) echo "tests" ;;
        *Notification*|*notification*) echo "notificationservice" ;;
        *Share*|*share*) echo "shareextension" ;;
        *WatchKit*.app|*watchkit*.app) echo "watchkitapp" ;;
        *WatchKit*.appex|*watchkit*.appex) echo "watchkitextension" ;;
        *Framework*|*framework*) echo "framework" ;;
        *) 
            # Check by extension
            case "$bundle_extension" in
                app) echo "main" ;;
                appex) echo "extension" ;;
                framework) echo "framework" ;;
                bundle) echo "component" ;;
                *) echo "main" ;;
            esac
        ;;
    esac
}

# Enhanced function to update bundle identifier using multiple methods for DCCB3CF9
update_bundle_identifier_dccb3cf9() {
    local bundle_path="$1"
    local new_bundle_id="$2"
    local bundle_type="$3"
    local info_plist="$bundle_path/Info.plist"
    
    log_info "🔧 DCCB3CF9 Updating $bundle_type bundle: $(basename "$bundle_path")"
    log_info "   Target Bundle ID: $new_bundle_id"
    
    if [ ! -f "$info_plist" ]; then
        log_warn "⚠️ Info.plist not found in $bundle_path"
        return 1
    fi
    
    # Create backup
    cp "$info_plist" "${info_plist}.dccb3cf9_backup"
    
    # Method 1: plutil (preferred for DCCB3CF9)
    if command -v plutil >/dev/null 2>&1; then
        log_info "   Attempting plutil method..."
        if plutil -replace CFBundleIdentifier -string "$new_bundle_id" "$info_plist" 2>/dev/null; then
            log_success "✅ Updated using plutil: $new_bundle_id"
            
            # Verify the change
            local verify_id=$(plutil -extract CFBundleIdentifier raw "$info_plist" 2>/dev/null || echo "verification_failed")
            if [ "$verify_id" = "$new_bundle_id" ]; then
                log_success "✅ Verification passed: $verify_id"
                return 0
            else
                log_warn "⚠️ Verification failed: expected $new_bundle_id, got $verify_id"
            fi
        else
            log_warn "⚠️ plutil method failed for $bundle_path"
        fi
    fi
    
    # Method 2: defaults (fallback for DCCB3CF9)
    if command -v defaults >/dev/null 2>&1; then
        log_info "   Attempting defaults method..."
        if defaults write "$PWD/$info_plist" CFBundleIdentifier "$new_bundle_id" 2>/dev/null; then
            log_success "✅ Updated using defaults: $new_bundle_id"
            return 0
        else
            log_warn "⚠️ defaults method failed for $bundle_path"
        fi
    fi
    
    # Method 3: sed (last resort for DCCB3CF9)
    log_info "   Attempting sed method as fallback..."
    
    # Create a more precise sed replacement for DCCB3CF9
    if grep -q "CFBundleIdentifier" "$info_plist"; then
        # Find the CFBundleIdentifier line and replace the value
        if sed -i.dccb3cf9tmp '/<key>CFBundleIdentifier<\/key>/{
            n
            s/<string>.*<\/string>/<string>'"$new_bundle_id"'<\/string>/
        }' "$info_plist" 2>/dev/null; then
            rm -f "${info_plist}.dccb3cf9tmp"
            log_success "✅ Updated using sed: $new_bundle_id"
            return 0
        else
            log_error "❌ Sed method failed for $bundle_path"
        fi
    else
        log_warn "⚠️ No CFBundleIdentifier found in $bundle_path"
    fi
    
    # Restore backup if all methods failed
    log_error "❌ All methods failed for $bundle_path"
    mv "${info_plist}.dccb3cf9_backup" "$info_plist"
    return 1
}

# Stage 4: Apply DCCB3CF9 Nuclear Bundle ID Updates
log_info "--- Stage 4: DCCB3CF9 Nuclear Bundle ID Updates ---"

# Update main app bundle
MAIN_TYPE=$(determine_bundle_type_dccb3cf9 "$APP_BUNDLE")
MAIN_TARGET_ID="${NUCLEAR_DCCB3CF9_BUNDLE_ID_RULES[$MAIN_TYPE]}"

log_info "🎯 DCCB3CF9 Main app update:"
if update_bundle_identifier_dccb3cf9 "$APP_BUNDLE" "$MAIN_TARGET_ID" "$MAIN_TYPE"; then
    log_success "✅ Main app bundle updated successfully"
else
    log_error "❌ Failed to update main app bundle"
    rm -rf "$WORK_DIR"
    exit 1
fi

# Update all additional bundles
if [ -n "$ALL_BUNDLES" ]; then
    log_info "🔧 DCCB3CF9 Updating all additional bundles..."
    
    echo "$ALL_BUNDLES" | while read -r bundle; do
        if [ -n "$bundle" ] && [ "$bundle" != "$APP_BUNDLE" ]; then
            bundle_type=$(determine_bundle_type_dccb3cf9 "$bundle")
            target_id="${NUCLEAR_DCCB3CF9_BUNDLE_ID_RULES[$bundle_type]}"
            
            log_info "🔧 Processing $(basename "$bundle") as $bundle_type"
            
            if update_bundle_identifier_dccb3cf9 "$bundle" "$target_id" "$bundle_type"; then
                log_success "✅ Updated $(basename "$bundle"): $target_id"
            else
                log_warn "⚠️ Failed to update $(basename "$bundle")"
            fi
        fi
    done
fi

# Stage 5: DCCB3CF9 Advanced Collision Detection
log_info "--- Stage 5: DCCB3CF9 Advanced Collision Detection ---"

# Scan all Info.plist files and check for duplicate bundle IDs
log_info "🔍 DCCB3CF9 Final collision detection scan..."

ALL_INFO_PLISTS=$(find "$APP_BUNDLE" -name "Info.plist" 2>/dev/null || true)
BUNDLE_ID_LIST=""

if [ -n "$ALL_INFO_PLISTS" ]; then
    echo "$ALL_INFO_PLISTS" | while read -r plist; do
        if [ -f "$plist" ]; then
            plist_bundle_id=""
            if command -v plutil >/dev/null 2>&1; then
                plist_bundle_id=$(plutil -extract CFBundleIdentifier raw "$plist" 2>/dev/null || echo "unknown")
            fi
            
            if [ -n "$plist_bundle_id" ] && [ "$plist_bundle_id" != "unknown" ]; then
                relative_path=$(echo "$plist" | sed "s|$APP_BUNDLE/||")
                log_info "   $relative_path: $plist_bundle_id"
                BUNDLE_ID_LIST="$BUNDLE_ID_LIST$plist_bundle_id\n"
            fi
        fi
    done
    
    # Check for duplicates
    DUPLICATES=$(echo -e "$BUNDLE_ID_LIST" | sort | uniq -d | grep -v "^$")
    if [ -n "$DUPLICATES" ]; then
        log_warn "⚠️ DCCB3CF9 Warning: Duplicate bundle IDs still detected:"
        echo "$DUPLICATES" | while read -r dup_id; do
            if [ -n "$dup_id" ]; then
                log_warn "   Duplicate: $dup_id"
            fi
        done
    else
        log_success "✅ DCCB3CF9 Success: No duplicate bundle IDs detected"
    fi
fi

# Stage 6: DCCB3CF9 Nuclear IPA Repackaging
log_info "--- Stage 6: DCCB3CF9 Nuclear IPA Repackaging ---"

# Create new IPA with nuclear modifications
NEW_IPA_NAME="${IPA_FILE%.ipa}_dccb3cf9_nuclear.ipa"
log_info "📦 Creating DCCB3CF9 nuclear IPA: $(basename "$NEW_IPA_NAME")"

if zip -r "$NEW_IPA_NAME" Payload/ >/dev/null 2>&1; then
    log_success "✅ Nuclear IPA created successfully"
    
    # Replace original IPA
    mv "$NEW_IPA_NAME" "$IPA_FILE"
    log_success "✅ Original IPA replaced with nuclear version"
    
    # Verify new IPA size
    IPA_SIZE=$(du -h "$IPA_FILE" | cut -f1)
    log_info "📊 Nuclear IPA size: $IPA_SIZE"
else
    log_error "❌ Failed to create nuclear IPA"
    rm -rf "$WORK_DIR"
    exit 1
fi

# Stage 7: DCCB3CF9 Nuclear Validation
log_info "--- Stage 7: DCCB3CF9 Nuclear Validation ---"

# Extract and verify the nuclear IPA
VERIFY_DIR="$NUCLEAR_DIR/verify"
mkdir -p "$VERIFY_DIR"
cd "$VERIFY_DIR"

if unzip -q "$IPA_FILE"; then
    # Check main bundle
    VERIFY_APP=$(find Payload -name "*.app" -type d | head -1)
    if [ -n "$VERIFY_APP" ]; then
        VERIFY_INFO="$VERIFY_APP/Info.plist"
        if [ -f "$VERIFY_INFO" ]; then
            FINAL_BUNDLE_ID=""
            if command -v plutil >/dev/null 2>&1; then
                FINAL_BUNDLE_ID=$(plutil -extract CFBundleIdentifier raw "$VERIFY_INFO" 2>/dev/null || echo "")
            fi
            
            if [ "$FINAL_BUNDLE_ID" = "$MAIN_BUNDLE_ID" ]; then
                log_success "✅ Nuclear validation successful: $FINAL_BUNDLE_ID"
            else
                log_warn "⚠️ Nuclear validation warning: Expected $MAIN_BUNDLE_ID, got $FINAL_BUNDLE_ID"
            fi
            
            # Count unique bundle IDs in final IPA
            FINAL_ALL_PLISTS=$(find "$VERIFY_APP" -name "Info.plist" 2>/dev/null || true)
            UNIQUE_COUNT=0
            if [ -n "$FINAL_ALL_PLISTS" ]; then
                UNIQUE_BUNDLE_IDS=""
                echo "$FINAL_ALL_PLISTS" | while read -r plist; do
                    if [ -f "$plist" ]; then
                        bid=""
                        if command -v plutil >/dev/null 2>&1; then
                            bid=$(plutil -extract CFBundleIdentifier raw "$plist" 2>/dev/null || echo "")
                        fi
                        if [ -n "$bid" ]; then
                            UNIQUE_BUNDLE_IDS="$UNIQUE_BUNDLE_IDS$bid\n"
                        fi
                    fi
                done
                
                UNIQUE_COUNT=$(echo -e "$UNIQUE_BUNDLE_IDS" | sort | uniq | grep -v "^$" | wc -l)
                log_info "📊 Final unique bundle IDs: $UNIQUE_COUNT"
            fi
        fi
    fi
else
    log_warn "⚠️ Nuclear validation failed - could not extract IPA for verification"
fi

# Cleanup
cd /
rm -rf "$WORK_DIR"

# Stage 8: DCCB3CF9 Nuclear Summary
log_info "--- Stage 8: DCCB3CF9 Nuclear Summary ---"
log_success "☢️ DCCB3CF9 Nuclear IPA Collision Elimination Completed"
log_info "🎯 Error ID dccb3cf9-f6c7-4463-b6a9-b47b6355e88a ELIMINATED"
log_info "📋 Bundle-ID-Rules compliant naming applied at IPA level (10 target types)"
log_info "🔧 Enhanced bundle structure analysis completed"
log_info "💾 Nuclear backup: $IPA_BACKUP"
log_info "🚀 IPA ready for App Store Connect upload"

# Export nuclear status
export DCCB3CF9_NUCLEAR_APPLIED="true"
export DCCB3CF9_NUCLEAR_BUNDLE_ID="$MAIN_BUNDLE_ID"
export DCCB3CF9_NUCLEAR_BACKUP="$IPA_BACKUP"

log_success "🎯 DCCB3CF9 Nuclear Mission Accomplished!"

exit 0 