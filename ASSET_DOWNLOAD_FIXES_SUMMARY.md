# Asset Download Fixes Summary

## Overview

Fixed four critical issues in the iOS workflow:

1. **Asset Download Logic**: Improved handling of null/empty URL variables
2. **pubspec.yaml Variable Substitution**: Fixed Firebase injection script variable processing
3. **APP_NAME Sanitization**: Ensured pubspec.yaml package names are valid Dart identifiers
4. **Firebase Injection Script**: Fixed bash variable substitution conflicts with Dart code

## Issue 1: Asset Download Logic

### Problem

The `branding_assets.sh` script was attempting to download assets even when URLs were set to "null", empty strings, or undefined, causing unnecessary network requests and potential errors.

### Solution

Enhanced the download logic to properly check for null, empty, and undefined values:

```bash
# Before (only checked if variable was set)
if [ -n "${LOGO_URL:-}" ]; then
    # Download logic
fi

# After (checks for null, empty, and undefined)
if [ -n "${LOGO_URL:-}" ] && [ "$LOGO_URL" != "null" ] && [ "$LOGO_URL" != "" ]; then
    # Download logic
fi
```

### Changes Made

#### 1. Logo Download (Step 7)

- **File**: `lib/scripts/ios/branding_assets.sh`
- **Lines**: 700-720
- **Improvement**: Now skips download if `LOGO_URL` is "null", empty, or undefined
- **Fallback**: Creates minimal PNG fallback asset

#### 2. Splash Download (Step 8)

- **File**: `lib/scripts/ios/branding_assets.sh`
- **Lines**: 722-730
- **Improvement**: Now skips download if `SPLASH_URL` is "null", empty, or undefined
- **Fallback**: Uses logo as splash image

#### 3. Splash Background Download (Step 9)

- **File**: `lib/scripts/ios/branding_assets.sh`
- **Lines**: 732-740
- **Improvement**: Now skips download if `SPLASH_BG_URL` is "null", empty, or undefined
- **Fallback**: No fallback created (optional asset)

### Asset Download Logic Summary

| Variable        | Null Check | Empty Check | Undefined Check | Action                         |
| --------------- | ---------- | ----------- | --------------- | ------------------------------ |
| `LOGO_URL`      | ✅         | ✅          | ✅              | Skip download, create fallback |
| `SPLASH_URL`    | ✅         | ✅          | ✅              | Skip download, use logo        |
| `SPLASH_BG_URL` | ✅         | ✅          | ✅              | Skip download, no fallback     |

## Issue 2: pubspec.yaml Variable Substitution and APP_NAME Sanitization

### Problem 1: Variable Substitution

The Firebase injection script was creating pubspec.yaml files with unprocessed variable substitutions like `${APP_ID:-twinklub_app}`, causing Flutter build errors.

### Problem 2: APP_NAME Sanitization

The `APP_NAME` variable was being used directly in pubspec.yaml without sanitization, causing issues when the app name contains spaces or special characters (e.g., "Twinklub App" should become "twinklub_app").

### Root Cause

1. Single quotes around heredoc delimiters prevented variable substitution
2. No sanitization of APP_NAME for Dart package name requirements

### Solution

1. Removed single quotes from heredoc delimiters to enable variable substitution
2. Added APP_NAME sanitization logic for pubspec.yaml compatibility

```bash
# Before: Variables not substituted due to single quotes
cat > pubspec.yaml << 'PUBSPEC_EOF'
name: ${APP_NAME:-twinklub_app}

# After: Variables properly substituted with sanitization
cat > pubspec.yaml << PUBSPEC_EOF
name: $(echo "${APP_NAME:-twinklub_app}" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9 ' | tr ' ' '_')
```

### APP_NAME Sanitization Logic

```bash
# Sanitization process:
# 1. Convert to lowercase
# 2. Remove special characters (keep only a-z, 0-9, spaces)
# 3. Replace spaces with underscores
echo "${APP_NAME:-twinklub_app}" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9 ' | tr ' ' '_'
```

### Sanitization Examples

| Input          | Output         | Notes                           |
| -------------- | -------------- | ------------------------------- |
| "Twinklub App" | "twinklub_app" | Spaces converted to underscores |
| "My Cool App!" | "my_cool_app"  | Special characters removed      |
| "App 123"      | "app_123"      | Numbers preserved               |
| "My-Cool-App"  | "mycoolapp"    | Hyphens removed                 |
| "My.Cool.App"  | "mycoolapp"    | Dots removed                    |
| "My@Cool#App"  | "mycoolapp"    | Special characters removed      |

