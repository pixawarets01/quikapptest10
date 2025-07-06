# Dynamic Bundle ID Injection System

## Overview

This document describes the comprehensive dynamic bundle ID injection system that uses environment variables from Codemagic API calls to prevent CFBundleIdentifier collision errors without hardcoding any values.

## Problem Statement

**Previous Issue**: Hardcoded bundle identifiers in scripts caused:

- Inflexible deployment across different environments
- Manual intervention required for different apps
- Risk of bundle ID collisions when scripts were reused
- Difficulty in CI/CD automation

**Solution**: Dynamic environment variable system that:

- Uses `BUNDLE_ID` and `PKG_NAME` from Codemagic API calls
- Provides fallback mechanisms for missing variables
- Integrates with `change_app_package_name` package
- Includes multiple fix scripts as backup

## Architecture

### 1. Primary Method: change_app_package_name Package

```yaml
# Dynamic configuration generated from environment variables
ios_bundle_identifier: ${BUNDLE_ID:-${PKG_NAME:-com.example.app}}
android_package_name: ${pkg_name//./_}
app_name: ${APP_NAME:-}
```

### 2. Fallback Method: Multiple Fix Scripts

- `fix_bundle_collision_clean.sh` - Clean fix without Unicode characters
- `fix_bundle_collision_proper.sh` - Target-aware assignment
- `fix_bundle_collision_simple.sh` - Simple sequential assignment

### 3. Final Fallback: Manual Update

- Direct project file manipulation
- Info.plist updates
- Podfile collision prevention

## Environment Variables

### Required Variables (from Codemagic API)

```bash
BUNDLE_ID="com.company.app"          # Primary bundle identifier
APP_NAME="My App Name"               # App display name
VERSION_NAME="1.0.0"                 # App version
VERSION_CODE="1"                     # Build number
WORKFLOW_ID="unique_workflow_id"     # Workflow identifier
APP_ID="unique_app_id"               # Application identifier
```

### Optional Variables

```bash
PKG_NAME="com.company.app"           # Alternative bundle ID (fallback)
ORG_NAME="Company Name"              # Organization name
WEB_URL="https://company.com"        # Website URL
LOGO_URL="https://company.com/logo.png"  # Logo URL
SPLASH_URL="https://company.com/splash.png"  # Splash screen URL
SPLASH_BG_URL="https://company.com/bg.png"   # Splash background URL
IS_BOTTOMMENU="true"                 # Enable bottom menu
BOTTOMMENU_ITEMS="[{\"type\":\"custom\",\"label\":\"Home\",\"icon_url\":\"https://...\"}]"  # Menu items
```

### Fallback Chain

1. `BUNDLE_ID` (primary)
2. `PKG_NAME` (secondary)
3. `com.example.app` (default)

## Implementation Details

### branding_assets.sh Integration

The main script now:

1. **Validates environment variables** from Codemagic API calls
2. **Uses change_app_package_name** as primary method
3. **Runs fallback scripts** if primary method fails
4. **Applies manual fixes** as final fallback
5. **Updates Podfile** with dynamic collision prevention

```bash
# Dynamic bundle ID assignment
local bundle_id="${BUNDLE_ID:-}"
local app_name="${APP_NAME:-}"
local pkg_name="${PKG_NAME:-$bundle_id}"

# Primary method: change_app_package_name
if flutter pub run change_app_package_name:main --config "$config_file"; then
    log_success "✅ Bundle ID updated successfully using change_app_package_name"
else
    # Fallback: Run fix scripts
    run_fallback_fix_scripts "$pkg_name"
fi
```

### Fix Scripts Dynamic Updates

All fix scripts now use:

```bash
# Dynamic configuration - no hardcoding
NEW_BUNDLE_ID="${BUNDLE_ID:-${PKG_NAME:-com.example.app}}"
BASE_BUNDLE_ID="${BUNDLE_ID:-${PKG_NAME:-com.example.app}}"

# Dynamic bundle identifier replacement
sed "s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_ID;/g"
```

### Podfile Collision Prevention

Dynamic Podfile updates:

```ruby
# Use dynamic bundle ID from environment
main_bundle_id = ENV['BUNDLE_ID'] || ENV['PKG_NAME'] || 'com.example.app'
timestamp = Time.now.to_i

installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
    next if target.name == 'Runner'

    # Generate unique bundle ID for each framework/pod
    unique_bundle_id = "#{main_bundle_id}.framework.#{target.name.downcase.gsub(/[^a-z0-9]/, '')}.#{timestamp}"
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = unique_bundle_id
  end
end
```

