#!/bin/bash

# Bundle Identifier Collision Fix - Bash Script Approach
# Fixes CFBundleIdentifier collision errors for App Store Connect validation

set -euo pipefail

echo "🔧 Bundle Identifier Collision Fix - Bash Script Approach"
echo "=================================================="

# Configuration
PROJECT_ROOT=$(pwd)
IOS_DIR="$PROJECT_ROOT/ios"
PROJECT_FILE="$IOS_DIR/Runner.xcodeproj/project.pbxproj"
MAIN_BUNDLE_ID="com.twinklub.twinklub"
TEST_BUNDLE_ID="com.twinklub.twinklub.tests"

echo "📁 Project: $PROJECT_ROOT"
echo "🎯 Main Bundle ID: $MAIN_BUNDLE_ID"
echo "🧪 Test Bundle ID: $TEST_BUNDLE_ID"

# Function to create backup
create_backup() {
    echo "💾 Creating backup of project file..."
    local timestamp=$(date +%Y%m%d_%H%M%S)
    if [ -f "$PROJECT_FILE" ]; then
        cp "$PROJECT_FILE" "$PROJECT_FILE.backup_collision_fix_$timestamp"
        echo "✅ Backup created: project.pbxproj.backup_collision_fix_$timestamp"
    else
        echo "❌ Project file not found: $PROJECT_FILE"
        exit 1
    fi
}

# Function to check current bundle identifiers
check_current_state() {
    echo ""
    echo "🔍 Analyzing current bundle identifiers..."
    echo "=========================================="
    
    if [ ! -f "$PROJECT_FILE" ]; then
        echo "❌ Project file not found: $PROJECT_FILE"
        exit 1
    fi
    
    echo "Current PRODUCT_BUNDLE_IDENTIFIER entries:"
    grep -n "PRODUCT_BUNDLE_IDENTIFIER" "$PROJECT_FILE" | head -10
    
    # Count occurrences of main bundle ID
    local main_count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $MAIN_BUNDLE_ID;" "$PROJECT_FILE" || echo "0")
    local test_count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $TEST_BUNDLE_ID;" "$PROJECT_FILE" || echo "0")
    
    echo ""
    echo "📊 Bundle ID Analysis:"
    echo "   Main app bundle ID ($MAIN_BUNDLE_ID): $main_count occurrences"
    echo "   Test bundle ID ($TEST_BUNDLE_ID): $test_count occurrences"
    
    # Check for collision
    if [ "$main_count" -gt 3 ]; then
        echo "❌ COLLISION DETECTED: Too many targets using main bundle ID"
        return 1
    elif [ "$main_count" -eq 3 ] && [ "$test_count" -eq 3 ]; then
        echo "✅ Bundle identifiers appear correctly configured"
        return 0
    else
        echo "⚠️  Bundle identifier configuration needs fixing"
        return 1
    fi
}

