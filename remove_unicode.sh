#!/bin/bash

# Remove Unicode characters from project file
echo "Removing Unicode characters from project file..."

# Create backup
cp ios/Runner.xcodeproj/project.pbxproj ios/Runner.xcodeproj/project.pbxproj.before_unicode_removal

# Remove Unicode characters using sed
sed 's/[^\x00-\x7F]//g' ios/Runner.xcodeproj/project.pbxproj > ios/Runner.xcodeproj/project.pbxproj.tmp
mv ios/Runner.xcodeproj/project.pbxproj.tmp ios/Runner.xcodeproj/project.pbxproj

echo "Unicode characters removed"
echo "Checking for remaining Unicode characters:"
grep -n "🔧" ios/Runner.xcodeproj/project.pbxproj || echo "No Unicode characters found" 