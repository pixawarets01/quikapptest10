# Environment Variable Validation Guide for iOS Workflow

## Overview

The iOS workflow now includes a comprehensive environment variable validation system that ensures all required variables are properly set before the build starts. This prevents build failures due to missing or invalid configuration.

## How It Works

The environment validator runs automatically as **Stage 1** of the iOS workflow and validates:

1. **Core App Configuration** - App ID, version, name, bundle ID, etc.
2. **Profile Configuration** - Profile type and URL
3. **Certificate Configuration** - P12 or CER+KEY setup
4. **Firebase Configuration** - When PUSH_NOTIFY=true
5. **App Store Connect Configuration** - For app-store profiles
6. **Android Configuration** - Keystore and signing
7. **Feature Flags** - All boolean feature toggles
8. **UI Configuration** - Splash screen and bottom menu settings
9. **Email Configuration** - SMTP settings for notifications
10. **Workflow Configuration** - Workflow metadata

## Required Environment Variables

### Core App Configuration

```bash
export APP_ID="1002"                           # Required: App ID
export VERSION_NAME="1.0.6"                    # Required: App version name
export VERSION_CODE="65"                       # Required: App version code
export APP_NAME="Twinklub App"                 # Required: App name
export ORG_NAME="JPR Garments"                 # Required: Organization name
export BUNDLE_ID="com.twinklub.twinklub"       # Required: iOS bundle identifier
export PKG_NAME="com.twinklub.twinklub"        # Required: Android package name
export WEB_URL="https://twinklub.com/"         # Required: Web URL
```

### Profile Configuration

```bash
export PROFILE_TYPE="app-store"                # Required: Profile type
export PROFILE_URL="https://..."               # Required: Provisioning profile URL
```

### Certificate Configuration (Choose One)

**P12 Flow (Recommended):**

```bash
export CERT_P12_URL="https://..."              # Required: P12 certificate URL
export CERT_PASSWORD="Password@1234"           # Required: Certificate password
```

**CER+KEY Flow:**

```bash
export CERT_CER_URL="https://..."              # Required: Certificate CER URL
export CERT_KEY_URL="https://..."              # Required: Private key URL
export CERT_PASSWORD="Password@1234"           # Required: Certificate password
```

### Firebase Configuration (When PUSH_NOTIFY=true)

```bash
export PUSH_NOTIFY="true"                      # Required: Enable push notifications
export FIREBASE_CONFIG_IOS="https://..."       # Required: iOS Firebase config URL
export FIREBASE_CONFIG_ANDROID="https://..."   # Optional: Android Firebase config URL
export APPLE_TEAM_ID="9H2AD7NQ49"              # Required: Apple Team ID
export APNS_KEY_ID="V566SWNF69"                # Required: APNS Key ID
export APNS_AUTH_KEY_URL="https://..."         # Required: APNS Auth Key URL
```

### App Store Connect Configuration (For app-store profiles)

```bash
export APP_STORE_CONNECT_KEY_IDENTIFIER="ZFD9GRMS7R"  # Required: API Key ID
export APP_STORE_CONNECT_API_KEY="https://..."        # Required: API Key URL
export APP_STORE_CONNECT_ISSUER_ID="a99a2ebd-..."     # Required: Issuer ID
export APPLE_ID="pixaware.co@gmail.com"               # Optional: Apple ID
export APPLE_ID_PASSWORD="umor-gpxa-iohu-nitb"        # Optional: Apple ID password
```

### Android Configuration

```bash
export KEY_STORE_URL="https://..."             # Required: Keystore URL
export CM_KEYSTORE_PASSWORD="opeN@1234"        # Required: Keystore password
export CM_KEY_ALIAS="my_key_alias"             # Required: Key alias
export CM_KEY_PASSWORD="opeN@1234"             # Required: Key password
```

### Feature Flags

```bash
export IS_CHATBOT="true"                       # Optional: Enable chatbot
export IS_DOMAIN_URL="true"                    # Optional: Enable domain URL
export IS_SPLASH="true"                        # Optional: Enable splash screen
export IS_PULLDOWN="true"                      # Optional: Enable pull to refresh
export IS_BOTTOMMENU="true"                    # Optional: Enable bottom menu
export IS_LOAD_IND="true"                      # Optional: Enable loading indicator
export IS_TESTFLIGHT="false"                   # Optional: Enable TestFlight
```

### Permissions

```bash
export IS_CAMERA="false"                       # Optional: Camera permission
export IS_LOCATION="false"                     # Optional: Location permission
export IS_MIC="true"                           # Optional: Microphone permission
export IS_NOTIFICATION="true"                  # Optional: Notification permission
export IS_CONTACT="false"                      # Optional: Contacts permission
export IS_BIOMETRIC="false"                    # Optional: Biometric permission
export IS_CALENDAR="false"                     # Optional: Calendar permission
export IS_STORAGE="true"                       # Optional: Storage permission
```

### UI Configuration

