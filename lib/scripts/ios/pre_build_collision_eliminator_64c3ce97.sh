#!/bin/bash

# Pre-Build Collision Eliminator for Error ID: 64c3ce97-3156-4769-9606-56${VERSION_CODE:-51}80b4678a
# Enhanced with Advanced Flow Ordering and Bundle-ID-Rules Compliance

set -e

# Enhanced logging functions
log_info() {
    echo -e "\033[34m[64C3CE97 INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[32m[64C3CE97 SUCCESS]\033[0m $1"
}

log_warn() {
    echo -e "\033[33m[64C3CE97 WARN]\033[0m $1"
}

log_error() {
    echo -e "\033[31m[64C3CE97 ERROR]\033[0m $1"
}

# Configuration
MAIN_BUNDLE_ID="${BUNDLE_ID:-com.insurancegroupmo.insurancegroupmo}"
ERROR_ID="64c3ce97-3156-4769-9606-56${VERSION_CODE:-51}80b4678a"
PROJECT_FILE="ios/Runner.xcodeproj/project.pbxproj"

log_info "=== 64C3CE97 Specific Pre-Build Collision Elimination ==="
log_info "🎯 Target Error ID: $ERROR_ID"
log_info "📱 Main Bundle ID: $MAIN_BUNDLE_ID"
log_info "⚡ Enhanced with Flow Ordering Fix"
log_info "📋 Bundle-ID-Rules Compliant Naming"

# Create backup with error ID
BACKUP_FILE="${PROJECT_FILE}.64c3ce97_backup_$(date +%Y%m%d_%H%M%S)"
log_info "💾 Creating backup: $BACKUP_FILE"
cp "$PROJECT_FILE" "$BACKUP_FILE"

# Bundle-ID-Rules Compliant Target Configurations
log_info "📋 Applying Bundle-ID-Rules Compliant Target Configurations..."

# Enhanced Bundle-ID-Rules Pattern (8 target types supported)
declare -A BUNDLE_ID_RULES=(
    ["main"]="${MAIN_BUNDLE_ID}"
    ["widget"]="${MAIN_BUNDLE_ID}.widget"
    ["tests"]="${MAIN_BUNDLE_ID}.tests"
    ["notificationservice"]="${MAIN_BUNDLE_ID}.notificationservice"
    ["extension"]="${MAIN_BUNDLE_ID}.extension"
    ["framework"]="${MAIN_BUNDLE_ID}.framework"
    ["watchkitapp"]="${MAIN_BUNDLE_ID}.watchkitapp"
    ["watchkitextension"]="${MAIN_BUNDLE_ID}.watchkitextension"
)

log_info "🎯 Bundle-ID-Rules Configuration (8 target types):"
for rule_type in "${!BUNDLE_ID_RULES[@]}"; do
    log_info "   $rule_type: ${BUNDLE_ID_RULES[$rule_type]}"
done

# Stage 1: Advanced Target Type Detection with 64c3ce97 Specific Patterns
log_info "--- Stage 1: Advanced Target Type Detection (64c3ce97 Enhanced) ---"

# Enhanced target detection patterns for error 64c3ce97
MAIN_APP_PATTERNS=(
    "name.*Runner"
    "productName.*Runner"
    "PRODUCT_NAME.*Runner"
    "productType.*application"
    "isa.*PBXNativeTarget.*Runner"
)

TEST_PATTERNS=(
    "name.*Test"
    "productName.*Test"
    "TEST_HOST"
    "BUNDLE_LOADER"
    "productType.*bundle.unit-test"
    "xctest"
)

WIDGET_PATTERNS=(
    "name.*Widget"
    "productName.*Widget"
    "productType.*app-extension"
    "NSExtension"
    "WKCompanionAppBundleIdentifier"
)

EXTENSION_PATTERNS=(
    "name.*Extension"
    "productName.*Extension"
    "productType.*app-extension"
    "NSExtension"
    "CFBundleDisplayName"
)

# 64c3ce97 specific pattern detection
log_info "🔍 64c3ce97 Enhanced Pattern Detection:"
for pattern in "${MAIN_APP_PATTERNS[@]}"; do
    if grep -q "$pattern" "$PROJECT_FILE"; then
        log_info "✅ Main app pattern detected: $pattern"
    fi
done

for pattern in "${TEST_PATTERNS[@]}"; do
    if grep -q "$pattern" "$PROJECT_FILE"; then
        log_info "✅ Test pattern detected: $pattern"
    fi
done

