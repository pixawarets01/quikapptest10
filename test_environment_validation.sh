#!/bin/bash

# Test Script for Environment Variable Validation
# Purpose: Test the environment validator with example variables

set -euo pipefail

echo "🧪 Testing Environment Variable Validation"
echo "=========================================="

# Set example environment variables (based on user input)
echo "📋 Setting up example environment variables..."

# Core App Configuration
export APP_ID="1002"
export VERSION_NAME="1.0.6"
export VERSION_CODE="65"
export APP_NAME="Twinklub App"
export ORG_NAME="JPR Garments"
export WEB_URL="https://twinklub.com/"
export BUNDLE_ID="com.twinklub.twinklub"
export PKG_NAME="com.twinklub.twinklub"

# Profile Configuration
export PROFILE_TYPE="app-store"
export PROFILE_URL="https://raw.githubusercontent.com/prasanna91/QuikApp/main/comtwinklubtwinklub__IOS_APP_STORE.mobileprovision"

# Certificate Configuration (P12 Flow)
export CERT_PASSWORD="Password@1234"
export CERT_P12_URL="https://raw.githubusercontent.com/prasanna91/QuikApp/main/PixawaretsIPhone.p12"

# Firebase Configuration
export PUSH_NOTIFY="true"
export FIREBASE_CONFIG_IOS="https://raw.githubusercontent.com/prasanna91/QuikApp/main/GoogleService-Info-TK.plist"
export FIREBASE_CONFIG_ANDROID="https://raw.githubusercontent.com/prasanna91/QuikApp/main/google-services-TK.json"
export APPLE_TEAM_ID="9H2AD7NQ49"
export APNS_KEY_ID="V566SWNF69"
export APNS_AUTH_KEY_URL="https://raw.githubusercontent.com/prasanna91/QuikApp/main/AuthKey_V566SWNF69.p8"

# App Store Connect Configuration
export APP_STORE_CONNECT_KEY_IDENTIFIER="ZFD9GRMS7R"
export APP_STORE_CONNECT_API_KEY="https://raw.githubusercontent.com/prasanna91/QuikApp/main/AuthKey_ZFD9GRMS7R.p8"
export APP_STORE_CONNECT_ISSUER_ID="a99a2ebd-ed3e-4117-9f97-f195823774a7"
export APPLE_ID="pixaware.co@gmail.com"
export APPLE_ID_PASSWORD="umor-gpxa-iohu-nitb"

# Android Configuration
export KEY_STORE_URL="https://raw.githubusercontent.com/prasanna91/QuikApp/main/keystore.jks"
export CM_KEYSTORE_PASSWORD="opeN@1234"
export CM_KEY_ALIAS="my_key_alias"
export CM_KEY_PASSWORD="opeN@1234"

# Feature Flags
export IS_CHATBOT="true"
export IS_DOMAIN_URL="true"
export IS_SPLASH="true"
export IS_PULLDOWN="true"
export IS_BOTTOMMENU="true"
export IS_LOAD_IND="true"
export IS_TESTFLIGHT="false"

# Permissions
export IS_CAMERA="false"
export IS_LOCATION="false"
export IS_MIC="true"
export IS_NOTIFICATION="true"
export IS_CONTACT="false"
export IS_BIOMETRIC="false"
export IS_CALENDAR="false"
export IS_STORAGE="true"

# UI Configuration
export LOGO_URL="https://raw.githubusercontent.com/prasanna91/QuikApp/main/twinklub_png_logo.png"
export SPLASH_URL="https://raw.githubusercontent.com/prasanna91/QuikApp/main/twinklub_png_logo.png"
export SPLASH_BG_COLOR="#cbdbf5"
export SPLASH_TAGLINE="TWINKLUB"
export SPLASH_TAGLINE_COLOR="#a30237"
export SPLASH_ANIMATION="zoom"
export SPLASH_DURATION="4"