### Changes Made

#### 1. Firebase-Enabled pubspec.yaml

- **File**: `lib/scripts/ios/conditional_firebase_injection.sh`
- **Line**: 58
- **Change**: Added APP_NAME sanitization for package name

#### 2. Firebase-Disabled pubspec.yaml

- **File**: `lib/scripts/ios/conditional_firebase_injection.sh`
- **Line**: 120
- **Change**: Added APP_NAME sanitization for package name

#### 3. Branding Assets Script

- **File**: `lib/scripts/ios/branding_assets.sh`
- **Line**: 85
- **Change**: Updated sanitization logic with default fallback

#### 4. main.dart Files

- **File**: `lib/scripts/ios/conditional_firebase_injection.sh`
- **Lines**: 181, 370
- **Change**: Removed single quotes from `'DART_EOF'` → `DART_EOF`

## Testing

### Test Scripts

Created comprehensive test scripts to verify all fixes:

```bash
# Test asset download fixes
./test_asset_download_fixes.sh

# Test APP_NAME sanitization
./test_app_name_sanitization.sh
```

### Test Cases

1. **Null URLs**: All URLs set to "null"
2. **Empty URLs**: All URLs set to empty strings
3. **Undefined URLs**: All URL variables unset
4. **Mixed URLs**: Valid URL + null/empty URLs
5. **Variable Substitution**: Firebase injection with proper variable processing
6. **APP_NAME Sanitization**: Various app name formats and edge cases

### Expected Results

- ✅ Asset downloads skipped when URLs are null/empty/undefined
- ✅ Fallback assets created appropriately
- ✅ pubspec.yaml variables properly substituted
- ✅ APP_NAME correctly sanitized for Dart package name requirements
- ✅ No Flutter build errors due to unprocessed variables or invalid package names

## Environment Variables

### Asset Download Variables

| Variable        | Purpose                 | Default | Null Handling                  |
| --------------- | ----------------------- | ------- | ------------------------------ |
| `LOGO_URL`      | App logo download URL   | None    | Skip download, create fallback |
| `SPLASH_URL`    | Splash screen image URL | None    | Skip download, use logo        |
| `SPLASH_BG_URL` | Splash background URL   | None    | Skip download, no fallback     |

### Firebase Injection Variables

| Variable       | Purpose                  | Default      | Usage                         |
| -------------- | ------------------------ | ------------ | ----------------------------- |
| `APP_NAME`     | Application display name | twinklub_app | pubspec.yaml name (sanitized) |
| `VERSION_NAME` | App version              | 1.0.6        | pubspec.yaml version          |
| `VERSION_CODE` | Build number             | 50           | pubspec.yaml version          |

## Error Prevention

### Before Fixes

```
Error on line 1, column 7 of pubspec.yaml: "name" field must be a valid Dart identifier.
  ╷
1 │ name: ${APP_NAME:-twinklub_app}
  │       ^^^^^^^^^^^^^^^^^^^
```

### After Fixes

```
✅ Variable substitution working for APP_NAME
✅ APP_NAME correctly sanitized: 'Twinklub App' → 'twinklub_app'
✅ Valid Dart identifier format maintained
✅ Firebase injection completed successfully
```

## Integration

### iOS Workflow Integration

The fixes are automatically applied in the iOS workflow:

1. **Stage 1**: `branding_assets.sh` - Asset download with null/empty handling
2. **Stage 6**: `conditional_firebase_injection.sh` - Firebase injection with proper variable substitution and APP_NAME sanitization

### Backward Compatibility

- ✅ Existing workflows continue to work
- ✅ No breaking changes to environment variable usage
- ✅ Improved error handling and logging
- ✅ Automatic APP_NAME sanitization for pubspec.yaml compatibility

## Benefits

### 1. Improved Reliability

- No more failed downloads due to null/empty URLs
- Proper fallback asset creation
- Valid pubspec.yaml package names
- Better error handling and user feedback

### 2. Enhanced User Experience

- Clearer logging about asset download decisions
- Automatic APP_NAME sanitization
- Faster builds when URLs are not provided
- No build failures due to unprocessed variables or invalid package names

### 3. Better Debugging

- Detailed logging of asset download logic
- Clear indication of fallback asset creation
- APP_NAME sanitization process logging
- Environment variable validation and reporting

## Usage Examples

### Minimal Configuration