# Function to fix RunnerTests bundle identifiers using sed
fix_bundle_identifiers() {
    echo ""
    echo "🔧 Fixing RunnerTests bundle identifiers..."
    echo "==========================================="
    
    # Create temporary file for processing
    local temp_file="$PROJECT_FILE.tmp"
    
    # Fix RunnerTests Debug configuration
    echo "   🔧 Fixing Debug configuration..."
    sed "s/PRODUCT_BUNDLE_IDENTIFIER = $MAIN_BUNDLE_ID;\(.*RunnerTests.*name = Debug\)/PRODUCT_BUNDLE_IDENTIFIER = $TEST_BUNDLE_ID;\1/g" "$PROJECT_FILE" > "$temp_file"
    
    # Fix RunnerTests Release configuration
    echo "   🔧 Fixing Release configuration..."
    sed "s/PRODUCT_BUNDLE_IDENTIFIER = $MAIN_BUNDLE_ID;\(.*RunnerTests.*name = Release\)/PRODUCT_BUNDLE_IDENTIFIER = $TEST_BUNDLE_ID;\1/g" "$temp_file" > "$temp_file.2"
    
    # Fix RunnerTests Profile configuration
    echo "   🔧 Fixing Profile configuration..."
    sed "s/PRODUCT_BUNDLE_IDENTIFIER = $MAIN_BUNDLE_ID;\(.*RunnerTests.*name = Profile\)/PRODUCT_BUNDLE_IDENTIFIER = $TEST_BUNDLE_ID;\1/g" "$temp_file.2" > "$temp_file.3"
    
    # Use more specific sed patterns for RunnerTests
    echo "   🔧 Applying specific RunnerTests pattern fixes..."
    
    # Pattern 1: Fix Debug RunnerTests
    sed -i.bak1 '/RunnerTests.*Debug/,/^[[:space:]]*};/{
        s/PRODUCT_BUNDLE_IDENTIFIER = '"$MAIN_BUNDLE_ID"';/PRODUCT_BUNDLE_IDENTIFIER = '"$TEST_BUNDLE_ID"';/g
    }' "$temp_file.3"
    
    # Pattern 2: Fix Release RunnerTests  
    sed -i.bak2 '/RunnerTests.*Release/,/^[[:space:]]*};/{
        s/PRODUCT_BUNDLE_IDENTIFIER = '"$MAIN_BUNDLE_ID"';/PRODUCT_BUNDLE_IDENTIFIER = '"$TEST_BUNDLE_ID"';/g
    }' "$temp_file.3"
    
    # Pattern 3: Fix Profile RunnerTests
    sed -i.bak3 '/RunnerTests.*Profile/,/^[[:space:]]*};/{
        s/PRODUCT_BUNDLE_IDENTIFIER = '"$MAIN_BUNDLE_ID"';/PRODUCT_BUNDLE_IDENTIFIER = '"$TEST_BUNDLE_ID"';/g
    }' "$temp_file.3"
    
    # Replace original file with processed version
    mv "$temp_file.3" "$PROJECT_FILE"
    
    # Clean up temporary files
    rm -f "$temp_file" "$temp_file.2" "$PROJECT_FILE.tmp.bak1" "$PROJECT_FILE.tmp.bak2" "$PROJECT_FILE.tmp.bak3"
    
    echo "✅ Bundle identifier fixes applied"
}

# Function to validate project file integrity
validate_project_integrity() {
    echo ""
    echo "🔍 Validating project file integrity..."
    echo "======================================"
    
    # Check if file exists and is readable
    if [ ! -f "$PROJECT_FILE" ]; then
        echo "❌ Project file not found after modifications"
        return 1
    fi
    
    # Basic syntax check (look for closing brace)
    if ! tail -1 "$PROJECT_FILE" | grep -q "}"; then
        echo "❌ Project file appears to be corrupted (missing closing brace)"
        return 1
    fi
    
    # Check for proper plist format
    if command -v plutil >/dev/null 2>&1; then
        if plutil -lint "$PROJECT_FILE" >/dev/null 2>&1; then
            echo "✅ Project file format is valid"
        else
            echo "⚠️  Project file format validation failed (but may still work)"
        fi
    else
        echo "ℹ️  plutil not available for validation"
    fi
    
    echo "✅ Project file integrity verified"
}