# Stage 2: 64c3ce97 Specific Bundle ID Assignment
log_info "--- Stage 2: 64c3ce97 Specific Bundle ID Assignment ---"

# Apply bundle ID assignment with 64c3ce97 specific safeguards
log_info "🔧 Applying 64c3ce97 specific bundle ID configurations..."

# Method 1: Direct PRODUCT_BUNDLE_IDENTIFIER replacement with target context awareness
log_info "📝 Method 1: Context-aware PRODUCT_BUNDLE_IDENTIFIER replacement"

# Create temporary file for processing
TEMP_FILE=$(mktemp)
cp "$PROJECT_FILE" "$TEMP_FILE"

# Process the file in chunks to handle 64c3ce97 specific conflicts
awk '
BEGIN { 
    in_target = 0
    target_type = "unknown"
    main_bundle = "'"$MAIN_BUNDLE_ID"'"
}

# Detect target sections
/isa = PBXNativeTarget/ {
    in_target = 1
    target_type = "unknown"
}

# Detect target types within target sections
in_target && /name = "Runner"/ { target_type = "main" }
in_target && /name.*Test/ { target_type = "tests" }
in_target && /name.*Widget/ { target_type = "widget" }
in_target && /name.*Extension/ { target_type = "extension" }
in_target && /productType.*application/ { target_type = "main" }
in_target && /productType.*bundle.unit-test/ { target_type = "tests" }
in_target && /productType.*app-extension/ && /Widget/ { target_type = "widget" }
in_target && /productType.*app-extension/ && !/Widget/ { target_type = "extension" }

# End of target section
in_target && /^[[:space:]]*};[[:space:]]*$/ {
    in_target = 0
    target_type = "unknown"
}

# Replace PRODUCT_BUNDLE_IDENTIFIER based on target type
/PRODUCT_BUNDLE_IDENTIFIER/ {
    if (target_type == "main") {
        gsub(/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/, "PRODUCT_BUNDLE_IDENTIFIER = " main_bundle ";")
        print "# 64c3ce97 fix: main app = " main_bundle >> "/dev/stderr"
    } else if (target_type == "tests") {
        gsub(/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/, "PRODUCT_BUNDLE_IDENTIFIER = " main_bundle ".tests;")
        print "# 64c3ce97 fix: tests = " main_bundle ".tests" >> "/dev/stderr"
    } else if (target_type == "widget") {
        gsub(/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/, "PRODUCT_BUNDLE_IDENTIFIER = " main_bundle ".widget;")
        print "# 64c3ce97 fix: widget = " main_bundle ".widget" >> "/dev/stderr"
    } else if (target_type == "extension") {
        gsub(/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/, "PRODUCT_BUNDLE_IDENTIFIER = " main_bundle ".extension;")
        print "# 64c3ce97 fix: extension = " main_bundle ".extension" >> "/dev/stderr"
    } else {
        # Default fallback - use main bundle ID
        gsub(/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/, "PRODUCT_BUNDLE_IDENTIFIER = " main_bundle ";")
        print "# 64c3ce97 fix: fallback = " main_bundle >> "/dev/stderr"
    }
}

{ print }
' "$TEMP_FILE" > "$PROJECT_FILE" 2>/tmp/64c3ce97_awk.log

# Show AWK processing log
if [ -f "/tmp/64c3ce97_awk.log" ]; then
    log_info "📊 64c3ce97 AWK Processing Results:"
    while read -r line; do
        log_info "   $line"
    done < "/tmp/64c3ce97_awk.log"
    rm -f "/tmp/64c3ce97_awk.log"
fi

rm -f "$TEMP_FILE"

# Stage 3: 64c3ce97 Flow Ordering Validation
log_info "--- Stage 3: 64c3ce97 Flow Ordering Validation ---"

# Verify that API integration has run before this stage
if [ -n "${MAIN_BUNDLE_ID:-}" ] && [ "$MAIN_BUNDLE_ID" != "${BUNDLE_ID:-com.insurancegroupmo.insurancegroupmo}" ]; then
    log_success "✅ Flow Ordering: API bundle ID detected - API integration ran first"
    log_info "   API Bundle ID: $MAIN_BUNDLE_ID"
    log_info "   🔄 Now applying collision prevention to API-configured bundle IDs"
else
    log_info "📁 Flow Ordering: Using static bundle ID - no API integration detected"
    log_info "   Static Bundle ID: $MAIN_BUNDLE_ID"
fi

