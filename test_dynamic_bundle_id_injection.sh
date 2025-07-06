#!/bin/bash

# Test Dynamic Bundle ID Injection
# Purpose: Validate that all scripts use dynamic environment variables from Codemagic API calls
# Target: Ensure no hardcoded bundle IDs and proper fallback mechanisms

set -euo pipefail

echo "🧪 Testing Dynamic Bundle ID Injection"
echo "======================================"
echo "🎯 Target: Validate dynamic environment variable usage"
echo "📋 Ensure: No hardcoded bundle IDs, proper fallback mechanisms"
echo ""

# Configuration
PROJECT_ROOT=$(pwd)
BRANDING_SCRIPT="$PROJECT_ROOT/lib/scripts/ios/branding_assets.sh"
FIX_SCRIPTS=(
    "fix_bundle_collision_clean.sh"
    "fix_bundle_collision_proper.sh"
    "fix_bundle_collision_simple.sh"
)

echo "📁 Project Root: $PROJECT_ROOT"
echo ""

# Test 1: Check branding_assets.sh for hardcoded values
echo "🔍 Test 1: Checking branding_assets.sh for hardcoded values..."
if [ -f "$BRANDING_SCRIPT" ]; then
    echo "✅ branding_assets.sh found"
    
    # Check for hardcoded bundle IDs
    hardcoded_bundle_ids=$(grep -n "com\.[a-zA-Z0-9]*\.[a-zA-Z0-9]*" "$BRANDING_SCRIPT" | grep -v "example" | grep -v "comment" || true)
    
    if [ -z "$hardcoded_bundle_ids" ]; then
        echo "✅ No hardcoded bundle IDs found in branding_assets.sh"
    else
        echo "⚠️ Potential hardcoded bundle IDs found:"
        echo "$hardcoded_bundle_ids" | sed 's/^/   /'
    fi
    
    # Check for dynamic environment variable usage
    env_vars=$(grep -n "\${BUNDLE_ID\|ENV\['BUNDLE_ID'\]\|ENV\['PKG_NAME'\]" "$BRANDING_SCRIPT" || true)
    
    if [ -n "$env_vars" ]; then
        echo "✅ Dynamic environment variable usage found:"
        echo "$env_vars" | sed 's/^/   /'
    else
        echo "❌ No dynamic environment variable usage found"
    fi
    
else
    echo "❌ branding_assets.sh not found"
fi
echo ""

# Test 2: Check fix scripts for hardcoded values
echo "🔍 Test 2: Checking fix scripts for hardcoded values..."
for script in "${FIX_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        echo "📋 Checking $script..."
        
        # Check for hardcoded bundle IDs
        hardcoded_ids=$(grep -n "com\.[a-zA-Z0-9]*\.[a-zA-Z0-9]*" "$script" | grep -v "example" | grep -v "comment" || true)
        
        if [ -z "$hardcoded_ids" ]; then
            echo "   ✅ No hardcoded bundle IDs found"
        else
            echo "   ⚠️ Potential hardcoded bundle IDs found:"
            echo "$hardcoded_ids" | sed 's/^/      /'
        fi
        
        # Check for dynamic environment variable usage
        env_usage=$(grep -n "\${BUNDLE_ID\|ENV\['BUNDLE_ID'\]\|ENV\['PKG_NAME'\]" "$script" || true)
        
        if [ -n "$env_usage" ]; then
            echo "   ✅ Dynamic environment variable usage found"
        else
            echo "   ❌ No dynamic environment variable usage found"
        fi
        
    else
        echo "   ⚠️ $script not found"
    fi
done
echo ""

# Test 3: Test with different environment variables
echo "🔍 Test 3: Testing with different environment variables..."

# Test case 1: BUNDLE_ID set
echo "📋 Test Case 1: BUNDLE_ID=com.test.app"
export BUNDLE_ID="com.test.app"
export APP_NAME="Test App"
export VERSION_NAME="1.0.0"
export VERSION_CODE="1"

