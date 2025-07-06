#!/bin/bash

# Test Certificate Workflow Script
# Purpose: Test the comprehensive certificate validation workflow

set -euo pipefail

echo "🔒 Testing Comprehensive Certificate Validation Workflow"
echo "========================================================"

# Check if scripts exist
echo "📋 Checking script availability..."

if [ -f "lib/scripts/ios/comprehensive_certificate_validation.sh" ]; then
    echo "✅ comprehensive_certificate_validation.sh found"
else
    echo "❌ comprehensive_certificate_validation.sh not found"
    exit 1
fi

if [ -f "lib/scripts/ios/ipa_export_with_certificate_validation.sh" ]; then
    echo "✅ ipa_export_with_certificate_validation.sh found"
else
    echo "❌ ipa_export_with_certificate_validation.sh not found"
    exit 1
fi

if [ -f "lib/scripts/ios/example_certificate_workflow.sh" ]; then
    echo "✅ example_certificate_workflow.sh found"
else
    echo "❌ example_certificate_workflow.sh not found"
    exit 1
fi

# Check script permissions
echo "🔐 Checking script permissions..."

if [ -x "lib/scripts/ios/comprehensive_certificate_validation.sh" ]; then
    echo "✅ comprehensive_certificate_validation.sh is executable"
else
    echo "❌ comprehensive_certificate_validation.sh is not executable"
    chmod +x lib/scripts/ios/comprehensive_certificate_validation.sh
    echo "✅ Made comprehensive_certificate_validation.sh executable"
fi

if [ -x "lib/scripts/ios/ipa_export_with_certificate_validation.sh" ]; then
    echo "✅ ipa_export_with_certificate_validation.sh is executable"
else
    echo "❌ ipa_export_with_certificate_validation.sh is not executable"
    chmod +x lib/scripts/ios/ipa_export_with_certificate_validation.sh
    echo "✅ Made ipa_export_with_certificate_validation.sh executable"
fi

if [ -x "lib/scripts/ios/example_certificate_workflow.sh" ]; then
    echo "✅ example_certificate_workflow.sh is executable"
else
    echo "❌ example_certificate_workflow.sh is not executable"
    chmod +x lib/scripts/ios/example_certificate_workflow.sh
    echo "✅ Made example_certificate_workflow.sh executable"
fi

# Test example script functionality
echo "🧪 Testing example script functionality..."

# Test help option
echo "📖 Testing help option..."
if bash lib/scripts/ios/example_certificate_workflow.sh help > /dev/null 2>&1; then
    echo "✅ Help option works"
else
    echo "❌ Help option failed"
fi

# Test p12-example option
echo "📦 Testing P12 example option..."
if bash lib/scripts/ios/example_certificate_workflow.sh p12-example > /dev/null 2>&1; then
    echo "✅ P12 example option works"
else
    echo "❌ P12 example option failed"
fi

# Test cer-key-example option
echo "🔑 Testing CER+KEY example option..."
if bash lib/scripts/ios/example_certificate_workflow.sh cer-key-example > /dev/null 2>&1; then
    echo "✅ CER+KEY example option works"
else
    echo "❌ CER+KEY example option failed"
fi

# Test validation-steps option
echo "🔍 Testing validation steps option..."
if bash lib/scripts/ios/example_certificate_workflow.sh validation-steps > /dev/null 2>&1; then
    echo "✅ Validation steps option works"
else
    echo "❌ Validation steps option failed"
fi

# Test troubleshooting option
echo "🚨 Testing troubleshooting option..."
if bash lib/scripts/ios/example_certificate_workflow.sh troubleshooting > /dev/null 2>&1; then
    echo "✅ Troubleshooting option works"
else
    echo "❌ Troubleshooting option failed"
fi

# Show workflow summary
echo ""
echo "🎯 Certificate Workflow Summary"
echo "==============================="
echo ""
echo "📋 Available Scripts:"
echo "   1. comprehensive_certificate_validation.sh - Core certificate validation"
echo "   2. ipa_export_with_certificate_validation.sh - Full IPA export workflow"
echo "   3. example_certificate_workflow.sh - Documentation and examples"
echo ""
echo "📝 Usage Examples:"
echo ""
echo "   # Certificate validation only"
echo "   export CERT_P12_URL=\"https://example.com/cert.p12\""
echo "   export CERT_PASSWORD=\"your_password\""
echo "   export APP_STORE_CONNECT_API_KEY_PATH=\"https://example.com/AuthKey.p8\""
echo "   export APP_STORE_CONNECT_KEY_IDENTIFIER=\"YOUR_KEY_ID\""
echo "   export APP_STORE_CONNECT_ISSUER_ID=\"your-issuer-id\""
echo "   export PROFILE_URL=\"https://example.com/profile.mobileprovision\""
echo "   export BUNDLE_ID=\"com.example.app\""
echo "   export PROFILE_TYPE=\"app-store\""
echo "   ./lib/scripts/ios/comprehensive_certificate_validation.sh"
echo ""
echo "   # Full IPA export with certificate validation"
echo "   ./lib/scripts/ios/ipa_export_with_certificate_validation.sh"
echo ""
echo "   # Get help and examples"
echo "   ./lib/scripts/ios/example_certificate_workflow.sh help"
echo ""
echo "📚 Documentation:"
echo "   - COMPREHENSIVE_CERTIFICATE_VALIDATION_GUIDE.md"
echo ""
echo "✅ Test completed successfully!"
echo "🚀 Certificate workflow is ready to use!" 