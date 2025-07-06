# Enhanced Branding Assets Guide

## Overview

The Enhanced Branding Assets script (`branding_assets.sh`) is now the **FIRST script** in the iOS workflow and handles all basic app information and branding assets. This script ensures that all essential app configuration is set up before any other build processes begin.

## 🚀 Key Features

### 1. Basic App Information Validation

- **WORKFLOW_ID**: Unique workflow identifier
- **APP_ID**: Application identifier
- **VERSION_NAME**: App version (e.g., 1.0.0)
- **VERSION_CODE**: Build number (e.g., 1)
- **APP_NAME**: Display name of the app
- **ORG_NAME**: Organization name
- **BUNDLE_ID**: iOS bundle identifier (e.g., com.company.app)

### 2. Asset Management

- **WEB_URL**: Company website URL
- **LOGO_URL**: App logo download URL
- **SPLASH_URL**: Splash screen image URL
- **SPLASH_BG_URL**: Splash background image URL

### 3. Bottom Menu Configuration

- **BOTTOMMENU_ITEMS**: Custom bottom menu with icons and labels
- Format: `"icon1:label1,icon2:label2,icon3:label3"`
- Automatically downloads custom icons for each menu item

## 📋 Required Environment Variables

### Essential Variables (Required)

```bash
WORKFLOW_ID="your_workflow_id"
APP_ID="com.yourcompany.yourapp"
VERSION_NAME="1.0.0"
VERSION_CODE="1"
APP_NAME="Your App Name"
BUNDLE_ID="com.yourcompany.yourapp"
```

### Optional Variables

```bash
ORG_NAME="Your Company Name"
WEB_URL="https://yourcompany.com"
LOGO_URL="https://yourcompany.com/logo.png"
SPLASH_URL="https://yourcompany.com/splash.png"
SPLASH_BG_URL="https://yourcompany.com/splash_bg.png"
BOTTOMMENU_ITEMS="https://icon1.com/icon1.png:Home,https://icon2.com/icon2.png:Search,https://icon3.com/icon3.png:Profile"
```

## 🔧 What the Script Does

### Step 1: Basic App Information Validation

- Validates all required environment variables
- Displays comprehensive app information summary
- Ensures no critical information is missing

### Step 2: App Configuration Updates

- Updates `pubspec.yaml` with app name, version, and description
- Updates iOS `Info.plist` with bundle information
- Updates iOS project file with bundle identifier

### Step 3: Bundle ID and App Name Updates

- Applies comprehensive bundle identifier collision prevention
- Updates app name across all configuration files
- Ensures Flutter integration compatibility

### Step 4: Version Management

- Updates version in `pubspec.yaml` and iOS `Info.plist`
- Validates version format compliance
- Creates version backups for rollback

### Step 5: Bottom Menu Items Processing

- Downloads custom icons for each menu item
- Creates menu configuration JSON file
- Handles fallback icons if downloads fail

### Step 6: Asset Directory Setup

- Creates necessary asset directories
- Ensures iOS asset catalog structure

### Step 7-10: Asset Downloads and Processing

- Downloads logo, splash, and splash background images
- Creates fallback assets if downloads fail
- Copies assets to iOS-specific locations

## 📁 Generated Files and Directories

```
assets/
├── images/
│   ├── logo.png          # App logo
│   ├── splash.png        # Splash screen
│   └── splash_bg.png     # Splash background
└── icons/
    └── menu/
        ├── menu_icon_0.png
        ├── menu_icon_1.png
        ├── menu_icon_2.png
        └── menu_config.json

ios/Runner/Assets.xcassets/
├── AppIcon.appiconset/
│   └── Icon-App-1024x1024@1x.png
└── LaunchImage.imageset/
    ├── LaunchImage.png
    ├── LaunchImage@2x.png
    └── LaunchImage@3x.png
```

## 🎯 Bottom Menu Items Format

### Input Format

```bash
BOTTOMMENU_ITEMS="icon1_url:label1,icon2_url:label2,icon3_url:label3"
```

### Example

```bash
BOTTOMMENU_ITEMS="https://example.com/home.png:Home,https://example.com/search.png:Search,https://example.com/profile.png:Profile"
```

### Generated Configuration

The script creates `assets/icons/menu/menu_config.json`:

```json
[
  { "icon": "menu_icon_0.png", "label": "Home" },
  { "icon": "menu_icon_1.png", "label": "Search" },
  { "icon": "menu_icon_2.png", "label": "Profile" }
]
```

## 🔄 Workflow Integration

### Stage 1: Enhanced Branding Assets (FIRST STAGE)

The script is now called as the very first stage in the iOS workflow:

```bash
# Stage 1: Enhanced Branding Assets Setup (FIRST STAGE)
log_info "--- Stage 1: Enhanced Branding Assets Setup (FIRST STAGE) ---"
log_info "🚀 This is the FIRST script in the iOS workflow"
log_info "📋 Handling all basic app information: WORKFLOW_ID, APP_ID, VERSION_NAME, VERSION_CODE, APP_NAME, ORG_NAME, BUNDLE_ID, WEB_URL, LOGO_URL, SPLASH_URL, SPLASH_BG_URL, BOTTOMMENU_ITEMS"

# Make branding assets script executable
chmod +x "${SCRIPT_DIR}/branding_assets.sh"

# Run enhanced branding assets setup
if ! "${SCRIPT_DIR}/branding_assets.sh"; then
    send_email "build_failed" "iOS" "${CM_BUILD_ID:-unknown}" "Enhanced branding assets setup failed."
    return 1
fi
```