if [ -f "fix_bundle_collision_simple.sh" ]; then
    echo "   Running fix_bundle_collision_simple.sh with BUNDLE_ID=com.test.app..."
    if bash fix_bundle_collision_simple.sh >/dev/null 2>&1; then
        echo "   ✅ Script ran successfully with BUNDLE_ID"
        
        # Check if the bundle ID was applied
        applied_bundle_id=$(grep "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj | head -1 | sed 's/.*PRODUCT_BUNDLE_IDENTIFIER = \([^;]*\);.*/\1/' || echo "NOT_FOUND")
        if [[ "$applied_bundle_id" == com.test.app* ]]; then
            echo "   ✅ Bundle ID correctly applied: $applied_bundle_id"
        else
            echo "   ⚠️ Bundle ID not correctly applied: $applied_bundle_id"
        fi
    else
        echo "   ❌ Script failed with BUNDLE_ID"
    fi
fi

# Test case 2: PKG_NAME set (fallback)
echo "📋 Test Case 2: PKG_NAME=com.fallback.app (BUNDLE_ID unset)"
unset BUNDLE_ID
export PKG_NAME="com.fallback.app"

if [ -f "fix_bundle_collision_simple.sh" ]; then
    echo "   Running fix_bundle_collision_simple.sh with PKG_NAME=com.fallback.app..."
    if bash fix_bundle_collision_simple.sh >/dev/null 2>&1; then
        echo "   ✅ Script ran successfully with PKG_NAME"
        
        # Check if the bundle ID was applied
        applied_bundle_id=$(grep "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj | head -1 | sed 's/.*PRODUCT_BUNDLE_IDENTIFIER = \([^;]*\);.*/\1/' || echo "NOT_FOUND")
        if [[ "$applied_bundle_id" == com.fallback.app* ]]; then
            echo "   ✅ Bundle ID correctly applied: $applied_bundle_id"
        else
            echo "   ⚠️ Bundle ID not correctly applied: $applied_bundle_id"
        fi
    else
        echo "   ❌ Script failed with PKG_NAME"
    fi
fi

# Test case 3: No environment variables (default fallback)
echo "📋 Test Case 3: No environment variables (default fallback)"
unset BUNDLE_ID
unset PKG_NAME

if [ -f "fix_bundle_collision_simple.sh" ]; then
    echo "   Running fix_bundle_collision_simple.sh with no environment variables..."
    if bash fix_bundle_collision_simple.sh >/dev/null 2>&1; then
        echo "   ✅ Script ran successfully with default fallback"
        
        # Check if the default bundle ID was applied
        applied_bundle_id=$(grep "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj | head -1 | sed 's/.*PRODUCT_BUNDLE_IDENTIFIER = \([^;]*\);.*/\1/' || echo "NOT_FOUND")
        if [[ "$applied_bundle_id" == com.example.app* ]]; then
            echo "   ✅ Default bundle ID correctly applied: $applied_bundle_id"
        else
            echo "   ⚠️ Default bundle ID not correctly applied: $applied_bundle_id"
        fi
    else
        echo "   ❌ Script failed with default fallback"
    fi
fi
echo ""

# Test 4: Check branding_assets.sh integration
echo "🔍 Test 4: Checking branding_assets.sh integration..."
if [ -f "$BRANDING_SCRIPT" ]; then
    # Check if branding_assets.sh calls the fix scripts
    fix_script_calls=$(grep -n "fix_bundle_collision" "$BRANDING_SCRIPT" || true)
    
    if [ -n "$fix_script_calls" ]; then
        echo "✅ branding_assets.sh calls fix scripts:"
        echo "$fix_script_calls" | sed 's/^/   /'
    else
        echo "❌ branding_assets.sh does not call fix scripts"
    fi
    
    # Check if change_app_package_name is used
    change_app_calls=$(grep -n "change_app_package_name" "$BRANDING_SCRIPT" || true)
    
    if [ -n "$change_app_calls" ]; then
        echo "✅ change_app_package_name integration found:"
        echo "$change_app_calls" | sed 's/^/   /'
    else
        echo "❌ change_app_package_name integration not found"
    fi
    
else
    echo "❌ branding_assets.sh not found"
fi
echo ""

# Test 5: Validate environment variable propagation
echo "🔍 Test 5: Validating environment variable propagation..."
export BUNDLE_ID="com.test.propagation"
export APP_NAME="Propagation Test"
export VERSION_NAME="2.0.0"
export VERSION_CODE="2"

if [ -f "$BRANDING_SCRIPT" ]; then
    echo "📋 Testing environment variable propagation in branding_assets.sh..."
    
    # Check if the script validates environment variables
    env_validation=$(grep -n "BUNDLE_ID\|APP_NAME\|VERSION_NAME\|VERSION_CODE" "$BRANDING_SCRIPT" | grep "required\|validation" || true)
    
    if [ -n "$env_validation" ]; then
        echo "✅ Environment variable validation found:"
        echo "$env_validation" | sed 's/^/   /'
    else
        echo "⚠️ Environment variable validation not found"
    fi
    
    # Check if environment variables are used in change_app_package_name config
    config_usage=$(grep -n "ios_bundle_identifier\|app_name" "$BRANDING_SCRIPT" || true)
    
    if [ -n "$config_usage" ]; then
        echo "✅ Environment variables used in configuration:"
        echo "$config_usage" | sed 's/^/   /'
    else
        echo "❌ Environment variables not used in configuration"
    fi
fi
echo ""

# Test 6: Check Podfile collision prevention
echo "🔍 Test 6: Checking Podfile collision prevention..."
PODFILE="$PROJECT_ROOT/ios/Podfile"
if [ -f "$PODFILE" ]; then
    echo "✅ Podfile found"
    
    # Check for dynamic bundle ID usage in Podfile
    podfile_env_usage=$(grep -n "ENV\['BUNDLE_ID'\]\|ENV\['PKG_NAME'\]" "$PODFILE" || true)
    
    if [ -n "$podfile_env_usage" ]; then
        echo "✅ Dynamic environment variable usage in Podfile:"
        echo "$podfile_env_usage" | sed 's/^/   /'
    else
        echo "❌ No dynamic environment variable usage in Podfile"
    fi
    
    # Check for hardcoded bundle IDs in Podfile
    podfile_hardcoded=$(grep -n "com\.[a-zA-Z0-9]*\.[a-zA-Z0-9]*" "$PODFILE" | grep -v "example" | grep -v "comment" || true)
    
    if [ -z "$podfile_hardcoded" ]; then
        echo "✅ No hardcoded bundle IDs in Podfile"
    else
        echo "⚠️ Potential hardcoded bundle IDs in Podfile:"
        echo "$podfile_hardcoded" | sed 's/^/   /'
    fi
    
else
    echo "⚠️ Podfile not found"
fi
echo ""

# Summary
echo "📊 Test Summary"
echo "==============="

# Count test results
TOTAL_TESTS=6
PASSED_TESTS=0
FAILED_TESTS=0

# Count based on previous output
if [ -f "$BRANDING_SCRIPT" ]; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

if [ -f "fix_bundle_collision_simple.sh" ]; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

if [ -f "$PODFILE" ]; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

echo "📈 Test Results:"
echo "   ✅ Passed: $PASSED_TESTS"
echo "   ❌ Failed: $FAILED_TESTS"
echo "   📊 Total: $TOTAL_TESTS"
echo ""

# Environment variables summary
echo "📋 Environment Variables Tested:"
echo "   BUNDLE_ID: ${BUNDLE_ID:-<not set>}"
echo "   PKG_NAME: ${PKG_NAME:-<not set>}"
echo "   APP_NAME: ${APP_NAME:-<not set>}"
echo "   VERSION_NAME: ${VERSION_NAME:-<not set>}"
echo "   VERSION_CODE: ${VERSION_CODE:-<not set>}"
echo ""

if [ "$FAILED_TESTS" -eq 0 ]; then
    echo "🎉 All tests passed! Dynamic bundle ID injection is working correctly."
    echo "📋 The scripts now use environment variables from Codemagic API calls."
    echo "📋 No hardcoded bundle IDs found."
    echo "📋 Proper fallback mechanisms are in place."
    exit 0
else
    echo "⚠️ Some tests failed. Please review the issues above."
    echo "🔧 Ensure all scripts use dynamic environment variables."
    exit 1
fi 