export BOTTOMMENU_ITEMS='[{"label":"Home","icon":{"type":"preset","name":"home_outlined"},"url":"https://twinklub.com/"},{"label":"New Arraivals","icon":{"type":"custom","icon_url":"https://raw.githubusercontent.com/prasanna91/QuikApp/main/card.svg","icon_size":"24"},"url":"https://www.twinklub.com/collections/new-arrivals"},{"label":"Collections","icon":{"type":"custom","icon_url":"https://raw.githubusercontent.com/prasanna91/QuikApp/main/about.svg","icon_size":"24"},"url":"https://www.twinklub.com/collections/all"},{"label":"Contact","icon":{"type":"custom","icon_url":"https://raw.githubusercontent.com/prasanna91/QuikApp/main/contact.svg","icon_size":"24"},"url":"https://www.twinklub.com/account"}]'
export BOTTOMMENU_BG_COLOR="#FFFFFF"
export BOTTOMMENU_ICON_COLOR="#6d6e8c"
export BOTTOMMENU_TEXT_COLOR="#6d6e8c"
export BOTTOMMENU_FONT="DM Sans"
export BOTTOMMENU_FONT_SIZE="12"
export BOTTOMMENU_FONT_BOLD="false"
export BOTTOMMENU_FONT_ITALIC="false"
export BOTTOMMENU_ACTIVE_TAB_COLOR="#a30237"
export BOTTOMMENU_ICON_POSITION="above"

# Email Configuration
export ENABLE_EMAIL_NOTIFICATIONS="true"
export EMAIL_SMTP_SERVER="smtp.gmail.com"
export EMAIL_SMTP_PORT="587"
export EMAIL_SMTP_USER="prasannasrie@gmail.com"
export EMAIL_SMTP_PASS="lrnu krfm aarp urux"

# Workflow Configuration
export WORKFLOW_ID="ios-workflow"
export USER_NAME="prasannasrie"
export EMAIL_ID="prasannasrinivasan32@gmail.com"
export BRANCH="main3"

echo "✅ Environment variables set up successfully"
echo ""

# Test Case 1: Valid Configuration
echo "📋 Test Case 1: Valid Configuration"
echo "-----------------------------------"
echo "Running environment validation with all required variables set..."

if [ -f "lib/scripts/ios/environment_validator.sh" ]; then
    bash lib/scripts/ios/environment_validator.sh
    echo "✅ Test Case 1 completed"
else
    echo "❌ Environment validator not found"
fi

echo ""

# Test Case 2: Missing Required Variables
echo "📋 Test Case 2: Missing Required Variables"
echo "------------------------------------------"
echo "Testing with missing required variables..."

# Unset some required variables
unset APP_ID
unset VERSION_NAME
unset BUNDLE_ID

if [ -f "lib/scripts/ios/environment_validator.sh" ]; then
    bash lib/scripts/ios/environment_validator.sh
    echo "✅ Test Case 2 completed (should show validation errors)"
else
    echo "❌ Environment validator not found"
fi

echo ""

# Test Case 3: Invalid Profile Type
echo "📋 Test Case 3: Invalid Profile Type"
echo "------------------------------------"
echo "Testing with invalid profile type..."

# Reset variables and set invalid profile type
export APP_ID="1002"
export VERSION_NAME="1.0.6"
export BUNDLE_ID="com.twinklub.twinklub"
export PROFILE_TYPE="invalid-profile"

if [ -f "lib/scripts/ios/environment_validator.sh" ]; then
    bash lib/scripts/ios/environment_validator.sh
    echo "✅ Test Case 3 completed (should show profile type error)"
else
    echo "❌ Environment validator not found"
fi

echo ""

# Test Case 4: PUSH_NOTIFY=false (Firebase disabled)
echo "📋 Test Case 4: PUSH_NOTIFY=false"
echo "---------------------------------"
echo "Testing with push notifications disabled..."

# Reset profile type and disable push notifications
export PROFILE_TYPE="app-store"
export PUSH_NOTIFY="false"

if [ -f "lib/scripts/ios/environment_validator.sh" ]; then
    bash lib/scripts/ios/environment_validator.sh
    echo "✅ Test Case 4 completed"
else
    echo "❌ Environment validator not found"
fi

echo ""
echo "🎯 Test Summary"
echo "==============="
echo "✅ All test cases completed"
echo "📋 Check the generated summary files for details:"
echo "   - ENVIRONMENT_VALIDATION_SUMMARY.txt"
echo ""
echo "📝 Environment validation ensures:"
echo "   - All required variables are set"
echo "   - URL formats are valid"
echo "   - Boolean values are properly formatted"
echo "   - Profile types are valid"
echo "   - Certificate configuration is complete"
echo "   - Firebase configuration is present when PUSH_NOTIFY=true"
echo "   - App Store Connect configuration is present for app-store profiles"
echo ""
echo "🔧 To use in your workflow:"
echo "   - Set all required environment variables"
echo "   - Run the iOS workflow: ./lib/scripts/ios/main.sh"
echo "   - The validator will run automatically before the build starts" 