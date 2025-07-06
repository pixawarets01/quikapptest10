#!/bin/bash

# Quick Bundle Identifier Collision Fix - One-liner Approach
# Usage: ./quick_bundle_fix.sh

PROJECT_FILE="ios/Runner.xcodeproj/project.pbxproj"

echo "🔧 Quick Bundle Identifier Collision Fix"

# Create backup
cp "$PROJECT_FILE" "$PROJECT_FILE.backup.$(date +%Y%m%d_%H%M%S)"

# Fix bundle identifier collisions in one command
sed -i.bak '
/PRODUCT_BUNDLE_IDENTIFIER = com\.twinklub\.twinklub;/{
    /RunnerTests/,/name = Debug\|name = Release\|name = Profile/{
        s/com\.twinklub\.twinklub;/com.twinklub.twinklub.tests;/
    }
}' "$PROJECT_FILE"

# Verify
echo "✅ Fixed! Current bundle identifiers:"
grep "PRODUCT_BUNDLE_IDENTIFIER" "$PROJECT_FILE"

echo "🎯 App Store validation should now succeed!" 