### Subsequent Stages

- **Stage 1.5**: Environment Variable Validation
- **Stage 1.7**: Pre-build Setup
- **Stage 2**: Build Started Email
- **Stage 3**: Certificate Validation
- **Stage 4**: Generate Flutter Launcher Icons (uses logo from Stage 1)

## 🧪 Testing

### Test Script

Run the test script to verify functionality:

```bash
./test_enhanced_branding_assets.sh
```

### Test Environment Variables

The test script sets up all required variables:

```bash
export WORKFLOW_ID="test_workflow_123"
export APP_ID="com.testcompany.testapp"
export VERSION_NAME="1.0.0"
export VERSION_CODE="1"
export APP_NAME="Test App"
export ORG_NAME="Test Company"
export BUNDLE_ID="com.testcompany.testapp"
export WEB_URL="https://testcompany.com"
export LOGO_URL="https://via.placeholder.com/1024x1024/007AFF/FFFFFF?text=Logo"
export SPLASH_URL="https://via.placeholder.com/2048x2048/007AFF/FFFFFF?text=Splash"
export SPLASH_BG_URL="https://via.placeholder.com/2048x2048/000000/FFFFFF?text=Background"
export BOTTOMMENU_ITEMS="https://via.placeholder.com/64x64/FF0000/FFFFFF?text=Home:Home,https://via.placeholder.com/64x64/00FF00/FFFFFF?text=Search:Search,https://via.placeholder.com/64x64/0000FF/FFFFFF?text=Profile:Profile"
```

## 🛡️ Error Handling

### Validation Errors

- Missing required environment variables
- Invalid bundle identifier format
- Invalid version format
- Download failures

### Fallback Mechanisms

- Creates fallback PNG assets if downloads fail
- Uses logo as splash if splash URL not provided
- Applies basic bundle ID updates if comprehensive fixes fail
- Manual file updates if plutil is not available

### Backup Files

The script creates backups before making changes:

- `pubspec.yaml.basic_info.backup`
- `ios/Runner/Info.plist.basic_info.backup`
- `ios/Runner.xcodeproj/project.pbxproj.basic_info.backup`

## 📊 Output Summary

The script provides comprehensive output including:

```
📊 Enhanced Branding Summary:
   WORKFLOW_ID: test_workflow_123
   APP_ID: com.testcompany.testapp
   VERSION_NAME: 1.0.0
   VERSION_CODE: 1
   APP_NAME: Test App
   ORG_NAME: Test Company
   BUNDLE_ID: com.testcompany.testapp
   WEB_URL: https://testcompany.com

🛡️ CFBundleIdentifier Collision Prevention:
   ✅ Bundle-ID-Rules compliance applied
   ✅ Unique bundle IDs for all target types
   ✅ Test targets: com.testcompany.testapp.tests
   ✅ Extensions: com.testcompany.testapp.extension
   ✅ Frameworks: com.testcompany.testapp.framework
   🛡️ ALL CFBundleIdentifier collision errors PREVENTED

   Version (Environment): 1.0.0 (build 1)
   Version (pubspec.yaml): 1.0.0+1
   ✅ Version successfully updated from environment variables

   Logo: downloaded
   Splash: downloaded
   Splash Background: downloaded

   Bottom Menu Items: 3 items configured
     - Home (https://via.placeholder.com/64x64/FF0000/FFFFFF?text=Home)
     - Search (https://via.placeholder.com/64x64/00FF00/FFFFFF?text=Search)
     - Profile (https://via.placeholder.com/64x64/0000FF/FFFFFF?text=Profile)
```

## 🚀 Benefits

1. **Early Configuration**: All app information is set up first
2. **Comprehensive Validation**: Ensures no critical information is missing
3. **Asset Management**: Automatic download and processing of all assets
4. **Collision Prevention**: Built-in bundle identifier collision prevention
5. **Error Recovery**: Multiple fallback mechanisms for robustness
6. **Menu Integration**: Automatic bottom menu configuration with custom icons
7. **Version Management**: Centralized version control across all files

## 🔧 Troubleshooting

### Common Issues

1. **Missing Environment Variables**

   - Ensure all required variables are set
   - Check variable names for typos

2. **Download Failures**

   - Verify URLs are accessible
   - Check network connectivity
   - Script will create fallback assets

3. **Bundle ID Format Issues**

   - Use only alphanumeric characters and dots
   - Avoid underscores, hyphens, or special characters
   - Format: com.company.app

4. **Version Format Issues**
   - VERSION_NAME: X.Y.Z format (e.g., 1.0.0)
   - VERSION_CODE: Numeric only (e.g., 1)

### Debug Mode

Add debug logging by setting:

```bash
export DEBUG=true
```

## 📝 Best Practices

1. **Set All Required Variables**: Always provide all required environment variables
2. **Use Valid URLs**: Ensure all asset URLs are accessible and return valid images
3. **Test Menu Items**: Verify bottom menu item format before deployment
4. **Version Consistency**: Keep VERSION_NAME and VERSION_CODE in sync
5. **Backup Before Changes**: The script creates backups, but manual backups are recommended
6. **Monitor Output**: Review the comprehensive output summary for any issues

## 🔄 Migration from Old Workflow

If migrating from the old workflow:

1. **Move branding_assets.sh to Stage 1**: Already done in this update
2. **Update environment variables**: Add any missing required variables
3. **Test thoroughly**: Run the test script to verify functionality
4. **Update documentation**: Inform team of new variable requirements
5. **Monitor builds**: Watch for any issues in the new workflow order