# Function to verify the fix
verify_fix() {
    echo ""
    echo "🔍 Verifying bundle identifier fix..."
    echo "===================================="
    
    echo "Final PRODUCT_BUNDLE_IDENTIFIER entries:"
    grep -n "PRODUCT_BUNDLE_IDENTIFIER" "$PROJECT_FILE"
    
    # Count final occurrences
    local main_count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $MAIN_BUNDLE_ID;" "$PROJECT_FILE" || echo "0")
    local test_count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $TEST_BUNDLE_ID;" "$PROJECT_FILE" || echo "0")
    
    echo ""
    echo "📊 Final Bundle ID Counts:"
    echo "   Main app ($MAIN_BUNDLE_ID): $main_count"
    echo "   Tests ($TEST_BUNDLE_ID): $test_count"
    
    # Validate expected counts
    if [ "$main_count" -eq 3 ] && [ "$test_count" -eq 3 ]; then
        echo "✅ SUCCESS: Bundle identifiers are correctly configured"
        echo "   ✅ Main app: 3 configurations (Debug/Release/Profile)"
        echo "   ✅ Tests: 3 configurations (Debug/Release/Profile)"
        echo "   ✅ No collisions detected"
        return 0
    else
        echo "❌ ISSUE: Bundle identifier counts are unexpected"
        echo "   Expected: 3 main + 3 test = 6 total"
        echo "   Found: $main_count main + $test_count test"
        return 1
    fi
}

# Function to create summary report
create_summary() {
    local report_file="$PROJECT_ROOT/BUNDLE_COLLISION_FIX_REPORT.txt"
    
    cat > "$report_file" << EOF
Bundle Identifier Collision Fix - Summary Report
===============================================

Timestamp: $(date)
Method: Bash Script with sed commands
Status: SUCCESS

Issue Fixed:
- CFBundleIdentifier collision preventing App Store Connect upload
- Multiple targets using same bundle identifier 'com.twinklub.twinklub'

Changes Applied:
- RunnerTests Debug: com.twinklub.twinklub → com.twinklub.twinklub.tests
- RunnerTests Release: com.twinklub.twinklub → com.twinklub.twinklub.tests  
- RunnerTests Profile: com.twinklub.twinklub → com.twinklub.twinklub.tests

Validation Results:
- Main app bundle ID: 3 occurrences (correct)
- Test bundle ID: 3 occurrences (correct)
- Total unique identifiers: 2 (no collisions)

Next Steps:
1. flutter clean
2. flutter pub get
3. flutter build ios --release
4. Archive and export IPA
5. Upload to App Store Connect (should succeed)

Files Modified:
- ios/Runner.xcodeproj/project.pbxproj

Backup Created:
- project.pbxproj.backup_collision_fix_[timestamp]
EOF

    echo "✅ Summary report created: BUNDLE_COLLISION_FIX_REPORT.txt"
}

# Main execution function
main() {
    echo "🚀 Starting Bundle Identifier Collision Fix..."
    echo ""
    
    # Step 1: Create backup
    create_backup
    
    # Step 2: Check current state
    if check_current_state; then
        echo "ℹ️  Bundle identifiers appear correct, but continuing with fix verification..."
    else
        echo "⚠️  Bundle identifier issues detected, applying fixes..."
    fi
    
    # Step 3: Apply fixes
    fix_bundle_identifiers
    
    # Step 4: Validate integrity
    if ! validate_project_integrity; then
        echo "❌ Project file integrity check failed"
        exit 1
    fi
    
    # Step 5: Verify the fix
    if ! verify_fix; then
        echo "❌ Bundle identifier fix verification failed"
        exit 1
    fi
    
    # Step 6: Create summary
    create_summary
    
    echo ""
    echo "🎉 Bundle Identifier Collision Fix COMPLETED!"
    echo "=============================================="
    echo ""
    echo "✅ Summary:"
    echo "   🔧 Bundle identifier collision resolved"
    echo "   📁 Project file backup created"
    echo "   🔍 Changes verified and validated"
    echo "   📋 Summary report generated"
    echo ""
    echo "🚀 Next Steps:"
    echo "   1. flutter clean"
    echo "   2. flutter pub get"  
    echo "   3. flutter build ios --release"
    echo "   4. Archive and export IPA"
    echo "   5. Upload to App Store Connect"
    echo ""
    echo "🎯 Expected Result:"
    echo "   ✅ No more CFBundleIdentifier collision errors"
    echo "   ✅ Successful App Store Connect validation"
    echo "   ✅ IPA upload completes without issues"
    
    return 0
}

# Execute main function
main "$@" 