#!/bin/bash

# Enhanced Conditional Firebase Injection Script
# Purpose: Enable or disable Firebase and push notifications based on PUSH_NOTIFY flag

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

log_info "🔥 Starting Enhanced Conditional Firebase Injection System..."

# Function to validate PUSH_NOTIFY flag
validate_push_notify_flag() {
    log_info "🔍 Validating PUSH_NOTIFY configuration..."
    
    # Normalize the flag
    case "${PUSH_NOTIFY:-false}" in
        "true"|"TRUE"|"True"|"1"|"yes"|"YES"|"Yes")
            export PUSH_NOTIFY="true"
            export FIREBASE_ENABLED="true"
            export PUSH_NOTIFICATIONS_ENABLED="true"
            log_info "🔔 Push notifications ENABLED - Firebase will be fully configured"
            ;;
        "false"|"FALSE"|"False"|"0"|"no"|"NO"|"No"|"")
            export PUSH_NOTIFY="false"
            export FIREBASE_ENABLED="false"
            export PUSH_NOTIFICATIONS_ENABLED="false"
            log_info "🔕 Push notifications DISABLED - Firebase will be completely excluded"
            ;;
        *)
            log_warn "⚠️ Invalid PUSH_NOTIFY value: ${PUSH_NOTIFY}. Defaulting to false"
            export PUSH_NOTIFY="false"
            export FIREBASE_ENABLED="false"
            export PUSH_NOTIFICATIONS_ENABLED="false"
            ;;
    esac
    
    log_success "✅ PUSH_NOTIFY flag validated: $PUSH_NOTIFY"
    log_info "📊 Configuration Summary:"
    log_info "   - Firebase Enabled: $FIREBASE_ENABLED"
    log_info "   - Push Notifications: $PUSH_NOTIFICATIONS_ENABLED"
    return 0
}

