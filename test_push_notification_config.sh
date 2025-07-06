#!/bin/bash

# Test Script for PUSH_NOTIFY Configuration
# Purpose: Demonstrate how PUSH_NOTIFY=true/false affects the iOS workflow

set -euo pipefail

echo "🧪 Testing PUSH_NOTIFY Configuration in iOS Workflow"
echo "=================================================="

# Test Case 1: PUSH_NOTIFY=true
echo ""
echo "📋 Test Case 1: PUSH_NOTIFY=true"
echo "--------------------------------"
export PUSH_NOTIFY="true"
echo "Setting PUSH_NOTIFY=$PUSH_NOTIFY"

# Run the enhanced push notification handler
if [ -f "lib/scripts/ios/enhanced_push_notification_handler.sh" ]; then
    echo "Running enhanced push notification handler..."
    bash lib/scripts/ios/enhanced_push_notification_handler.sh
    echo "✅ Test Case 1 completed"
else
    echo "❌ Enhanced push notification handler not found"
fi

# Test Case 2: PUSH_NOTIFY=false
echo ""
echo "📋 Test Case 2: PUSH_NOTIFY=false"
echo "--------------------------------"
export PUSH_NOTIFY="false"
echo "Setting PUSH_NOTIFY=$PUSH_NOTIFY"

# Run the enhanced push notification handler
if [ -f "lib/scripts/ios/enhanced_push_notification_handler.sh" ]; then
    echo "Running enhanced push notification handler..."
    bash lib/scripts/ios/enhanced_push_notification_handler.sh
    echo "✅ Test Case 2 completed"
else
    echo "❌ Enhanced push notification handler not found"
fi

# Test Case 3: PUSH_NOTIFY not set (should default to false)
echo ""
echo "📋 Test Case 3: PUSH_NOTIFY not set (defaults to false)"
echo "------------------------------------------------------"
unset PUSH_NOTIFY
echo "PUSH_NOTIFY is not set"

# Run the enhanced push notification handler
if [ -f "lib/scripts/ios/enhanced_push_notification_handler.sh" ]; then
    echo "Running enhanced push notification handler..."
    bash lib/scripts/ios/enhanced_push_notification_handler.sh
    echo "✅ Test Case 3 completed"
else
    echo "❌ Enhanced push notification handler not found"
fi

echo ""
echo "🎯 Test Summary"
echo "==============="
echo "✅ All test cases completed"
echo "📋 Check the generated summary files for details:"
echo "   - PUSH_NOTIFICATION_SUMMARY.txt"
echo "   - FIREBASE_INJECTION_SUMMARY.txt"
echo ""
echo "🔔 PUSH_NOTIFY=true: Firebase and push notifications ENABLED"
echo "🔕 PUSH_NOTIFY=false: Firebase and push notifications DISABLED"
echo ""
echo "📝 To use in your workflow:"
echo "   export PUSH_NOTIFY=true   # Enable push notifications"
echo "   export PUSH_NOTIFY=false  # Disable push notifications" 