```bash
# Splash Screen (when IS_SPLASH=true)
export SPLASH_BG_COLOR="#cbdbf5"               # Optional: Background color
export SPLASH_TAGLINE="TWINKLUB"               # Optional: Tagline text
export SPLASH_TAGLINE_COLOR="#a30237"          # Optional: Tagline color
export SPLASH_ANIMATION="zoom"                 # Optional: Animation type
export SPLASH_DURATION="4"                     # Optional: Duration in seconds

# Bottom Menu (when IS_BOTTOMMENU=true)
export BOTTOMMENU_ITEMS='[{"label":"Home",...}]'  # Required: Menu items JSON
export BOTTOMMENU_BG_COLOR="#FFFFFF"           # Optional: Background color
export BOTTOMMENU_ICON_COLOR="#6d6e8c"         # Optional: Icon color
export BOTTOMMENU_TEXT_COLOR="#6d6e8c"         # Optional: Text color
export BOTTOMMENU_FONT="DM Sans"               # Optional: Font family
export BOTTOMMENU_FONT_SIZE="12"               # Optional: Font size
export BOTTOMMENU_ACTIVE_TAB_COLOR="#a30237"   # Optional: Active tab color
export BOTTOMMENU_ICON_POSITION="above"        # Optional: Icon position
```

### Email Configuration (When ENABLE_EMAIL_NOTIFICATIONS=true)

```bash
export ENABLE_EMAIL_NOTIFICATIONS="true"       # Optional: Enable email notifications
export EMAIL_SMTP_SERVER="smtp.gmail.com"      # Required: SMTP server
export EMAIL_SMTP_PORT="587"                   # Required: SMTP port
export EMAIL_SMTP_USER="user@gmail.com"        # Required: SMTP username
export EMAIL_SMTP_PASS="app_password"          # Required: SMTP password
```

### Workflow Configuration

```bash
export WORKFLOW_ID="ios-workflow"              # Optional: Workflow ID
export USER_NAME="username"                    # Optional: User name
export EMAIL_ID="user@example.com"             # Optional: Email ID
export BRANCH="main"                           # Optional: Git branch
```

## Profile Types

The validator supports these profile types:

- `app-store` or `appstore` - For App Store distribution
- `ad-hoc` or `adhoc` - For ad-hoc distribution
- `enterprise` - For enterprise distribution
- `development` or `dev` - For development
- `developer_id` - For Developer ID distribution

## Certificate Configuration

The validator supports two certificate flows:

### P12 Flow (Recommended)

```bash
export CERT_P12_URL="https://..."
export CERT_PASSWORD="password"
```

### CER+KEY Flow

```bash
export CERT_CER_URL="https://..."
export CERT_KEY_URL="https://..."
export CERT_PASSWORD="password"
```

If both are configured, P12 takes precedence.

## Firebase Configuration

When `PUSH_NOTIFY=true`, the validator ensures:

- Firebase configuration URLs are provided
- APNS configuration is complete
- All required Firebase variables are set

When `PUSH_NOTIFY=false`, Firebase validation is skipped.

## Usage Examples

### 1. Run the iOS Workflow

```bash
# Set all required environment variables
export APP_ID="1002"
export VERSION_NAME="1.0.6"
# ... (set all other required variables)

# Run the iOS workflow (validation runs automatically)
./lib/scripts/ios/main.sh
```

### 2. Test Environment Validation Only

```bash
# Test with example variables
./test_environment_validation.sh

# Test with your own variables
./lib/scripts/ios/environment_validator.sh
```

### 3. Test Push Notification Configuration

```bash
# Test PUSH_NOTIFY=true/false scenarios
./test_push_notification_config.sh
```

## Validation Output

The validator provides:

- ✅ Success indicators for valid variables
- ❌ Error messages for missing required variables
- ⚠️ Warnings for potential issues
- 📋 Summary file: `ENVIRONMENT_VALIDATION_SUMMARY.txt`

## Error Handling

If validation fails:

1. The build stops immediately
2. An email notification is sent (if enabled)
3. A detailed error report is generated
4. The validation summary shows what needs to be fixed

## Integration with CI/CD

The environment validator integrates seamlessly with Codemagic:

```yaml
workflows:
  ios-workflow:
    name: iOS Build
    environment:
      vars:
        APP_ID: "1002"
        VERSION_NAME: "1.0.6"
        # ... (all other variables)
    scripts:
      - name: Run iOS workflow
        script: |
          ./lib/scripts/ios/main.sh
```

## Testing

Use the provided test scripts to validate your configuration:

```bash
# Test environment validation
./test_environment_validation.sh

# Test push notification configuration
./test_push_notification_config.sh
```

## Troubleshooting

### Common Issues

1. **Missing Required Variables**

   - Check the error messages for specific missing variables
   - Ensure all required variables are set

2. **Invalid Profile Type**

   - Use one of the supported profile types
   - Check spelling and case sensitivity

3. **Invalid URL Format**

   - Ensure URLs start with `http://` or `https://`
   - Verify URLs are accessible

4. **Certificate Configuration Issues**

   - Ensure either P12 or CER+KEY configuration is complete
   - Verify certificate passwords are correct

5. **Firebase Configuration Missing**
   - When `PUSH_NOTIFY=true`, ensure all Firebase variables are set
   - Verify APNS configuration is complete

### Getting Help

1. Check the validation summary file: `ENVIRONMENT_VALIDATION_SUMMARY.txt`
2. Review the error messages in the build logs
3. Use the test scripts to isolate issues
4. Ensure all required variables are properly exported

## Best Practices

1. **Always validate before building** - The validator runs automatically
2. **Use consistent variable naming** - Follow the established conventions
3. **Test with different configurations** - Use the test scripts
4. **Keep sensitive data secure** - Use environment variables, not hardcoded values
5. **Document your configuration** - Keep track of your variable values
6. **Use version control** - Store configuration templates in version control

## Summary

The environment validation system ensures your iOS builds are properly configured before they start, preventing common build failures and saving time. It validates all aspects of your app configuration and provides clear feedback on any issues that need to be resolved.