# Function to inject Firebase-enabled pubspec.yaml
inject_firebase_enabled_pubspec() {
    log_info "🔥 Injecting Firebase-enabled pubspec.yaml..."
    
    # Create backup
    if [ -f "pubspec.yaml" ]; then
        cp pubspec.yaml pubspec.yaml.firebase_backup
        log_info "✅ Original pubspec.yaml backed up"
    fi
    
    # Generate Firebase-enabled pubspec.yaml
    cat > pubspec.yaml << PUBSPEC_EOF
name: $(echo "${APP_NAME:-twinklub_app}" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9 ' | tr ' ' '_')
description: A Flutter application with Firebase support
publish_to: 'none'
version: ${VERSION_NAME:-1.0.6}+50

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # Core dependencies
  cupertino_icons: ^1.0.2
  http: ^1.1.0
  url_launcher: ^6.1.12
  webview_flutter: ^4.4.1
  connectivity_plus: ^5.0.1
  permission_handler: ^11.0.1
  
  # Firebase dependencies (ENABLED for push notifications)
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  firebase_analytics: ^10.7.4
  
  # UI dependencies
  flutter_launcher_icons: ^0.13.1
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/icons/
    - assets/images/

flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icons/app_icon.png"
PUBSPEC_EOF
    
    log_success "✅ Firebase-enabled pubspec.yaml injected"
}

# Function to inject Firebase-disabled pubspec.yaml
inject_firebase_disabled_pubspec() {
    log_info "🚫 Injecting Firebase-disabled pubspec.yaml..."
    
    # Create backup
    if [ -f "pubspec.yaml" ]; then
        cp pubspec.yaml pubspec.yaml.firebase_backup
        log_info "✅ Original pubspec.yaml backed up"
    fi
    
    # Generate Firebase-disabled pubspec.yaml  
    cat > pubspec.yaml << PUBSPEC_EOF
name: $(echo "${APP_NAME:-twinklub_app}" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9 ' | tr ' ' '_')
description: A Flutter application without Firebase
publish_to: 'none'
version: ${VERSION_NAME:-1.0.6}+50

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # Core dependencies
  cupertino_icons: ^1.0.2
  http: ^1.1.0
  url_launcher: ^6.1.12
  webview_flutter: ^4.4.1
  connectivity_plus: ^5.0.1
  permission_handler: ^11.0.1
  
  # Firebase dependencies DISABLED - no Firebase packages for push notifications
  
  # UI dependencies
  flutter_launcher_icons: ^0.13.1
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/icons/
    - assets/images/

flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icons/app_icon.png"
PUBSPEC_EOF
    
    log_success "✅ Firebase-disabled pubspec.yaml injected"
}

# Function to inject Firebase-enabled main.dart
inject_firebase_enabled_main_dart() {
    log_info "🔥 Injecting Firebase-enabled main.dart..."
    
    # Create backup
    if [ -f "lib/main.dart" ]; then
        cp lib/main.dart lib/main.dart.firebase_backup
        log_info "✅ Original main.dart backed up"
    fi
    
    # Ensure lib directory exists
    mkdir -p lib
    
    # Generate Firebase-enabled main.dart
    cat > lib/main.dart << DART_EOF
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Firebase background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: \${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Set up Firebase messaging background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseMessaging? _messaging;
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
  }

  Future<void> _initializeFirebaseMessaging() async {
    _messaging = FirebaseMessaging.instance;
    
    // Request permission for iOS
    NotificationSettings settings = await _messaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      
      // Get FCM token
      _fcmToken = await _messaging!.getToken();
      print('FCM Token: \$_fcmToken');
      
      // Listen to foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: \${message.data}');
        
        if (message.notification != null) {
          print('Message also contained a notification: \${message.notification}');
          _showNotificationDialog(message.notification!);
        }
      });
      
      // Handle notification taps
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('A new onMessageOpenedApp event was published!');
        print('Message data: \${message.data}');
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void _showNotificationDialog(RemoteNotification notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(notification.title ?? 'Notification'),
          content: Text(notification.body ?? 'No message body'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${APP_NAME:-${ORG_NAME:-QuikApp} App}',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('${APP_NAME:-${ORG_NAME:-Twinklub} App}'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_active,
                size: 64,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              Text(
                'Welcome to ${APP_NAME:-${ORG_NAME:-Twinklub} App}',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Firebase Push Notifications Enabled',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (_fcmToken != null) ...[
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'FCM Token:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          _fcmToken!,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
DART_EOF
    
    log_success "✅ Firebase-enabled main.dart injected"
}

# Function to inject Firebase-disabled main.dart
inject_firebase_disabled_main_dart() {
    log_info "🚫 Injecting Firebase-disabled main.dart..."
    
    # Create backup
    if [ -f "lib/main.dart" ]; then
        cp lib/main.dart lib/main.dart.firebase_backup
        log_info "✅ Original main.dart backed up"
    fi
    
    # Ensure lib directory exists
    mkdir -p lib
    
    # Generate Firebase-disabled main.dart
    cat > lib/main.dart << DART_EOF
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // No Firebase initialization - Firebase and push notifications disabled
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${APP_NAME:-${ORG_NAME:-Twinklub} App}',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('${APP_NAME:-${ORG_NAME:-Twinklub} App}'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_off,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 20),
              Text(
                'Welcome to ${APP_NAME:-${ORG_NAME:-Twinklub} App}',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Firebase Push Notifications Disabled',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This build does not include Firebase or push notification functionality.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
DART_EOF
    
    log_success "✅ Firebase-disabled main.dart injected"
}

# Function to inject Firebase configuration files
inject_firebase_config_files() {
    log_info "🔥 Injecting Firebase configuration files..."
    
    # Inject iOS Firebase config if URL provided
    if [ -n "${FIREBASE_CONFIG_IOS:-}" ]; then
        log_info "📱 Downloading iOS Firebase config..."
        mkdir -p ios/Runner
        
        if curl -fsSL -o ios/Runner/GoogleService-Info.plist "${FIREBASE_CONFIG_IOS}"; then
            log_success "✅ iOS Firebase config downloaded"
        else
            log_error "❌ Failed to download iOS Firebase config from: ${FIREBASE_CONFIG_IOS}"
            
            # Create placeholder Firebase config
            log_info "📝 Creating placeholder iOS Firebase config..."
            cat > ios/Runner/GoogleService-Info.plist << PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CLIENT_ID</key>
	<string>PLACEHOLDER_CLIENT_ID</string>
	<key>REVERSED_CLIENT_ID</key>
	<string>PLACEHOLDER_REVERSED_CLIENT_ID</string>
	<key>API_KEY</key>
	<string>PLACEHOLDER_API_KEY</string>
	<key>GCM_SENDER_ID</key>
	<string>PLACEHOLDER_SENDER_ID</string>
	<key>PLIST_VERSION</key>
	<string>1</string>
	<key>BUNDLE_ID</key>
	<string>${BUNDLE_ID:-com.twinklub.twinklub}</string>
	<key>PROJECT_ID</key>
	<string>twinklub-app</string>
	<key>STORAGE_BUCKET</key>
	<string>twinklub-app.appspot.com</string>
	<key>IS_ADS_ENABLED</key>
	<false/>
	<key>IS_ANALYTICS_ENABLED</key>
	<false/>
	<key>IS_APPINVITE_ENABLED</key>
	<true/>
	<key>IS_GCM_ENABLED</key>
	<true/>
	<key>IS_SIGNIN_ENABLED</key>
	<true/>
	<key>GOOGLE_APP_ID</key>
	<string>PLACEHOLDER_GOOGLE_APP_ID</string>
</dict>
</plist>
PLIST_EOF
            log_warn "⚠️ Placeholder Firebase config created - replace with actual config for production"
        fi
    else
        log_warn "⚠️ FIREBASE_CONFIG_IOS not provided, creating placeholder config..."
        mkdir -p ios/Runner
        cat > ios/Runner/GoogleService-Info.plist << PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CLIENT_ID</key>
	<string>PLACEHOLDER_CLIENT_ID</string>
	<key>REVERSED_CLIENT_ID</key>
	<string>PLACEHOLDER_REVERSED_CLIENT_ID</string>
	<key>API_KEY</key>
	<string>PLACEHOLDER_API_KEY</string>
	<key>GCM_SENDER_ID</key>
	<string>PLACEHOLDER_SENDER_ID</string>
	<key>PLIST_VERSION</key>
	<string>1</string>
	<key>BUNDLE_ID</key>
	<string>${BUNDLE_ID:-com.twinklub.twinklub}</string>
	<key>PROJECT_ID</key>
	<string>twinklub-app</string>
	<key>STORAGE_BUCKET</key>
	<string>twinklub-app.appspot.com</string>
	<key>IS_ADS_ENABLED</key>
	<false/>
	<key>IS_ANALYTICS_ENABLED</key>
	<false/>
	<key>IS_APPINVITE_ENABLED</key>
	<true/>
	<key>IS_GCM_ENABLED</key>
	<true/>
	<key>IS_SIGNIN_ENABLED</key>
	<true/>
	<key>GOOGLE_APP_ID</key>
	<string>PLACEHOLDER_GOOGLE_APP_ID</string>
</dict>
</plist>
PLIST_EOF
        log_warn "⚠️ Placeholder Firebase config created - provide FIREBASE_CONFIG_IOS URL for production"
    fi
    
    # Inject Android Firebase config if URL provided
    if [ -n "${FIREBASE_CONFIG_ANDROID:-}" ]; then
        log_info "🤖 Downloading Android Firebase config..."
        mkdir -p android/app
        
        if curl -fsSL -o android/app/google-services.json "${FIREBASE_CONFIG_ANDROID}"; then
            log_success "✅ Android Firebase config downloaded"
        else
            log_error "❌ Failed to download Android Firebase config from: ${FIREBASE_CONFIG_ANDROID}"
        fi
    fi
    
    log_success "✅ Firebase configuration files processed"
}

# Function to remove Firebase configuration files
remove_firebase_config_files() {
    log_info "🚫 Removing Firebase configuration files..."
    
    # Remove iOS Firebase config
    if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
        mv ios/Runner/GoogleService-Info.plist ios/Runner/GoogleService-Info.plist.disabled
        log_info "✅ iOS Firebase config disabled"
    fi
    
    # Remove Android Firebase config
    if [ -f "android/app/google-services.json" ]; then
        mv android/app/google-services.json android/app/google-services.json.disabled
        log_info "✅ Android Firebase config disabled"
    fi
    
    log_success "✅ Firebase configuration files removed"
}

# Function to inject Firebase-enabled iOS Podfile
inject_firebase_enabled_podfile() {
    log_info "🔥 Injecting Firebase-enabled iOS Podfile..."
    
    # Create backup
    if [ -f "ios/Podfile" ]; then
        cp ios/Podfile ios/Podfile.firebase_backup
        log_info "✅ Original Podfile backed up"
    fi
    
    # Generate Firebase-enabled Podfile
    cat > ios/Podfile << 'PODFILE_EOF'
platform :ios, '13.0'
use_frameworks! :linkage => :static

ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  target 'RunnerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      # Core iOS settings
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      
      # Firebase & Xcode 16.0 compatibility settings
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      config.build_settings['SWIFT_VERSION'] = '5.0'
      config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
      config.build_settings['ENABLE_PREVIEWS'] = 'NO'
      config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
      
      # Firebase specific settings for Xcode 16
      if target.name.start_with?('Firebase')
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1'
        config.build_settings['OTHER_CFLAGS'] ||= ['$(inherited)']
        config.build_settings['OTHER_CFLAGS'] << '-Wno-error'
        config.build_settings['CLANG_WARN_STRICT_PROTOTYPES'] = 'NO'
      end
      
      # Bundle identifier collision prevention
      next if target.name == 'Runner'
      
      if config.build_settings['PRODUCT_BUNDLE_IDENTIFIER']
        current_bundle_id = config.build_settings['PRODUCT_BUNDLE_IDENTIFIER']
        if current_bundle_id.include?('${BUNDLE_ID:-com.twinklub.twinklub}') || current_bundle_id.include?('com.example')
          config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = current_bundle_id + '.pod.' + target.name.downcase
        end
      end
    end
  end
end
PODFILE_EOF
    
    log_success "✅ Firebase-enabled Podfile injected"
}

# Function to inject Firebase-disabled iOS Podfile
inject_firebase_disabled_podfile() {
    log_info "🚫 Injecting Firebase-disabled iOS Podfile..."
    
    # Create backup
    if [ -f "ios/Podfile" ]; then
        cp ios/Podfile ios/Podfile.firebase_backup
        log_info "✅ Original Podfile backed up"
    fi
    
    # Generate Firebase-disabled Podfile
    cat > ios/Podfile << 'PODFILE_EOF'
platform :ios, '13.0'
use_frameworks! :linkage => :static

ENV['COCOAPODS_DISABLE_STATS'] = 'true'
ENV['FIREBASE_DISABLED'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  target 'RunnerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      # Core iOS settings
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      
      # Standard Xcode compatibility settings (no Firebase)
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      config.build_settings['SWIFT_VERSION'] = '5.0'
      config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
      
      # Bundle identifier collision prevention
      next if target.name == 'Runner'
      
      if config.build_settings['PRODUCT_BUNDLE_IDENTIFIER']
        current_bundle_id = config.build_settings['PRODUCT_BUNDLE_IDENTIFIER']
        if current_bundle_id.include?('${BUNDLE_ID:-com.twinklub.twinklub}') || current_bundle_id.include?('com.example')
          config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = current_bundle_id + '.pod.' + target.name.downcase
        end
      end
    end
  end
end
PODFILE_EOF
    
    log_success "✅ Firebase-disabled Podfile injected"
}

# Function to handle iOS Info.plist push notification permissions
handle_ios_push_notification_permissions() {
    local plist_file="ios/Runner/Info.plist"
    
    if [ "$PUSH_NOTIFICATIONS_ENABLED" = "true" ]; then
        log_info "🔔 Adding push notification permissions to iOS Info.plist..."
        
        # Add background modes for push notifications
        plutil -insert "UIBackgroundModes" -array "$plist_file" 2>/dev/null || true
        plutil -insert "UIBackgroundModes.0" -string "remote-notification" "$plist_file" 2>/dev/null || true
        
        # Add notification usage description
        plutil -insert "NSUserNotificationUsageDescription" -string "This app uses notifications to keep you updated with important information." "$plist_file" 2>/dev/null || \
        plutil -replace "NSUserNotificationUsageDescription" -string "This app uses notifications to keep you updated with important information." "$plist_file" 2>/dev/null || true
        
        log_success "✅ Push notification permissions added to iOS Info.plist"
    else
        log_info "🔕 Removing push notification permissions from iOS Info.plist..."
        
        # Remove background modes for push notifications
        plutil -remove "UIBackgroundModes" "$plist_file" 2>/dev/null || true
        
        # Remove notification usage description
        plutil -remove "NSUserNotificationUsageDescription" "$plist_file" 2>/dev/null || true
        
        log_success "✅ Push notification permissions removed from iOS Info.plist"
    fi
}

# Function to clean up Firebase-related files when disabled
cleanup_firebase_files() {
    log_info "🧹 Cleaning up Firebase-related files..."
    
    # Remove Firebase-related directories and files
    local firebase_files=(
        "ios/Pods/Firebase"
        "ios/Pods/FirebaseCore"
        "ios/Pods/FirebaseMessaging"
        "ios/Pods/FirebaseAnalytics"
        "ios/Pods/GoogleUtilities"
        "ios/Pods/GTMSessionFetcher"
        "ios/Pods/nanopb"
        "ios/Pods/Protobuf"
    )
    
    for file in "${firebase_files[@]}"; do
        if [ -e "$file" ]; then
            rm -rf "$file"
            log_info "🗑️ Removed: $file"
        fi
    done
    
    # Clean up Pods directory if it exists
    if [ -d "ios/Pods" ]; then
        log_info "🧹 Cleaning up Pods directory..."
        find ios/Pods -name "*Firebase*" -type d -exec rm -rf {} + 2>/dev/null || true
        find ios/Pods -name "*GoogleUtilities*" -type d -exec rm -rf {} + 2>/dev/null || true
    fi
    
    log_success "✅ Firebase cleanup completed"
}

# Main conditional injection function
perform_conditional_injection() {
    log_info "🎯 Performing conditional Firebase injection based on PUSH_NOTIFY: $PUSH_NOTIFY"
    
    if [ "$FIREBASE_ENABLED" = "true" ]; then
        log_info "🔥 === FIREBASE ENABLED MODE ==="
        
        # Inject Firebase-enabled files
        inject_firebase_enabled_pubspec
        inject_firebase_enabled_main_dart
        inject_firebase_enabled_podfile
        inject_firebase_config_files
        handle_ios_push_notification_permissions
        
        log_success "✅ Firebase injection completed - all Firebase features enabled"
        
    else
        log_info "🚫 === FIREBASE DISABLED MODE ==="
        
        # Inject Firebase-disabled files
        inject_firebase_disabled_pubspec
        inject_firebase_disabled_main_dart
        inject_firebase_disabled_podfile
        remove_firebase_config_files
        handle_ios_push_notification_permissions
        cleanup_firebase_files
        
        log_success "✅ Firebase exclusion completed - all Firebase features disabled"
    fi
    
    # Create injection summary
    create_injection_summary
}

# Function to create injection summary
create_injection_summary() {
    local summary_file="FIREBASE_INJECTION_SUMMARY.txt"
    
    cat > "$summary_file" << SUMMARY_EOF
=== Enhanced Conditional Firebase Injection Summary ===
Date: $(date)
PUSH_NOTIFY Flag: $PUSH_NOTIFY
Firebase Status: $([ "$FIREBASE_ENABLED" = "true" ] && echo "ENABLED" || echo "DISABLED")
Push Notifications: $([ "$PUSH_NOTIFICATIONS_ENABLED" = "true" ] && echo "ENABLED" || echo "DISABLED")

=== Files Modified ===
- pubspec.yaml: $([ "$FIREBASE_ENABLED" = "true" ] && echo "Firebase dependencies INCLUDED" || echo "Firebase dependencies EXCLUDED")
- lib/main.dart: $([ "$FIREBASE_ENABLED" = "true" ] && echo "Firebase initialization INCLUDED" || echo "Firebase initialization EXCLUDED")
- ios/Podfile: $([ "$FIREBASE_ENABLED" = "true" ] && echo "Firebase pods ENABLED" || echo "Firebase pods DISABLED")
- ios/Runner/Info.plist: $([ "$PUSH_NOTIFICATIONS_ENABLED" = "true" ] && echo "Push notification permissions ADDED" || echo "Push notification permissions REMOVED")
- Firebase configs: $([ "$FIREBASE_ENABLED" = "true" ] && echo "ACTIVE" || echo "REMOVED")

=== Environment Variables ===
PUSH_NOTIFY: ${PUSH_NOTIFY}
FIREBASE_ENABLED: ${FIREBASE_ENABLED}
PUSH_NOTIFICATIONS_ENABLED: ${PUSH_NOTIFICATIONS_ENABLED}
FIREBASE_CONFIG_IOS: ${FIREBASE_CONFIG_IOS:+SET}
FIREBASE_CONFIG_ANDROID: ${FIREBASE_CONFIG_ANDROID:+SET}

=== Backup Files Created ===
- pubspec.yaml.firebase_backup
- lib/main.dart.firebase_backup
- ios/Podfile.firebase_backup

=== Cleanup Actions ===
$([ "$FIREBASE_ENABLED" = "false" ] && echo "- Firebase-related files cleaned up" || echo "- No cleanup needed (Firebase enabled)")

Enhanced conditional injection completed successfully!
SUMMARY_EOF
    
    log_success "✅ Injection summary created: $summary_file"
}

# Main execution function
main() {
    log_info "🚀 Starting Enhanced Conditional Firebase Injection System..."
    
    # Step 1: Validate PUSH_NOTIFY flag
    validate_push_notify_flag
    
    # Step 2: Perform conditional injection
    perform_conditional_injection
    
    log_success "✅ Enhanced Conditional Firebase injection completed successfully!"
    log_info "📋 Summary: PUSH_NOTIFY=$PUSH_NOTIFY, Firebase=$([ "$FIREBASE_ENABLED" = "true" ] && echo "ENABLED" || echo "DISABLED"), Push Notifications=$([ "$PUSH_NOTIFICATIONS_ENABLED" = "true" ] && echo "ENABLED" || echo "DISABLED")"
    
    return 0
}

# Execute main function if script is run directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi 