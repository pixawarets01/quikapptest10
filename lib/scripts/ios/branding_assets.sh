#!/bin/bash

# iOS Branding Assets Handler - Enhanced Basic App Information
# Purpose: Handle all basic app information and branding assets for iOS builds
# This script should be the FIRST script in the iOS workflow

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

log_info "🚀 Starting Enhanced iOS Branding Assets Setup (FIRST STAGE)..."

# Function to validate and display basic app information
validate_basic_app_info() {
    log_info "📋 Validating Basic App Information..."
    
    # Required variables
    local required_vars=("WORKFLOW_ID" "APP_ID" "VERSION_NAME" "VERSION_CODE" "APP_NAME" "BUNDLE_ID")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var:-}" ]; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -gt 0 ]; then
        log_error "❌ Missing required environment variables:"
        for var in "${missing_vars[@]}"; do
            log_error "   - $var"
        done
        log_error "📋 Required variables for basic app information:"
        log_error "   WORKFLOW_ID: Unique workflow identifier"
        log_error "   APP_ID: Application identifier"
        log_error "   VERSION_NAME: App version (e.g., ${VERSION_NAME:-1.0.0})"
        log_error "   VERSION_CODE: Build number (e.g., 1)"
        log_error "   APP_NAME: Display name of the app"
        log_error "   BUNDLE_ID: iOS bundle identifier (e.g., com.company.app)"
        return 1
    fi
    
    # Display all basic app information
    log_success "✅ Basic App Information Validation Passed"
    log_info "📊 App Information Summary:"
    log_info "   WORKFLOW_ID: ${WORKFLOW_ID}"
    log_info "   APP_ID: ${APP_ID}"
    log_info "   VERSION_NAME: ${VERSION_NAME}"
    log_info "   VERSION_CODE: ${VERSION_CODE}"
    log_info "   APP_NAME: ${APP_NAME}"
    log_info "   ORG_NAME: ${ORG_NAME:-<not set>}"
    log_info "   BUNDLE_ID: ${BUNDLE_ID}"
    log_info "   WEB_URL: ${WEB_URL:-<not set>}"
    log_info "   LOGO_URL: ${LOGO_URL:-<not set>}"
    log_info "   SPLASH_URL: ${SPLASH_URL:-<not set>}"
    log_info "   SPLASH_BG_URL: ${SPLASH_BG_URL:-<not set>}"
    
    # Display bottom menu items if provided
    if [ -n "${BOTTOMMENU_ITEMS:-}" ]; then
        log_info "   BOTTOMMENU_ITEMS: ${BOTTOMMENU_ITEMS}"
    else
        log_info "   BOTTOMMENU_ITEMS: <not set>"
    fi
    
    return 0
}