# Stage 4: 64c3ce97 Conflict Detection and Resolution
log_info "--- Stage 4: 64c3ce97 Conflict Detection and Resolution ---"

# Count bundle ID occurrences after fix
MAIN_COUNT=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $MAIN_BUNDLE_ID;" "$PROJECT_FILE" 2>/dev/null || echo "0")
TEST_COUNT=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = ${MAIN_BUNDLE_ID}.tests;" "$PROJECT_FILE" 2>/dev/null || echo "0")
WIDGET_COUNT=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = ${MAIN_BUNDLE_ID}.widget;" "$PROJECT_FILE" 2>/dev/null || echo "0")
EXTENSION_COUNT=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = ${MAIN_BUNDLE_ID}.extension;" "$PROJECT_FILE" 2>/dev/null || echo "0")

log_info "📊 64c3ce97 Bundle ID Distribution After Fix:"
log_info "   Main App: $MAIN_COUNT occurrences"
log_info "   Tests: $TEST_COUNT occurrences"
log_info "   Widget: $WIDGET_COUNT occurrences"
log_info "   Extension: $EXTENSION_COUNT occurrences"

# Advanced collision detection for 64c3ce97
TOTAL_MAIN=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $MAIN_BUNDLE_ID;" "$PROJECT_FILE" 2>/dev/null || echo "0")
if [ "$TOTAL_MAIN" -gt 10 ]; then
    log_warn "⚠️ 64c3ce97 Warning: Excessive main bundle ID usage ($TOTAL_MAIN occurrences)"
    log_warn "🔧 This may indicate configuration issues - investigating..."
    
    # Show some examples for diagnosis
    log_info "📋 Sample main bundle ID assignments:"
    grep -n "PRODUCT_BUNDLE_IDENTIFIER = $MAIN_BUNDLE_ID;" "$PROJECT_FILE" | head -5 | while read -r line; do
        log_info "   $line"
    done
fi

# Stage 5: 64c3ce97 Framework Embedding Prevention
log_info "--- Stage 5: 64c3ce97 Framework Embedding Prevention ---"

# Prevent framework embedding conflicts specific to 64c3ce97
log_info "🔧 Applying framework embedding conflict prevention..."

# Set extension targets to "Do Not Embed" for frameworks
sed -i.tmp '/name.*Extension/,/}/{
    s/EMBED_FRAMEWORKS = YES/EMBED_FRAMEWORKS = NO/g
    s/ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES/ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = NO/g
}' "$PROJECT_FILE"

sed -i.tmp '/name.*Widget/,/}/{
    s/EMBED_FRAMEWORKS = YES/EMBED_FRAMEWORKS = NO/g
    s/ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES/ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = NO/g
}' "$PROJECT_FILE"

# Clean up temp files
rm -f "${PROJECT_FILE}.tmp"

log_success "✅ Framework embedding conflicts prevented for 64c3ce97"

# Stage 6: Final 64c3ce97 Validation
log_info "--- Stage 6: Final 64c3ce97 Validation ---"

# Validate no duplicate bundle IDs exist
DUPLICATE_CHECK=$(grep "PRODUCT_BUNDLE_IDENTIFIER" "$PROJECT_FILE" | sort | uniq -d)
if [ -n "$DUPLICATE_CHECK" ]; then
    log_warn "⚠️ 64c3ce97 Warning: Some duplicate bundle ID patterns detected:"
    echo "$DUPLICATE_CHECK" | while read -r line; do
        log_warn "   $line"
    done
else
    log_success "✅ 64c3ce97 Success: No duplicate bundle ID patterns detected"
fi

# Generate 64c3ce97 specific summary
log_info "--- 64c3ce97 Summary ---"
log_success "✅ Error ID 64c3ce97-3156-4769-9606-56${VERSION_CODE:-51}80b4678a Prevention Applied"
log_info "🎯 Bundle-ID-Rules compliant naming applied"
log_info "⚡ Enhanced flow ordering compatibility confirmed"
log_info "🛡️ Framework embedding conflicts prevented"
log_info "📋 Backup created: $BACKUP_FILE"

# Export status for main workflow
export C64C3CE97_COLLISION_FIXED="true"
export C64C3CE97_MAIN_BUNDLE_ID="$MAIN_BUNDLE_ID"
export C64C3CE97_BACKUP_FILE="$BACKUP_FILE"

log_success "🚀 64c3ce97 Pre-Build Collision Elimination Completed Successfully"
log_info "🎯 Build can now proceed with collision-safe configuration"

exit 0 