## Usage Examples

### Codemagic Workflow Configuration

```yaml
workflows:
  ios-app:
    name: iOS Build
    environment:
      vars:
        BUNDLE_ID: "com.company.app"
        APP_NAME: "My App"
        VERSION_NAME: "1.0.0"
        VERSION_CODE: "1"
        WORKFLOW_ID: "ios_build_workflow"
        APP_ID: "unique_app_id"
    scripts:
      - name: Run branding assets script
        script: |
          bash lib/scripts/ios/branding_assets.sh
```

### Manual Testing

```bash
# Test with different environment variables
export BUNDLE_ID="com.test.app"
export APP_NAME="Test App"
export VERSION_NAME="1.0.0"
export VERSION_CODE="1"
bash lib/scripts/ios/branding_assets.sh

# Test with PKG_NAME fallback
unset BUNDLE_ID
export PKG_NAME="com.fallback.app"
bash lib/scripts/ios/branding_assets.sh

# Test with no variables (default fallback)
unset BUNDLE_ID PKG_NAME
bash lib/scripts/ios/branding_assets.sh
```

## Testing

### Comprehensive Test Script

```bash
# Run dynamic bundle ID injection tests
bash test_dynamic_bundle_id_injection.sh
```

The test script validates:

1. **No hardcoded values** in any scripts
2. **Dynamic environment variable usage**
3. **Proper fallback mechanisms**
4. **Integration with branding_assets.sh**
5. **Environment variable propagation**
6. **Podfile collision prevention**

### Test Cases

1. **BUNDLE_ID set**: Uses primary bundle identifier
2. **PKG_NAME set**: Uses secondary bundle identifier
3. **No variables**: Uses default fallback
4. **Invalid format**: Validates bundle ID format
5. **Missing files**: Handles missing project files gracefully

## Benefits

### 1. Flexibility

- ✅ No hardcoded bundle IDs
- ✅ Works with any app bundle identifier
- ✅ Supports multiple environments
- ✅ Easy to reuse across projects

### 2. Reliability

- ✅ Multiple fallback mechanisms
- ✅ Comprehensive error handling
- ✅ Validation of environment variables
- ✅ Backup and recovery systems

### 3. Automation

- ✅ Fully automated CI/CD integration
- ✅ Dynamic configuration from API calls
- ✅ No manual intervention required
- ✅ Consistent across all builds

### 4. Maintainability

- ✅ Clear separation of concerns
- ✅ Modular script architecture
- ✅ Comprehensive logging
- ✅ Easy to debug and troubleshoot

## Error Handling

### Environment Variable Validation

```bash
# Required variables check
local required_vars=("WORKFLOW_ID" "APP_ID" "VERSION_NAME" "VERSION_CODE" "APP_NAME" "BUNDLE_ID")
for var in "${required_vars[@]}"; do
    if [ -z "${!var:-}" ]; then
        missing_vars+=("$var")
    fi
done
```

### Bundle ID Format Validation

```bash
# Enhanced bundle-id-rules validation
if [[ ! "$pkg_name" =~ ^[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)*$ ]]; then
    log_error "❌ Invalid bundle identifier format: $pkg_name"
    return 1
fi
```

### Fallback Script Execution

```bash
# Sequential fallback execution
for script in "${FIX_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        if bash "$script"; then
            log_success "✅ $script completed successfully"
            break
        else
            log_warn "⚠️ $script failed, trying next script..."
        fi
    fi
done
```

## Future Enhancements

### 1. Additional Environment Variables

- `IOS_TEAM_ID`: Apple Developer Team ID
- `IOS_PROVISIONING_PROFILE`: Provisioning profile name
- `IOS_CERTIFICATE`: Code signing certificate name

### 2. Advanced Validation

- Bundle ID availability checking
- App Store Connect integration
- Certificate and profile validation

### 3. Enhanced Logging

- Structured logging output
- Integration with monitoring systems
- Performance metrics collection

## Conclusion

The dynamic bundle ID injection system provides a robust, flexible, and maintainable solution for handling bundle identifiers in iOS builds. By using environment variables from Codemagic API calls, the system eliminates hardcoded values while providing comprehensive fallback mechanisms for reliability.

The integration with `change_app_package_name` package ensures the most robust bundle identifier management, while the multiple fix scripts provide reliable fallbacks for any edge cases. The system is fully automated and ready for production CI/CD workflows.