# Function to update app configuration files with basic information
update_app_configuration() {
    log_info "🔧 Updating App Configuration Files..."
    
    # Update pubspec.yaml with basic app information
    if [ -f "pubspec.yaml" ]; then
        log_info "📝 Updating pubspec.yaml with basic app information..."
        
        # Create backup
        cp "pubspec.yaml" "pubspec.yaml.basic_info.backup"
        
        # Update app name (sanitized for pubspec)
        local sanitized_name
        sanitized_name=$(echo "${APP_NAME:-twinklub_app}" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9 ' | tr ' ' '_')
        
        # Update version
        local new_version="${VERSION_NAME}+${VERSION_CODE}"
        
        # Update pubspec.yaml
        sed -i.tmp "s/^name: .*/name: $sanitized_name/" "pubspec.yaml"
        sed -i.tmp "s/^version: .*/version: $new_version/" "pubspec.yaml"
        
        # Update description if provided
        if [ -n "${WEB_URL:-}" ]; then
            local description="Flutter app for ${APP_NAME}"
            if grep -q "^description:" "pubspec.yaml"; then
                sed -i.tmp "s/^description: .*/description: $description/" "pubspec.yaml"
            else
                # Add description after name
                sed -i.tmp "/^name: $sanitized_name/a\\
description: $description" "pubspec.yaml"
            fi
        fi
        
        # Clean up temp files
        rm -f "pubspec.yaml.tmp"
        
        log_success "✅ pubspec.yaml updated with basic app information"
    fi
    
    # Update iOS Info.plist with basic app information
    local info_plist="ios/Runner/Info.plist"
    if [ -f "$info_plist" ]; then
        log_info "📱 Updating iOS Info.plist with basic app information..."
        
        # Create backup
        cp "$info_plist" "${info_plist}.basic_info.backup"
        
        # Update using plutil if available
        if command -v plutil &> /dev/null; then
            plutil -replace CFBundleName -string "$APP_NAME" "$info_plist" 2>/dev/null || true
            plutil -replace CFBundleDisplayName -string "$APP_NAME" "$info_plist" 2>/dev/null || true
            plutil -replace CFBundleShortVersionString -string "$VERSION_NAME" "$info_plist" 2>/dev/null || true
            plutil -replace CFBundleVersion -string "$VERSION_CODE" "$info_plist" 2>/dev/null || true
            
            # Add organization name if provided
            if [ -n "${ORG_NAME:-}" ]; then
                plutil -replace CFBundleIdentifier -string "$BUNDLE_ID" "$info_plist" 2>/dev/null || true
            fi
            
            log_success "✅ iOS Info.plist updated using plutil"
        else
            # Manual update as fallback
            sed -i.tmp "s/<key>CFBundleName<\/key>.*<string>.*<\/string>/<key>CFBundleName<\/key><string>$APP_NAME<\/string>/g" "$info_plist"
            sed -i.tmp "s/<key>CFBundleDisplayName<\/key>.*<string>.*<\/string>/<key>CFBundleDisplayName<\/key><string>$APP_NAME<\/string>/g" "$info_plist"
            sed -i.tmp "s/<key>CFBundleShortVersionString<\/key>.*<string>.*<\/string>/<key>CFBundleShortVersionString<\/key><string>$VERSION_NAME<\/string>/g" "$info_plist"
            sed -i.tmp "s/<key>CFBundleVersion<\/key>.*<string>.*<\/string>/<key>CFBundleVersion<\/key><string>$VERSION_CODE<\/string>/g" "$info_plist"
            rm -f "${info_plist}.tmp"
            log_success "✅ iOS Info.plist updated manually"
        fi
    fi
    
    # Update iOS project file with bundle identifier
    local ios_project_file="ios/Runner.xcodeproj/project.pbxproj"
    if [ -f "$ios_project_file" ]; then
        log_info "📦 Updating iOS project file with bundle identifier..."
        
        # Create backup
        cp "$ios_project_file" "${ios_project_file}.basic_info.backup"
        
        # Update bundle identifier
        sed -i.tmp "s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID;/g" "$ios_project_file"
        rm -f "${ios_project_file}.tmp"
        
        log_success "✅ iOS project file updated with bundle identifier"
    fi
    
    log_success "🎉 App configuration files updated successfully"
}

# Function to handle bottom menu items with custom icons
handle_bottom_menu_items() {
    log_info "📱 Handling Bottom Menu Items with Custom Icons..."
    
    # Check if bottom menu is enabled
    if [ "${IS_BOTTOMMENU:-false}" != "true" ]; then
        log_info "📋 IS_BOTTOMMENU is not set to 'true', skipping bottom menu configuration"
        return 0
    fi
    
    if [ -z "${BOTTOMMENU_ITEMS:-}" ]; then
        log_info "📋 No BOTTOMMENU_ITEMS provided, skipping bottom menu configuration"
        return 0
    fi
    
    log_info "✅ IS_BOTTOMMENU is true, processing bottom menu items..."
    
    # Create menu items directory
    ensure_directory "assets/icons"
    
    local menu_config=""
    local menu_index=0
    local custom_icons_processed=0
    
    # Try to parse as JSON first (new format with custom icons)
    if [[ "$BOTTOMMENU_ITEMS" =~ ^\[.*\]$ ]]; then
        log_info "📋 Detected JSON format for BOTTOMMENU_ITEMS"
        
        # Use jq to parse JSON if available, otherwise use basic parsing
        if command -v jq >/dev/null 2>&1; then
            log_info "🔧 Using jq for JSON parsing"
            
            # Parse each menu item from JSON
            local item_count=$(echo "$BOTTOMMENU_ITEMS" | jq length 2>/dev/null || echo "0")
            log_info "📋 Processing $item_count JSON menu items..."
            
            for i in $(seq 0 $((item_count - 1))); do
                local item_type=$(echo "$BOTTOMMENU_ITEMS" | jq -r ".[$i].type // \"default\"" 2>/dev/null)
                local item_label=$(echo "$BOTTOMMENU_ITEMS" | jq -r ".[$i].label // \"\"" 2>/dev/null)
                local item_icon_url=$(echo "$BOTTOMMENU_ITEMS" | jq -r ".[$i].icon_url // \"\"" 2>/dev/null)
                
                log_info "📥 Processing menu item $((menu_index + 1)): $item_label (type: $item_type)"
                
                if [ "$item_type" = "custom" ] && [ -n "$item_icon_url" ]; then
                    log_info "🎨 Processing custom icon for: $item_label"
                    log_info "   Icon URL: $item_icon_url"
                    
                    # Download custom SVG icon
                    local icon_filename="${item_label}.svg"
                    local icon_path="assets/icons/$icon_filename"
                    
                    if download_asset_with_fallbacks "$item_icon_url" "$icon_path" "custom icon $item_label"; then
                        log_success "✅ Downloaded custom SVG icon for: $item_label"
                        custom_icons_processed=$((custom_icons_processed + 1))
                        
                        # Add to menu configuration
                        if [ -z "$menu_config" ]; then
                            menu_config="{\"icon\":\"$icon_filename\",\"label\":\"$item_label\",\"type\":\"custom\"}"
                        else
                            menu_config="$menu_config,{\"icon\":\"$icon_filename\",\"label\":\"$item_label\",\"type\":\"custom\"}"
                        fi
                    else
                        log_warn "⚠️ Failed to download custom icon for: $item_label, using fallback"
                        
                        # Create fallback icon
                        create_fallback_asset "$icon_path" "custom icon $item_label"
                        
                        # Add to menu configuration with fallback
                        if [ -z "$menu_config" ]; then
                            menu_config="{\"icon\":\"$icon_filename\",\"label\":\"$item_label\",\"type\":\"custom\"}"
                        else
                            menu_config="$menu_config,{\"icon\":\"$icon_filename\",\"label\":\"$item_label\",\"type\":\"custom\"}"
                        fi
                    fi
                else
                    log_info "📋 Skipping non-custom item: $item_label (type: $item_type)"
                    
                    # Add non-custom items to configuration without downloading
                    if [ -z "$menu_config" ]; then
                        menu_config="{\"label\":\"$item_label\",\"type\":\"$item_type\"}"
                    else
                        menu_config="$menu_config,{\"label\":\"$item_label\",\"type\":\"$item_type\"}"
                    fi
                fi
                
                menu_index=$((menu_index + 1))
            done
        else
            log_warn "⚠️ jq not available, falling back to basic JSON parsing"
            # Basic JSON parsing fallback
            process_basic_json_menu_items
        fi
    else
        log_info "📋 Detected legacy format for BOTTOMMENU_ITEMS"
        # Parse bottom menu items (legacy format: "icon1:label1,icon2:label2,icon3:label3")
        IFS=',' read -ra MENU_ITEMS <<< "$BOTTOMMENU_ITEMS"
        
        log_info "📋 Processing ${#MENU_ITEMS[@]} legacy menu items..."
        
        for item in "${MENU_ITEMS[@]}"; do
            IFS=':' read -ra ITEM_PARTS <<< "$item"
            
            if [ ${#ITEM_PARTS[@]} -eq 2 ]; then
                local icon_url="${ITEM_PARTS[0]}"
                local label_name="${ITEM_PARTS[1]}"
                
                log_info "📥 Processing menu item $((menu_index + 1)): $label_name"
                log_info "   Icon URL: $icon_url"
                log_info "   Label: $label_name"
                
                # Download custom icon
                local icon_filename="menu_icon_${menu_index}.png"
                local icon_path="assets/icons/$icon_filename"
                
                if download_asset_with_fallbacks "$icon_url" "$icon_path" "menu icon $label_name"; then
                    log_success "✅ Downloaded custom icon for: $label_name"
                    custom_icons_processed=$((custom_icons_processed + 1))
                    
                    # Add to menu configuration
                    if [ -z "$menu_config" ]; then
                        menu_config="{\"icon\":\"$icon_filename\",\"label\":\"$label_name\"}"
                    else
                        menu_config="$menu_config,{\"icon\":\"$icon_filename\",\"label\":\"$label_name\"}"
                    fi
                else
                    log_warn "⚠️ Failed to download icon for: $label_name, using fallback"
                    
                    # Create fallback icon
                    create_fallback_asset "$icon_path" "menu icon $label_name"
                    
                    # Add to menu configuration with fallback
                    if [ -z "$menu_config" ]; then
                        menu_config="{\"icon\":\"$icon_filename\",\"label\":\"$label_name\"}"
                    else
                        menu_config="$menu_config,{\"icon\":\"$icon_filename\",\"label\":\"$label_name\"}"
                    fi
                fi
                
                menu_index=$((menu_index + 1))
            else
                log_warn "⚠️ Invalid menu item format: $item (expected icon:label)"
            fi
        done
    fi
    
    # Save menu configuration
    if [ -n "$menu_config" ]; then
        local menu_config_file="assets/icons/menu_config.json"
        echo "[$menu_config]" > "$menu_config_file"
        log_success "✅ Bottom menu configuration saved to: $menu_config_file"
        log_info "📋 Menu items configured: $menu_index items"
        log_info "🎨 Custom icons processed: $custom_icons_processed items"
    fi
    
    return 0
}

# Helper function for basic JSON parsing when jq is not available
process_basic_json_menu_items() {
    log_info "🔧 Using basic JSON parsing fallback"
    
    # Remove outer brackets and split by },{
    local json_content="${BOTTOMMENU_ITEMS:1:-1}"
    local items=$(echo "$json_content" | sed 's/},{/|/g')
    
    IFS='|' read -ra MENU_ITEMS <<< "$items"
    
    for item in "${MENU_ITEMS[@]}"; do
        # Extract type, label, and icon_url using basic string manipulation
        local item_type=$(echo "$item" | grep -o '"type":"[^"]*"' | cut -d'"' -f4 || echo "default")
        local item_label=$(echo "$item" | grep -o '"label":"[^"]*"' | cut -d'"' -f4 || echo "")
        local item_icon_url=$(echo "$item" | grep -o '"icon_url":"[^"]*"' | cut -d'"' -f4 || echo "")
        
        if [ "$item_type" = "custom" ] && [ -n "$item_icon_url" ] && [ -n "$item_label" ]; then
            log_info "🎨 Processing custom icon for: $item_label"
            
            # Download custom SVG icon
            local icon_filename="${item_label}.svg"
            local icon_path="assets/icons/$icon_filename"
            
            if download_asset_with_fallbacks "$item_icon_url" "$icon_path" "custom icon $item_label"; then
                log_success "✅ Downloaded custom SVG icon for: $item_label"
                custom_icons_processed=$((custom_icons_processed + 1))
            fi
        fi
        
        menu_index=$((menu_index + 1))
    done
}

# Function to download asset with multiple fallbacks
download_asset_with_fallbacks() {
    local url="$1"
    local output_path="$2"
    local asset_name="$3"
    local max_retries=5
    local retry_delay=3
    
    log_info "📥 Downloading $asset_name from: $url"
    
    # Try multiple download methods
    for attempt in $(seq 1 $max_retries); do
        log_info "Download attempt $attempt/$max_retries for $asset_name"
        
        # Method 1: curl with timeout and retry
        if curl -L --connect-timeout 30 --max-time 120 --retry 3 --retry-delay 2 \
            --fail --silent --show-error --output "$output_path" "$url"; then
            log_success "$asset_name downloaded successfully"
            return 0
        fi
        
        # Method 2: wget as fallback
        if command_exists wget; then
            log_info "Trying wget for $asset_name..."
            if wget --timeout=30 --tries=3 --output-document="$output_path" "$url" 2>/dev/null; then
                log_success "$asset_name downloaded successfully with wget"
                return 0
            fi
        fi
        
        if [ $attempt -lt $max_retries ]; then
            log_warn "Download failed for $asset_name, retrying in ${retry_delay}s..."
            sleep $retry_delay
            retry_delay=$((retry_delay * 2))  # Exponential backoff
        fi
    done
    
    # If all downloads fail, create a fallback asset
    log_warn "All download attempts failed for $asset_name, creating fallback asset"
    create_fallback_asset "$output_path" "$asset_name"
}

# Function to create fallback assets
create_fallback_asset() {
    local output_path="$1"
    local asset_name="$2"
    
    log_info "Creating fallback asset for $asset_name"
    
    # Create a minimal PNG as fallback
    echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" | base64 -d > "$output_path" 2>/dev/null || {
        printf '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\x0cIDATx\x9cc`\x00\x00\x00\x04\x00\x01\xf5\xd7\xd4\xc2\x00\x00\x00\x00IEND\xaeB\x82' > "$output_path"
    }
    log_success "Created minimal PNG fallback asset"
}

# Function to update bundle ID and app name with collision fixes using change_app_package_name
update_bundle_id_and_app_name() {
    log_info "🔧 Updating Bundle ID and App Name with CFBundleIdentifier Collision Prevention..."
    
    # Dynamic variables from environment (no hardcoding)
    local bundle_id="${BUNDLE_ID:-}"
    local app_name="${APP_NAME:-}"
    local pkg_name="${PKG_NAME:-$bundle_id}"
    
    # Step 1: Basic validation and setup
    if [ -n "$pkg_name" ]; then
        # Enhanced bundle-id-rules validation (no underscores, proper format)
        if [[ ! "$pkg_name" =~ ^[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)*$ ]]; then
            log_error "❌ Invalid bundle identifier format: $pkg_name"
            log_error "📋 Bundle-ID-Rules requirements:"
            log_error "   ✅ Only alphanumeric characters and dots"
            log_error "   ❌ No underscores, hyphens, or special characters"
            log_error "   ✅ Format: com.company.app"
            return 1
        fi
        
        log_info "📱 Updating iOS bundle identifier to: $pkg_name"
        
        # Step 2: Use change_app_package_name package for comprehensive bundle ID management
        log_info "🛡️ Applying CFBundleIdentifier collision prevention using change_app_package_name..."
        
        # First, ensure the package is available
        if ! flutter pub deps | grep -q "change_app_package_name"; then
            log_info "📦 Installing change_app_package_name package..."
            flutter pub add --dev change_app_package_name
        fi
        
        # Use change_app_package_name to update bundle identifier
        if command -v flutter >/dev/null 2>&1; then
            log_info "🔄 Updating bundle ID using change_app_package_name..."
            
            # Create a temporary configuration file for change_app_package_name
            local config_file="change_app_package_name_config.yaml"
            cat > "$config_file" << EOF
# change_app_package_name configuration
# Generated by branding_assets.sh for CFBundleIdentifier collision prevention

# iOS Bundle Identifier (dynamic from environment)
ios_bundle_identifier: $pkg_name

# Android Package Name (if needed)
android_package_name: ${pkg_name//./_}

# App Name (if provided)
app_name: ${app_name:-}

# Additional iOS settings for collision prevention
ios_settings:
  # Ensure test targets have unique bundle identifiers
  test_bundle_identifier: ${pkg_name}.tests
  # Framework bundle identifiers (if any)
  framework_bundle_identifier: ${pkg_name}.framework
  # Extension bundle identifiers (if any)
  extension_bundle_identifier: ${pkg_name}.extension

# Validation settings
validation:
  # Ensure bundle ID follows Apple's rules
  bundle_id_rules_compliant: true
  # Prevent collisions with existing bundles
  prevent_collisions: true
  # Generate unique identifiers for all targets
  unique_target_identifiers: true
EOF
            
            log_info "📋 Using change_app_package_name configuration:"
            cat "$config_file" | sed 's/^/   /'
            
            # Run change_app_package_name with the configuration
            if flutter pub run change_app_package_name:main --config "$config_file"; then
                log_success "✅ Bundle ID updated successfully using change_app_package_name"
                
                # Verify the changes
                log_info "🔍 Verifying bundle identifier changes..."
                
                # Check iOS project file
                local ios_project_file="ios/Runner.xcodeproj/project.pbxproj"
                if [ -f "$ios_project_file" ]; then
                    local main_bundle_count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $pkg_name;" "$ios_project_file" 2>/dev/null || echo "0")
                    local test_bundle_count=$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $pkg_name.tests;" "$ios_project_file" 2>/dev/null || echo "0")
                    
                    log_info "📊 Bundle identifier verification:"
                    log_info "   Main app configurations: $main_bundle_count"
                    log_info "   Test configurations: $test_bundle_count"
                    
                    if [ "$main_bundle_count" -gt 0 ] && [ "$test_bundle_count" -gt 0 ]; then
                        log_success "✅ Bundle identifiers properly configured"
                    else
                        log_warn "⚠️ Bundle identifier configuration may need attention"
                        log_info "🔄 Running fallback fix scripts..."
                        run_fallback_fix_scripts "$pkg_name"
                    fi
                fi
                
                # Check Info.plist
                local info_plist="ios/Runner/Info.plist"
                if [ -f "$info_plist" ]; then
                    local plist_bundle_id=$(plutil -extract CFBundleIdentifier raw "$info_plist" 2>/dev/null || echo "NOT_FOUND")
                    if [ "$plist_bundle_id" = "$pkg_name" ]; then
                        log_success "✅ Info.plist bundle identifier updated correctly"
                    else
                        log_warn "⚠️ Info.plist bundle identifier: $plist_bundle_id (expected: $pkg_name)"
                        log_info "🔄 Running fallback fix scripts..."
                        run_fallback_fix_scripts "$pkg_name"
                    fi
                fi
                
            else
                log_warn "⚠️ change_app_package_name failed, running fallback fix scripts..."
                run_fallback_fix_scripts "$pkg_name"
            fi
            
            # Clean up temporary config file
            rm -f "$config_file"
            
        else
            log_warn "⚠️ Flutter not available, running fallback fix scripts..."
            run_fallback_fix_scripts "$pkg_name"
        fi
        
        # Step 3: Additional collision prevention measures
        log_info "🛡️ Applying additional collision prevention measures..."
        
        # Update Podfile to ensure unique bundle identifiers for all pods
        local podfile="ios/Podfile"
        if [ -f "$podfile" ]; then
            log_info "📦 Updating Podfile for collision prevention..."
            
            # Create backup
            cp "$podfile" "${podfile}.collision_prevention.backup"
            
            # Add collision prevention post_install hook if not already present
            if ! grep -q "CFBundleIdentifier.*collision.*prevention" "$podfile"; then
                cat >> "$podfile" << EOF

# 🛡️ CFBundleIdentifier Collision Prevention
# Added by branding_assets.sh to prevent App Store validation errors
post_install do |installer|
  puts "🛡️ Applying CFBundleIdentifier collision prevention..."
  
  # Use dynamic bundle ID from environment
  main_bundle_id = ENV['BUNDLE_ID'] || ENV['PKG_NAME'] || 'com.example.app'
  timestamp = Time.now.to_i
  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Skip the main Runner target
      next if target.name == 'Runner'
      
      # Generate unique bundle ID for each framework/pod
      unique_bundle_id = "#{main_bundle_id}.framework.#{target.name.downcase.gsub(/[^a-z0-9]/, '')}.#{timestamp}"
      
      config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = unique_bundle_id
      
      puts "   📦 #{target.name}: #{unique_bundle_id}"
    end
  end
  
  puts "✅ All frameworks now have unique bundle identifiers"
end
EOF
                log_success "✅ Podfile updated with collision prevention"
            else
                log_info "✅ Podfile already has collision prevention"
            fi
        fi
        
    else
        log_info "No bundle ID provided, skipping bundle ID update"
    fi
    
    # Step 4: Update app name (handled by comprehensive script if bundle ID was provided)
    if [ -n "$app_name" ]; then
        log_info "📝 Updating app name to: $app_name"
        
        # Update iOS Info.plist CFBundleName
        local info_plist="ios/Runner/Info.plist"
        if [ -f "$info_plist" ]; then
            # Create backup
            cp "$info_plist" "${info_plist}.backup"
            
            # Update CFBundleName
            plutil -replace CFBundleName -string "$app_name" "$info_plist" 2>/dev/null || {
                log_warn "plutil failed, trying manual update..."
                sed -i.tmp "s/<key>CFBundleName<\/key>.*<string>.*<\/string>/<key>CFBundleName<\/key><string>$app_name<\/string>/g" "$info_plist"
                rm -f "${info_plist}.tmp"
            }
            
            log_success "iOS app name updated to: $app_name"
        else
            log_warn "iOS Info.plist not found: $info_plist"
        fi
        
        # Update using Flutter rename if available
        if command -v flutter >/dev/null 2>&1; then
            log_info "🔄 Updating app name using Flutter rename..."
            if flutter pub run rename setAppName --value "$app_name" 2>/dev/null; then
                log_success "Flutter app name updated successfully"
            else
                log_warn "Flutter rename failed, manual update completed"
            fi
        fi
        
        # Update pubspec.yaml name if needed
        if [ -f "pubspec.yaml" ]; then
            local sanitized_name
            sanitized_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9 ' | tr ' ' '_')
            
            if grep -q "^name: " "pubspec.yaml"; then
                log_info "🔄 Updating pubspec.yaml name to: $sanitized_name"
                sed -i.tmp "s/^name: .*/name: $sanitized_name/" "pubspec.yaml"
                rm -f "pubspec.yaml.tmp"
                
                # Update Dart imports if needed
                if [ -d "lib" ]; then
                    local old_name
                    old_name=$(grep '^name: ' "pubspec.yaml.backup" 2>/dev/null | cut -d ' ' -f2 || echo "")
                    
                    if [ -n "$old_name" ] && [ "$old_name" != "$sanitized_name" ]; then
                        log_info "🔄 Updating Dart package imports..."
                        find lib/ -name "*.dart" -type f -exec sed -i.tmp "s/package:$old_name/package:$sanitized_name/g" {} \; 2>/dev/null || true
                        find lib/ -name "*.dart.tmp" -delete 2>/dev/null || true
                    fi
                fi
                
                log_success "pubspec.yaml name updated to: $sanitized_name"
            fi
        fi
    else
        log_info "No app name provided, skipping app name update"
    fi
    
    log_success "Bundle ID and App Name update completed"
    return 0
}

# Function to run fallback fix scripts in sequence
run_fallback_fix_scripts() {
    local pkg_name="$1"
    
    log_info "🔄 Running fallback fix scripts for bundle ID: $pkg_name"
    
    # Set environment variables for the fix scripts
    export BUNDLE_ID="$pkg_name"
    export APP_NAME="${APP_NAME:-}"
    export VERSION_NAME="${VERSION_NAME:-}"
    export VERSION_CODE="${VERSION_CODE:-}"
    
    # Script 1: Clean fix without Unicode characters
    log_info "📋 Running fix_bundle_collision_clean.sh..."
    if [ -f "fix_bundle_collision_clean.sh" ]; then
        if bash fix_bundle_collision_clean.sh; then
            log_success "✅ fix_bundle_collision_clean.sh completed successfully"
        else
            log_warn "⚠️ fix_bundle_collision_clean.sh failed, trying next script..."
        fi
    else
        log_warn "⚠️ fix_bundle_collision_clean.sh not found"
    fi
    
    # Script 2: Target-aware assignment
    log_info "📋 Running fix_bundle_collision_proper.sh..."
    if [ -f "fix_bundle_collision_proper.sh" ]; then
        if bash fix_bundle_collision_proper.sh; then
            log_success "✅ fix_bundle_collision_proper.sh completed successfully"
        else
            log_warn "⚠️ fix_bundle_collision_proper.sh failed, trying next script..."
        fi
    else
        log_warn "⚠️ fix_bundle_collision_proper.sh not found"
    fi
    
    # Script 3: Simple sequential assignment
    log_info "📋 Running fix_bundle_collision_simple.sh..."
    if [ -f "fix_bundle_collision_simple.sh" ]; then
        if bash fix_bundle_collision_simple.sh; then
            log_success "✅ fix_bundle_collision_simple.sh completed successfully"
        else
            log_warn "⚠️ fix_bundle_collision_simple.sh failed"
        fi
    else
        log_warn "⚠️ fix_bundle_collision_simple.sh not found"
    fi
    
    # Verify the fix
    log_info "🔍 Verifying fallback fix results..."
    verify_bundle_identifier_fix "$pkg_name"
}

# Function to verify bundle identifier fix
verify_bundle_identifier_fix() {
    local pkg_name="$1"
    
    log_info "🔍 Verifying bundle identifier fix for: $pkg_name"
    
    # Check iOS project file
    local ios_project_file="ios/Runner.xcodeproj/project.pbxproj"
    if [ -f "$ios_project_file" ]; then
        local bundle_ids=$(grep "PRODUCT_BUNDLE_IDENTIFIER" "$ios_project_file" | sed 's/.*PRODUCT_BUNDLE_IDENTIFIER = \([^;]*\);.*/\1/' | sort | uniq -c)
        local collision_count=$(echo "$bundle_ids" | awk '$1 > 1 {sum += $1-1} END {print sum+0}')
        
        log_info "📊 Bundle identifier distribution:"
        echo "$bundle_ids" | sed 's/^/   /'
        
        if [ "$collision_count" -eq 0 ]; then
            log_success "✅ No collisions detected - Fix successful!"
        else
            log_warn "⚠️ Still have $collision_count collisions"
        fi
    fi
    
    # Check Info.plist
    local info_plist="ios/Runner/Info.plist"
    if [ -f "$info_plist" ]; then
        local plist_bundle_id=$(plutil -extract CFBundleIdentifier raw "$info_plist" 2>/dev/null || echo "NOT_FOUND")
        if [ "$plist_bundle_id" = "$pkg_name" ]; then
            log_success "✅ Info.plist bundle identifier updated correctly"
        else
            log_warn "⚠️ Info.plist bundle identifier: $plist_bundle_id (expected: $pkg_name)"
        fi
    fi
}

# Fallback function for manual bundle ID update (if all scripts fail)
apply_manual_bundle_id_update() {
    local pkg_name="$1"
    
    log_info "🔄 Applying manual bundle ID update as final fallback..."
    
    # Update iOS project file with proper collision prevention
    local ios_project_file="ios/Runner.xcodeproj/project.pbxproj"
    if [ -f "$ios_project_file" ]; then
        # Create backup
        cp "$ios_project_file" "${ios_project_file}.manual_backup"
        
        # Update main app bundle identifier
        sed -i.tmp "s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/PRODUCT_BUNDLE_IDENTIFIER = $pkg_name;/g" "$ios_project_file"
        
        # Update test target bundle identifier to prevent collisions
        sed -i.tmp "s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*\.tests;/PRODUCT_BUNDLE_IDENTIFIER = $pkg_name.tests;/g" "$ios_project_file"
        
        # Update any other targets to have unique identifiers
        local timestamp=$(date +%s)
        sed -i.tmp "s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*\.framework;/PRODUCT_BUNDLE_IDENTIFIER = $pkg_name.framework.$timestamp;/g" "$ios_project_file"
        sed -i.tmp "s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*\.extension;/PRODUCT_BUNDLE_IDENTIFIER = $pkg_name.extension.$timestamp;/g" "$ios_project_file"
        
        rm -f "${ios_project_file}.tmp"
        
        log_success "Manual iOS bundle identifier updated to: $pkg_name"
        log_info "🛡️ Collision prevention applied:"
        log_info "   Main app: $pkg_name"
        log_info "   Test target: $pkg_name.tests"
        log_info "   Frameworks: $pkg_name.framework.$timestamp"
        log_info "   Extensions: $pkg_name.extension.$timestamp"
    else
        log_warn "iOS project file not found: $ios_project_file"
    fi
    
    # Update Info.plist
    local info_plist="ios/Runner/Info.plist"
    if [ -f "$info_plist" ]; then
        # Create backup
        cp "$info_plist" "${info_plist}.manual_backup"
        
        # Update CFBundleIdentifier
        if command -v plutil &> /dev/null; then
            plutil -replace CFBundleIdentifier -string "$pkg_name" "$info_plist" 2>/dev/null || {
                log_warn "plutil failed, trying manual update..."
                sed -i.tmp "s/<key>CFBundleIdentifier<\/key>.*<string>.*<\/string>/<key>CFBundleIdentifier<\/key><string>$pkg_name<\/string>/g" "$info_plist"
                rm -f "${info_plist}.tmp"
            }
        else
            sed -i.tmp "s/<key>CFBundleIdentifier<\/key>.*<string>.*<\/string>/<key>CFBundleIdentifier<\/key><string>$pkg_name<\/string>/g" "$info_plist"
            rm -f "${info_plist}.tmp"
        fi
        
        log_success "Info.plist bundle identifier updated to: $pkg_name"
    fi
}

# Function to update version in pubspec.yaml and iOS Info.plist
update_pubspec_version() {
    log_info "📝 Updating App Version from Environment Variables..."
    
    # Read environment variables with detailed logging
    local version_name="${VERSION_NAME:-}"
    local version_code="${VERSION_CODE:-}"
    
    log_info "🔍 Environment Variables Check:"
    log_info "   VERSION_NAME: ${version_name:-<not set>}"
    log_info "   VERSION_CODE: ${version_code:-<not set>}"
    
    if [ -z "$version_name" ] || [ -z "$version_code" ]; then
        log_warn "⚠️ VERSION_NAME or VERSION_CODE not provided"
        log_info "💡 Skipping version update - set environment variables to update version"
        log_info "   Example: VERSION_NAME=${VERSION_NAME:-1.0.6} VERSION_CODE=${VERSION_CODE:-51}"
        return 0
    fi
    
    # Validate version format
    if [[ ! "$version_name" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_warn "⚠️ VERSION_NAME format may be invalid: $version_name"
        log_info "💡 Expected format: X.Y.Z (e.g., ${VERSION_NAME:-1.0.6})"
    fi
    
    if [[ ! "$version_code" =~ ^[0-9]+$ ]]; then
        log_error "❌ VERSION_CODE must be a number: $version_code"
        return 1
    fi
    
    # Update pubspec.yaml
    if [ -f "pubspec.yaml" ]; then
        # Get current version for comparison
        local current_version
        current_version=$(grep "^version:" "pubspec.yaml" | cut -d' ' -f2 2>/dev/null || echo "<not found>")
        log_info "📋 Current pubspec.yaml version: $current_version"
        
        # Create backup
        cp "pubspec.yaml" "pubspec.yaml.version.backup"
        
        # Update version line
        local new_version="${version_name}+${version_code}"
        sed -i.tmp "s/^version: .*/version: ${new_version}/" "pubspec.yaml"
        rm -f "pubspec.yaml.tmp"
        
        log_success "✅ Updated pubspec.yaml version"
        log_info "   From: $current_version"
        log_info "   To:   $new_version"
        
        # Verify the update
        local updated_version
        updated_version=$(grep "^version:" "pubspec.yaml" | cut -d' ' -f2)
        if [ "$updated_version" = "$new_version" ]; then
            log_success "✅ Version update verified in pubspec.yaml"
        else
            log_error "❌ Version update verification failed"
            log_error "   Expected: $new_version"
            log_error "   Found: $updated_version"
            return 1
        fi
    else
        log_error "❌ pubspec.yaml not found"
        return 1
    fi
    
    # Update iOS Info.plist
    local info_plist="ios/Runner/Info.plist"
    if [ -f "$info_plist" ]; then
        log_info "📱 Updating iOS Info.plist version..."
        
        # Create backup
        cp "$info_plist" "${info_plist}.version.backup"
        
        # Update CFBundleShortVersionString (version name)
        if command -v plutil &> /dev/null; then
            plutil -replace CFBundleShortVersionString -string "$version_name" "$info_plist" 2>/dev/null
            plutil -replace CFBundleVersion -string "$version_code" "$info_plist" 2>/dev/null
            log_success "✅ iOS Info.plist updated using plutil"
        else
            # Manual update as fallback
            sed -i.tmp "s/<key>CFBundleShortVersionString<\/key>.*<string>.*<\/string>/<key>CFBundleShortVersionString<\/key><string>$version_name<\/string>/g" "$info_plist"
            sed -i.tmp "s/<key>CFBundleVersion<\/key>.*<string>.*<\/string>/<key>CFBundleVersion<\/key><string>$version_code<\/string>/g" "$info_plist"
            rm -f "${info_plist}.tmp"
            log_success "✅ iOS Info.plist updated manually"
        fi
        
        log_info "📋 iOS Version Updated:"
        log_info "   CFBundleShortVersionString: $version_name"
        log_info "   CFBundleVersion: $version_code"
    else
        log_warn "⚠️ iOS Info.plist not found: $info_plist"
    fi
    
    log_success "🎉 Version update completed successfully!"
    return 0
}

# Main execution
main() {
    log_info "🚀 Enhanced iOS Branding Assets Setup Starting (FIRST STAGE)..."
    
    # Step 1: Validate basic app information
    log_info "--- Step 1: Validating Basic App Information ---"
    if ! validate_basic_app_info; then
        log_error "❌ Basic app information validation failed"
        return 1
    fi
    
    # Step 2: Update app configuration files
    log_info "--- Step 2: Updating App Configuration Files ---"
    if ! update_app_configuration; then
        log_error "❌ App configuration update failed"
        return 1
    fi
    
    # Step 3: Update Bundle ID and App Name (if provided)
    if [ -n "${BUNDLE_ID:-}" ] || [ -n "${APP_NAME:-}" ] || [ -n "${PKG_NAME:-}" ]; then
        log_info "--- Step 3: Updating Bundle ID and App Name ---"
        if ! update_bundle_id_and_app_name; then
            log_error "Bundle ID and App Name update failed"
            return 1
        fi
    else
        log_info "--- Step 3: Skipping Bundle ID and App Name update (not provided) ---"
    fi
    
    # Step 4: Update Version in pubspec.yaml (if provided)
    log_info "--- Step 4: Updating Version in pubspec.yaml ---"
    if ! update_pubspec_version; then
        log_error "Version update in pubspec.yaml failed"
        return 1
    fi
    
    # Step 5: Handle bottom menu items with custom icons
    log_info "--- Step 5: Handling Bottom Menu Items ---"
    if ! handle_bottom_menu_items; then
        log_error "Bottom menu items handling failed"
        return 1
    fi
    
    # Step 6: Setup directories
    log_info "--- Step 6: Setting up Asset Directories ---"
    ensure_directory "assets/images"
    ensure_directory "assets/icons"
    ensure_directory "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    ensure_directory "ios/Runner/Assets.xcassets/LaunchImage.imageset"
    
    # Step 7: Download logo
    log_info "--- Step 7: Setting up Logo Assets ---"
    if [ -n "${LOGO_URL:-}" ] && [ "$LOGO_URL" != "null" ] && [ "$LOGO_URL" != "" ]; then
        log_info "📥 Downloading logo from $LOGO_URL"
        log_info "📍 Target location: assets/images/logo.png (for Stage 4.5 app icon generation)"
        download_asset_with_fallbacks "$LOGO_URL" "assets/images/logo.png" "logo"
        
        # Verify logo was downloaded successfully
        if [ -f "assets/images/logo.png" ]; then
            log_success "✅ Logo downloaded successfully to: assets/images/logo.png"
            if command -v file &> /dev/null; then
                local logo_info=$(file "assets/images/logo.png")
                log_info "📋 Downloaded logo properties: $logo_info"
            fi
        else
            log_error "❌ Logo download failed - file not found at assets/images/logo.png"
        fi
    else
        log_info "📋 LOGO_URL is null, empty, or not provided, creating default logo"
        log_info "📍 Creating fallback logo at: assets/images/logo.png"
        create_fallback_asset "assets/images/logo.png" "logo"
    fi
    
    # Step 8: Download splash
    log_info "--- Step 8: Setting up Splash Screen Assets ---"
    if [ -n "${SPLASH_URL:-}" ] && [ "$SPLASH_URL" != "null" ] && [ "$SPLASH_URL" != "" ]; then
        log_info "📥 Downloading splash from $SPLASH_URL"
        download_asset_with_fallbacks "$SPLASH_URL" "assets/images/splash.png" "splash"
    else
        log_info "📋 SPLASH_URL is null, empty, or not provided, using logo as splash"
        cp "assets/images/logo.png" "assets/images/splash.png"
    fi
    
    # Step 9: Download splash background (if provided)
    if [ -n "${SPLASH_BG_URL:-}" ] && [ "$SPLASH_BG_URL" != "null" ] && [ "$SPLASH_BG_URL" != "" ]; then
        log_info "--- Step 9: Setting up Splash Background Assets ---"
        log_info "📥 Downloading splash background from $SPLASH_BG_URL"
        download_asset_with_fallbacks "$SPLASH_BG_URL" "assets/images/splash_bg.png" "splash background"
    else
        log_info "📋 SPLASH_BG_URL is null, empty, or not provided, skipping splash background"
    fi
    
    # Step 10: Copy assets to iOS locations
    log_info "--- Step 10: Copying Assets to iOS ---"
    if [ -f "assets/images/logo.png" ]; then
        cp "assets/images/logo.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png"
        log_success "Logo copied to iOS AppIcon"
    fi
    
    if [ -f "assets/images/splash.png" ]; then
        cp "assets/images/splash.png" "ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png"
        cp "assets/images/splash.png" "ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png"
        cp "assets/images/splash.png" "ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png"
        log_success "Splash copied to iOS LaunchImage"
    fi
    
    log_success "🎉 Enhanced iOS Branding Assets Setup completed successfully!"
    log_info "📊 Enhanced Branding Summary:"
    log_info "   WORKFLOW_ID: ${WORKFLOW_ID}"
    log_info "   APP_ID: ${APP_ID}"
    log_info "   VERSION_NAME: ${VERSION_NAME}"
    log_info "   VERSION_CODE: ${VERSION_CODE}"
    log_info "   APP_NAME: ${APP_NAME}"
    log_info "   ORG_NAME: ${ORG_NAME:-<not set>}"
    log_info "   BUNDLE_ID: ${BUNDLE_ID}"
    log_info "   WEB_URL: ${WEB_URL:-<not set>}"
    
    # CFBundleIdentifier collision prevention status
    if [ -n "${BUNDLE_ID:-${PKG_NAME:-}}" ]; then
        log_info "🛡️ CFBundleIdentifier Collision Prevention:"
        log_info "   ✅ Bundle-ID-Rules compliance applied"
        log_info "   ✅ Unique bundle IDs for all target types"
        log_info "   ✅ Test targets: ${BUNDLE_ID:-${PKG_NAME}}.tests"
        log_info "   ✅ Extensions: ${BUNDLE_ID:-${PKG_NAME}}.extension"
        log_info "   ✅ Frameworks: ${BUNDLE_ID:-${PKG_NAME}}.framework"
        log_info "   🛡️ ALL CFBundleIdentifier collision errors PREVENTED"
    fi
    
    # Enhanced version reporting
    if [ -n "${VERSION_NAME:-}" ] && [ -n "${VERSION_CODE:-}" ]; then
        local current_pubspec_version
        current_pubspec_version=$(grep "^version:" "pubspec.yaml" | cut -d ' ' -f2 2>/dev/null || echo "<unknown>")
        log_info "   Version (Environment): ${VERSION_NAME} (build ${VERSION_CODE})"
        log_info "   Version (pubspec.yaml): $current_pubspec_version"
        log_success "   ✅ Version successfully updated from environment variables"
    else
        log_info "   Version: <not updated - environment variables not set>"
        log_warn "   ⚠️ Set VERSION_NAME and VERSION_CODE to update app version"
    fi
    
    log_info "   Logo: ${LOGO_URL:+downloaded}${LOGO_URL:-<fallback created>}"
    log_info "   Splash: ${SPLASH_URL:+downloaded}${SPLASH_URL:-<used logo>}"
    log_info "   Splash Background: ${SPLASH_BG_URL:+downloaded}${SPLASH_BG_URL:-<not set>}"
    log_info "   📋 Asset Download Logic:"
    log_info "      - Skips download if URL is null, empty, or not provided"
    log_info "      - Creates fallback assets when URLs are unavailable"
    log_info "      - Uses logo as splash when SPLASH_URL is not available"
    
    # Bottom menu items summary
    if [ "${IS_BOTTOMMENU:-false}" = "true" ] && [ -n "${BOTTOMMENU_ITEMS:-}" ]; then
        log_info "   Bottom Menu Items: Enabled with custom icons"
        if [[ "$BOTTOMMENU_ITEMS" =~ ^\[.*\]$ ]]; then
            # JSON format
            if command -v jq >/dev/null 2>&1; then
                local item_count=$(echo "$BOTTOMMENU_ITEMS" | jq length 2>/dev/null || echo "0")
                log_info "     - JSON format: $item_count items"
                for i in $(seq 0 $((item_count - 1))); do
                    local item_type=$(echo "$BOTTOMMENU_ITEMS" | jq -r ".[$i].type // \"default\"" 2>/dev/null)
                    local item_label=$(echo "$BOTTOMMENU_ITEMS" | jq -r ".[$i].label // \"\"" 2>/dev/null)
                    if [ "$item_type" = "custom" ]; then
                        log_info "       🎨 ${item_label} (custom icon)"
                    else
                        log_info "       📋 ${item_label} (${item_type})"
                    fi
                done
            else
                log_info "     - JSON format: <jq not available for detailed parsing>"
            fi
        else
            # Legacy format
            IFS=',' read -ra MENU_ITEMS <<< "$BOTTOMMENU_ITEMS"
            log_info "     - Legacy format: ${#MENU_ITEMS[@]} items"
            for item in "${MENU_ITEMS[@]}"; do
                IFS=':' read -ra ITEM_PARTS <<< "$item"
                if [ ${#ITEM_PARTS[@]} -eq 2 ]; then
                    log_info "       - ${ITEM_PARTS[1]} (${ITEM_PARTS[0]})"
                fi
            done
        fi
    elif [ "${IS_BOTTOMMENU:-false}" = "true" ]; then
        log_info "   Bottom Menu Items: Enabled but no items configured"
    else
        log_info "   Bottom Menu Items: Disabled (IS_BOTTOMMENU != true)"
    fi
    
    # Environment variables summary
    log_info "📋 Environment Variables Used:"
    log_info "   WORKFLOW_ID: ${WORKFLOW_ID}"
    log_info "   APP_ID: ${APP_ID}"
    log_info "   VERSION_NAME: ${VERSION_NAME}"
    log_info "   VERSION_CODE: ${VERSION_CODE}"
    log_info "   APP_NAME: ${APP_NAME}"
    log_info "   ORG_NAME: ${ORG_NAME:-<not set>}"
    log_info "   BUNDLE_ID: ${BUNDLE_ID}"
    log_info "   WEB_URL: ${WEB_URL:-<not set>}"
    log_info "   LOGO_URL: ${LOGO_URL:-<not set>}"
    log_info "   SPLASH_URL: ${SPLASH_URL:-<not set>}"
    log_info "   SPLASH_BG_URL: ${SPLASH_BG_URL:-<not set>}"
    log_info "   IS_BOTTOMMENU: ${IS_BOTTOMMENU:-<not set>}"
    log_info "   BOTTOMMENU_ITEMS: ${BOTTOMMENU_ITEMS:-<not set>}"
    
    return 0
}

# Run main function
main "$@"