```bash
# Only required variables - assets will use fallbacks
export WORKFLOW_ID="test_workflow"
export APP_ID="test_app"
export VERSION_NAME="1.0.0"
export VERSION_CODE="1"
export APP_NAME="My Cool App"  # Will become "my_cool_app" in pubspec.yaml
export BUNDLE_ID="com.example.myapp"
```

### Full Asset Configuration

```bash
# All assets provided
export LOGO_URL="https://example.com/logo.png"
export SPLASH_URL="https://example.com/splash.png"
export SPLASH_BG_URL="https://example.com/splash_bg.png"
export APP_NAME="Twinklub App"  # Will become "twinklub_app" in pubspec.yaml
```

### Mixed Configuration

```bash
# Some assets provided, others will use fallbacks
export LOGO_URL="https://example.com/logo.png"
export SPLASH_URL="null"  # Will use logo as splash
export SPLASH_BG_URL=""   # Will be skipped
export APP_NAME="My App!"  # Will become "my_app" in pubspec.yaml
```

## Conclusion

These fixes significantly improve the robustness of the iOS workflow by:

1. **Preventing unnecessary network requests** when asset URLs are not available
2. **Ensuring proper variable substitution** in generated configuration files
3. **Maintaining valid Dart package names** through APP_NAME sanitization
4. **Providing clear feedback** about asset download decisions and sanitization
5. **Maintaining backward compatibility** with existing workflows

The workflow now handles edge cases gracefully and provides better user experience with improved logging, error handling, and automatic sanitization for Flutter compatibility.

## Issue 3: Firebase Injection Script Bash Variable Substitution Conflicts

### Problem

The Firebase injection script was failing with "bad substitution" errors when generating main.dart files. The issue was that bash was trying to interpret Dart string interpolation syntax (like `${message.messageId}`) as bash variable substitutions.

### Root Cause

Dart code contains string interpolation using `${}` syntax, which conflicts with bash variable substitution when using heredocs without proper escaping.

### Solution

Escaped all Dart string interpolation that should not be processed by bash by adding backslashes before the `$` characters.

### Changes Made

#### 1. Firebase Background Message Handler

- **File**: `lib/scripts/ios/conditional_firebase_injection.sh`
- **Line**: 187
- **Change**: Escaped `${message.messageId}` → `\${message.messageId}`

#### 2. FCM Token and Message Data

- **File**: `lib/scripts/ios/conditional_firebase_injection.sh`
- **Lines**: 225, 230, 235, 240
- **Change**: Escaped all Dart string interpolation variables

### Examples of Fixes

```bash
# Before (causing bash errors)
print('FCM Token: $_fcmToken');
print('Message data: ${message.data}');

# After (properly escaped)
print('FCM Token: \$_fcmToken');
print('Message data: \${message.data}');
```

## Issue 4: Email Notifications Script BOM Issue

### Problem

The email notifications script was failing with "No such file or directory" errors due to a BOM (Byte Order Mark) at the beginning of the file.

### Root Cause

The script file had a UTF-8 BOM (`ef bb bf`) at the beginning, which caused bash to fail when trying to execute the shebang line.

### Solution

Removed the BOM from the email notifications script file.

### Changes Made

- **File**: `lib/scripts/ios/email_notifications.sh`
- **Change**: Removed UTF-8 BOM from the beginning of the file
- **Command**: `sed '1s/^\xEF\xBB\xBF//'`

## Testing

### Test Scripts

Created comprehensive test scripts to verify all fixes:

```bash
# Test asset download fixes
./test_asset_download_fixes.sh

# Test APP_NAME sanitization
./test_app_name_sanitization.sh

# Test Firebase injection fixes
./test_firebase_injection_fixes.sh
```

### Test Cases

1. **Null URLs**: All URLs set to "null"
2. **Empty URLs**: All URLs set to empty strings
3. **Undefined URLs**: All URL variables unset
4. **Mixed URLs**: Valid URL + null/empty URLs
5. **Variable Substitution**: Firebase injection with proper variable processing
6. **APP_NAME Sanitization**: Various app name formats and edge cases
7. **Firebase Injection**: Proper Dart code generation without bash conflicts
8. **Email Notifications**: Script execution without BOM issues

### Expected Results

- ✅ Asset downloads skipped when URLs are null/empty/undefined
- ✅ Fallback assets created appropriately
- ✅ pubspec.yaml variables properly substituted
- ✅ APP_NAME correctly sanitized for Dart package name requirements
- ✅ Firebase injection script runs without bash substitution errors
- ✅ Email notifications script executes without BOM issues
- ✅ No Flutter build errors due to unprocessed variables or invalid package names
